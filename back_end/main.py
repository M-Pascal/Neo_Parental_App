# Essential imports
from fastapi import FastAPI, File, UploadFile, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import uvicorn
import librosa
import numpy as np
import joblib
import os
from pathlib import Path
from typing import Dict, Optional
from datetime import datetime
import logging

# LOGGING CONFIGURATION
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# FASTAPI APP SETUP
app = FastAPI(
    title="NeoParental Prediction API",
    description="API for predicting baby cry sound classes using the best trained model",
    version="2.3.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# DIRECTORIES & PATHS
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "Model" / "saved_model"
MODEL_PATH = MODEL_DIR / "best_model.joblib"
TEMP_DIR = BASE_DIR / "temp"

MODEL_DIR.mkdir(parents=True, exist_ok=True)
TEMP_DIR.mkdir(exist_ok=True)

# GLOBAL VARIABLES
model = None
model_type = None
model_metadata = {}

# CLASS LABELS
class_labels = {
    0: "Belly_pain",
    1: "Burping",
    2: "Discomfort",
    3: "Hungry",
    4: "Tired/Sleepy"
}

# RESPONSE MODELS
class PredictionResponse(BaseModel):
    prediction_value: float
    predicted_label: Optional[str]
    confidence: Optional[float]
    processing_time: float
    timestamp: str

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: Optional[str]
    model_metadata: Dict
    timestamp: str

# MODEL LOADING
def load_model():
    global model, model_type, model_metadata
    try:
        if MODEL_PATH.exists():
            logger.info(f"Loading model from: {MODEL_PATH}")
            model = joblib.load(MODEL_PATH)

            # Detect model type dynamically
            model_class_name = model.__class__.__name__
            if "Classifier" in model_class_name:
                model_type = "classifier"
            else:
                model_type = "regressor"

            model_metadata = {
                "type": model_type,
                "class": model_class_name,
                "path": str(MODEL_PATH),
                "library": "scikit-learn"
            }
            logger.info(f"Model loaded successfully: {model_class_name}")
        else:
            logger.error("No model file found in Model/saved_model/")
            model_metadata = {"error": "Model file not found"}
    except Exception as e:
        logger.error(f"Model loading error: {e}")
        model_metadata = {"error": str(e)}
        raise

# FEATURE EXTRACTION
def extract_audio_features(file_path: Path) -> np.ndarray:
    try:
        n_mfcc = 40
        n_fft = 1024
        hop_length = 10 * 16
        win_length = 25 * 16
        window = 'hann'
        n_mels = 128
        n_bands = 7
        fmin = 100

        y, sr = librosa.load(file_path, sr=16000)

        mfcc = np.mean(librosa.feature.mfcc(
            y=y, sr=sr, n_mfcc=n_mfcc, n_fft=n_fft,
            hop_length=hop_length, win_length=win_length,
            window=window
        ).T, axis=0)

        mel = np.mean(librosa.feature.melspectrogram(
            y=y, sr=sr, n_fft=n_fft, hop_length=hop_length,
            win_length=win_length, window='hann', n_mels=n_mels
        ).T, axis=0)

        stft = np.abs(librosa.stft(y))
        chroma = np.mean(librosa.feature.chroma_stft(S=stft, y=y, sr=sr).T, axis=0)
        contrast = np.mean(librosa.feature.spectral_contrast(
            S=stft, y=y, sr=sr, n_fft=n_fft, hop_length=hop_length,
            win_length=win_length, n_bands=n_bands, fmin=fmin
        ).T, axis=0)
        tonnetz = np.mean(librosa.feature.tonnetz(y=y, sr=sr).T, axis=0)

        features = np.concatenate((mfcc, chroma, mel, contrast, tonnetz))
        return features.reshape(1, -1)
    except Exception as e:
        logger.error(f"Feature extraction error: {e}")
        raise HTTPException(status_code=400, detail=f"Feature extraction failed: {e}")

# FILE VALIDATION & CLEANUP
def validate_audio_file(file: UploadFile) -> bool:
    allowed_extensions = {'.wav', '.mp3', '.m4a', '.flac', '.ogg', '.aac'}
    return Path(file.filename).suffix.lower() in allowed_extensions

async def cleanup_file(file_path: Path):
    try:
        if file_path.exists():
            file_path.unlink()
            logger.debug(f"Cleaned up file: {file_path}")
    except Exception as e:
        logger.warning(f"Failed to delete {file_path}: {e}")

# STARTUP EVENT
@app.on_event("startup")
async def startup_event():
    logger.info("Starting NeoParental Prediction API...")
    load_model()

# HEALTH CHECK
@app.get("/", response_model=HealthResponse)
async def root():
    return HealthResponse(
        status="online",
        model_loaded=model is not None,
        model_type=model_type,
        model_metadata=model_metadata,
        timestamp=datetime.now().isoformat()
    )

@app.get("/health", response_model=HealthResponse)
async def health_check():
    return await root()

# PREDICTION ENDPOINT
@app.post("/predict", response_model=PredictionResponse)
async def predict_audio(background_tasks: BackgroundTasks, file: UploadFile = File(...)):
    """Predict baby cry category using the trained model."""
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")
    if not validate_audio_file(file):
        raise HTTPException(status_code=400, detail="Invalid audio format.")

    temp_file = TEMP_DIR / f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
    start_time = datetime.now()

    try:
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File exceeds 10MB limit.")
        with open(temp_file, "wb") as f:
            f.write(contents)

        features = extract_audio_features(temp_file)

        # Prediction + confidence handling
        if model_type == "classifier":
            probs = model.predict_proba(features)[0]
            pred_index = int(np.argmax(probs))
            confidence = float(np.max(probs))
            prediction_value = pred_index
            predicted_label = class_labels.get(pred_index, None)

        else:  # Regressor
            prediction_value = float(model.predict(features)[0])
            predicted_label = class_labels.get(round(prediction_value), None)
            # Simulate confidence based on proximity to integer class
            confidence = max(0.0, 1.0 - abs(prediction_value - round(prediction_value)))

        return PredictionResponse(
            prediction_value=prediction_value,
            predicted_label=predicted_label,
            confidence=round(confidence * 100, 2),
            processing_time=(datetime.now() - start_time).total_seconds(),
            timestamp=datetime.now().isoformat()
        )

    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {e}")
    finally:
        background_tasks.add_task(cleanup_file, temp_file)

# ERROR HANDLER
@app.exception_handler(Exception)
async def general_exception_handler(_, exc: Exception):
    logger.error(f"Unhandled error: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal Server Error",
            "detail": str(exc),
            "timestamp": datetime.now().isoformat()
        }
    )

# RUN SERVER
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False, log_level="info")
