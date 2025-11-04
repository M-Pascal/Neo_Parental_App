import os
from dotenv import load_dotenv
import ssl
import certifi
import motor.motor_asyncio
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, status, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.responses import JSONResponse
from pydantic import BaseModel, EmailStr, Field
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional, List, Dict
from bson import ObjectId
import librosa
import numpy as np
import joblib
from pathlib import Path
import logging
from openai import OpenAI
import cloudinary
import cloudinary.uploader
import cloudinary.api
import warnings

# Suppress sklearn version warning
warnings.filterwarnings("ignore", category=UserWarning, module="sklearn")

# LOGGING CONFIGURATION
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables
load_dotenv()

# === Configuration ===
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
JWT_SECRET = os.getenv("JWT_SECRET", "your_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# OpenAI client
openai_client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# === Cloudinary Configuration ===
try:
    # Try individual credentials first (more reliable)
    CLOUDINARY_CLOUD_NAME = os.getenv("CLOUDINARY_CLOUD_NAME")
    CLOUDINARY_API_KEY = os.getenv("CLOUDINARY_API_KEY")
    CLOUDINARY_API_SECRET = os.getenv("CLOUDINARY_API_SECRET")
    
    if all([CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET]):
        cloudinary.config(
            cloud_name=CLOUDINARY_CLOUD_NAME,
            api_key=CLOUDINARY_API_KEY,
            api_secret=CLOUDINARY_API_SECRET
        )
        logger.info(f"Cloudinary configured via individual credentials")
    else:
        # Fallback to CLOUDINARY_URL
        CLOUDINARY_URL = os.getenv("CLOUDINARY_URL")
        if not CLOUDINARY_URL:
            raise ValueError("Cloudinary credentials not found in environment variables")
        
        cloudinary.config(cloudinary_url=CLOUDINARY_URL)
        logger.info(f"Cloudinary configured via CLOUDINARY_URL")
    
    # Verify configuration
    cloud_name = cloudinary.config().cloud_name
    api_key = cloudinary.config().api_key
    api_secret = cloudinary.config().api_secret
    
    if not all([cloud_name, api_key, api_secret]):
        logger.error(f"Config check: cloud_name={cloud_name}, api_key={'exists' if api_key else 'missing'}, api_secret={'exists' if api_secret else 'missing'}")
        raise ValueError("Cloudinary configuration incomplete after setup")
    
    logger.info(f"Cloudinary cloud name: {cloud_name}")
    
    # Test connection
    try:
        cloudinary.api.ping()
        logger.info("Cloudinary connection test successful")
    except Exception as ping_error:
        logger.warning(f"Cloudinary ping test failed: {ping_error}")
    
except Exception as e:
    logger.error(f"Cloudinary configuration failed: {e}")
    raise

# ML Model paths
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "Model" / "saved_model"
MODEL_PATH = MODEL_DIR / "best_model.joblib"
TEMP_DIR = BASE_DIR / "temp"

MODEL_DIR.mkdir(parents=True, exist_ok=True)
TEMP_DIR.mkdir(exist_ok=True)

# === MongoDB connection ===
try:
    client = motor.motor_asyncio.AsyncIOMotorClient(
        MONGO_URI,
        tlsCAFile=certifi.where(),
        serverSelectionTimeoutMS=30000
    )
    db = client[DB_NAME]
    users_collection = db["users"]
    predictions_collection = db["predictions"]
    logger.info(" MongoDB connection initialized")
except Exception as e:
    logger.error(f" MongoDB connection failed: {e}")
    raise

# === Password hashing ===
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# === FastAPI app ===
app = FastAPI(
    title="NeoParental Application API",
    description="Complete API for authentication, chatbot, and baby cry prediction with Cloudinary storage",
    version="1.0.0"
)

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# === Global ML Model Variables ===
ml_model = None
model_type = None
model_metadata = {}

# Class labels for predictions
class_labels = {
    0: "Belly_pain",
    1: "Burping",
    2: "Discomfort",
    3: "Hungry",
    4: "Tired/Sleepy"
}

# === Helper Functions ===
def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, JWT_SECRET, algorithm=ALGORITHM)

def objectid_to_str(o):
    return str(o) if isinstance(o, ObjectId) else o

# === ML Model Functions ===
def load_ml_model():
    global ml_model, model_type, model_metadata
    try:
        if MODEL_PATH.exists():
            logger.info(f"Loading model from: {MODEL_PATH}")
            ml_model = joblib.load(MODEL_PATH)
            model_class_name = ml_model.__class__.__name__
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
            logger.info(f" Model loaded successfully: {model_class_name}")
        else:
            logger.error(" No model file found in Model/saved_model/")
            model_metadata = {"error": "Model file not found"}
    except Exception as e:
        logger.error(f" Model loading error: {e}")
        model_metadata = {"error": str(e)}

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

async def upload_to_cloudinary(file_path: Path, user_id: str, original_filename: str) -> dict:
    """Upload audio file to Cloudinary and return the response"""
    try:
        # Create a unique public_id using user_id and timestamp
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        public_id = f"neoparental/audio/{user_id}/{timestamp}_{Path(original_filename).stem}"
        
        # Upload to Cloudinary
        upload_result = cloudinary.uploader.upload(
            str(file_path),
            resource_type="video",
            public_id=public_id,
            folder="neoparental/audio",
            overwrite=True,
            tags=[f"user_{user_id}", "baby_cry"]
        )
        
        logger.info(f" Uploaded to Cloudinary: {upload_result.get('secure_url')}")
        return upload_result
    except Exception as e:
        logger.error(f" Cloudinary upload error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to upload audio to cloud storage: {e}")

# === Pydantic Models ===
class UserIn(BaseModel):
    username: str = Field(..., min_length=3)
    first_name: str
    last_name: str
    email: EmailStr
    telephone: str
    address: str
    password: str = Field(..., min_length=6)

class UserOut(BaseModel):
    id: str
    username: str
    first_name: str
    last_name: str
    email: EmailStr
    telephone: str
    address: str
    role: str
    created_at: datetime

class UserUpdate(BaseModel):
    username: Optional[str] = None
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    telephone: Optional[str] = None
    address: Optional[str] = None
    password: Optional[str] = None

class Token(BaseModel):
    access_token: str
    token_type: str

class Message(BaseModel):
    message: str

class PredictionResponse(BaseModel):
    prediction_id: str
    prediction_value: float
    predicted_label: Optional[str]
    confidence: Optional[float]
    audio_filename: str
    audio_url: str
    cloudinary_public_id: str
    processing_time: float
    timestamp: str

class PredictionHistory(BaseModel):
    id: str
    user_id: str
    username: str
    audio_filename: str
    audio_url: str
    cloudinary_public_id: str
    prediction_value: float
    predicted_label: Optional[str]
    confidence: Optional[float]
    created_at: datetime

class HealthResponse(BaseModel):
    status: str
    model_loaded: bool
    model_type: Optional[str]
    cloudinary_configured: bool
    timestamp: str

# === Auth Dependencies ===
async def get_current_user(token: str = Depends(oauth2_scheme)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    user = await users_collection.find_one({"_id": ObjectId(user_id)})
    if not user:
        raise credentials_exception
    user["id"] = objectid_to_str(user["_id"])
    return user

async def require_admin(user = Depends(get_current_user)):
    if user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin privileges required")
    return user

# === Startup Event ===
@app.on_event("startup")
async def startup_event():
    logger.info(" Starting NeoParental Application API...")
    load_ml_model()
    
    # Verify Cloudinary configuration
    try:
        cloud_name = cloudinary.config().cloud_name
        api_key = cloudinary.config().api_key
        if cloud_name and api_key:
            logger.info(f" Cloudinary configured: {cloud_name}")
        else:
            logger.warning(" Cloudinary configuration incomplete")
    except Exception as e:
        logger.error(f" Cloudinary configuration error: {e}")

# === Health Check Routes ===
@app.get("/health")
async def health_check():
    try:
        await db.command("ping")
        
        # Properly access cloudinary config
        cloud_name = cloudinary.config().cloud_name
        api_key = cloudinary.config().api_key
        cloudinary_ok = cloud_name is not None and api_key is not None
        
        return {
            "status": "online",
            "mongodb": "connected",
            "model_loaded": ml_model is not None,
            "model_type": model_type,
            "cloudinary_configured": cloudinary_ok,
            "cloudinary_cloud_name": cloud_name if cloudinary_ok else None,
            "timestamp": datetime.now().isoformat()
        }
    except Exception as e:
        return {
            "status": "error",
            "mongodb": "failed",
            "error": str(e),
            "timestamp": datetime.now().isoformat()
        }

# === Authentication Routes ===
@app.post("/register", response_model=UserOut)
async def register(user_in: UserIn):
    if await users_collection.find_one({"email": user_in.email}):
        raise HTTPException(status_code=400, detail="Email already registered")
    if await users_collection.find_one({"username": user_in.username}):
        raise HTTPException(status_code=400, detail="Username already taken")

    hashed_pwd = hash_password(user_in.password)
    doc = {
        "username": user_in.username,
        "first_name": user_in.first_name,
        "last_name": user_in.last_name,
        "email": user_in.email,
        "telephone": user_in.telephone,
        "address": user_in.address,
        "password_hash": hashed_pwd,
        "role": "user",
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }

    result = await users_collection.insert_one(doc)
    doc["id"] = str(result.inserted_id)

    return UserOut(
        id=doc["id"],
        username=doc["username"],
        first_name=doc["first_name"],
        last_name=doc["last_name"],
        email=doc["email"],
        telephone=doc["telephone"],
        address=doc["address"],
        role=doc["role"],
        created_at=doc["created_at"]
    )

@app.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    query = {"$or": [{"email": form_data.username}, {"username": form_data.username}]}
    user = await users_collection.find_one(query)
    if not user or not verify_password(form_data.password, user["password_hash"]):
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    access_token = create_access_token({"sub": str(user["_id"]), "role": user.get("role", "user")})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=UserOut)
async def read_me(current_user=Depends(get_current_user)):
    return UserOut(
        id=str(current_user["_id"]),
        username=current_user["username"],
        first_name=current_user["first_name"],
        last_name=current_user["last_name"],
        email=current_user["email"],
        telephone=current_user["telephone"],
        address=current_user["address"],
        role=current_user.get("role", "user"),
        created_at=current_user.get("created_at")
    )

@app.put("/users/me", response_model=UserOut)
async def update_me(update: UserUpdate, current_user=Depends(get_current_user)):
    update_doc = {}
    for field, value in update.dict(exclude_unset=True).items():
        if field == "password":
            update_doc["password_hash"] = hash_password(value)
        else:
            update_doc[field] = value

    if not update_doc:
        raise HTTPException(status_code=400, detail="Nothing to update")

    update_doc["updated_at"] = datetime.utcnow()
    await users_collection.update_one({"_id": current_user["_id"]}, {"$set": update_doc})

    user = await users_collection.find_one({"_id": current_user["_id"]})
    return UserOut(
        id=str(user["_id"]),
        username=user["username"],
        first_name=user["first_name"],
        last_name=user["last_name"],
        email=user["email"],
        telephone=user["telephone"],
        address=user["address"],
        role=user.get("role", "user"),
        created_at=user.get("created_at")
    )

# === Admin Routes ===
@app.get("/admin/users", response_model=List[UserOut])
async def list_all_users(admin_user=Depends(require_admin)):
    cursor = users_collection.find().sort("created_at", -1).limit(100)
    users = []
    async for u in cursor:
        users.append(UserOut(
            id=str(u["_id"]),
            username=u["username"],
            first_name=u["first_name"],
            last_name=u["last_name"],
            email=u["email"],
            telephone=u["telephone"],
            address=u["address"],
            role=u.get("role", "user"),
            created_at=u.get("created_at")
        ))
    return users

@app.delete("/admin/users/{user_id}", status_code=204)
async def delete_user(user_id: str, admin_user=Depends(require_admin)):
    # First, get all predictions for this user to delete their audio files from Cloudinary
    cursor = predictions_collection.find({"user_id": user_id})
    async for p in cursor:
        try:
            cloudinary_public_id = p.get("cloudinary_public_id")
            if cloudinary_public_id:
                cloudinary.uploader.destroy(cloudinary_public_id, resource_type="video")
                logger.info(f"Deleted audio from Cloudinary: {cloudinary_public_id}")
        except Exception as e:
            logger.warning(f"Failed to delete audio from Cloudinary: {e}")
    
    # Delete all predictions for this user
    await predictions_collection.delete_many({"user_id": user_id})
    
    # Delete the user
    res = await users_collection.delete_one({"_id": ObjectId(user_id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    return None

@app.get("/admin/predictions", response_model=List[PredictionHistory])
async def list_all_predictions(admin_user=Depends(require_admin)):
    cursor = predictions_collection.find().sort("created_at", -1).limit(100)
    predictions = []
    async for p in cursor:
        predictions.append(PredictionHistory(
            id=str(p["_id"]),
            user_id=p["user_id"],
            username=p["username"],
            audio_filename=p["audio_filename"],
            audio_url=p.get("audio_url", ""),
            cloudinary_public_id=p.get("cloudinary_public_id", ""),
            prediction_value=p["prediction_value"],
            predicted_label=p.get("predicted_label"),
            confidence=p.get("confidence"),
            created_at=p["created_at"]
        ))
    return predictions

@app.get("/admin/users/{user_id}/predictions", response_model=List[PredictionHistory])
async def get_user_predictions_admin(user_id: str, admin_user=Depends(require_admin)):
    cursor = predictions_collection.find({"user_id": user_id}).sort("created_at", -1)
    predictions = []
    async for p in cursor:
        predictions.append(PredictionHistory(
            id=str(p["_id"]),
            user_id=p["user_id"],
            username=p["username"],
            audio_filename=p["audio_filename"],
            audio_url=p.get("audio_url", ""),
            cloudinary_public_id=p.get("cloudinary_public_id", ""),
            prediction_value=p["prediction_value"],
            predicted_label=p.get("predicted_label"),
            confidence=p.get("confidence"),
            created_at=p["created_at"]
        ))
    return predictions

@app.delete("/admin/predictions/{prediction_id}", status_code=204)
async def delete_prediction(prediction_id: str, admin_user=Depends(require_admin)):
    # Get the prediction to find the Cloudinary public_id
    prediction = await predictions_collection.find_one({"_id": ObjectId(prediction_id)})
    if not prediction:
        raise HTTPException(status_code=404, detail="Prediction not found")
    
    # Delete from Cloudinary
    try:
        cloudinary_public_id = prediction.get("cloudinary_public_id")
        if cloudinary_public_id:
            cloudinary.uploader.destroy(cloudinary_public_id, resource_type="video")
            logger.info(f"Deleted audio from Cloudinary: {cloudinary_public_id}")
    except Exception as e:
        logger.warning(f"Failed to delete audio from Cloudinary: {e}")
    
    # Delete from database
    await predictions_collection.delete_one({"_id": ObjectId(prediction_id)})
    return None

# === Chatbot Route ===
@app.post("/chat")
def chat_endpoint(data: Message, current_user=Depends(get_current_user)):
    system_message = {
        "role": "system",
        "content": (
            "You are NeoParental, a compassionate and knowledgeable virtual assistant "
            "that helps parents with baby care, parenting advice, and emotional support. "
            "Respond in a friendly, conversational way with short answers — no more than 25 to 30 words. "
            "Encourage continued conversation naturally. "
            "If the question sounds serious, urgent, or medical-related "
            "(like high fever, breathing difficulty, dehydration, injury, etc.), "
            "politely advise them to seek immediate professional medical assistance."
        ),
    }

    response = openai_client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            system_message,
            {"role": "user", "content": data.message},
        ],
        max_tokens=60,
        temperature=0.8
    )

    return {"reply": response.choices[0].message.content.strip()}

# === Prediction Routes ===
@app.post("/predict", response_model=PredictionResponse)
async def predict_audio(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    current_user=Depends(get_current_user)
):
    """
    Upload audio file, predict baby cry category, and store in Cloudinary.
    Requires authentication - only logged-in users can upload.
    """
    if ml_model is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")
    if not validate_audio_file(file):
        raise HTTPException(status_code=400, detail="Invalid audio format. Allowed: .wav, .mp3, .m4a, .flac, .ogg, .aac")

    temp_file = TEMP_DIR / f"{datetime.now().strftime('%Y%m%d_%H%M%S')}_{file.filename}"
    start_time = datetime.now()

    try:
        # Save uploaded file temporarily
        contents = await file.read()
        if len(contents) > 10 * 1024 * 1024:
            raise HTTPException(status_code=400, detail="File exceeds 10MB limit.")
        with open(temp_file, "wb") as f:
            f.write(contents)

        # Extract features for prediction
        features = extract_audio_features(temp_file)

        # Make prediction
        if model_type == "classifier":
            probs = ml_model.predict_proba(features)[0]
            pred_index = int(np.argmax(probs))
            confidence = float(np.max(probs))
            prediction_value = pred_index
            predicted_label = class_labels.get(pred_index, None)
        else:
            prediction_value = float(ml_model.predict(features)[0])
            predicted_label = class_labels.get(round(prediction_value), None)
            confidence = max(0.0, 1.0 - abs(prediction_value - round(prediction_value)))

        # Upload to Cloudinary
        cloudinary_result = await upload_to_cloudinary(
            temp_file, 
            str(current_user["_id"]), 
            file.filename
        )

        # Save prediction to database with Cloudinary info
        prediction_doc = {
            "user_id": str(current_user["_id"]),
            "username": current_user["username"],
            "audio_filename": file.filename,
            "audio_url": cloudinary_result.get("secure_url"),
            "cloudinary_public_id": cloudinary_result.get("public_id"),
            "cloudinary_resource_type": cloudinary_result.get("resource_type"),
            "prediction_value": prediction_value,
            "predicted_label": predicted_label,
            "confidence": round(confidence * 100, 2),
            "created_at": datetime.utcnow()
        }
        result = await predictions_collection.insert_one(prediction_doc)

        return PredictionResponse(
            prediction_id=str(result.inserted_id),
            prediction_value=prediction_value,
            predicted_label=predicted_label,
            confidence=round(confidence * 100, 2),
            audio_filename=file.filename,
            audio_url=cloudinary_result.get("secure_url"),
            cloudinary_public_id=cloudinary_result.get("public_id"),
            processing_time=(datetime.now() - start_time).total_seconds(),
            timestamp=datetime.now().isoformat()
        )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=f"Error: {e}")
    finally:
        background_tasks.add_task(cleanup_file, temp_file)

@app.get("/predictions/me", response_model=List[PredictionHistory])
async def get_my_predictions(current_user=Depends(get_current_user)):
    """Get all predictions for the currently authenticated user"""
    cursor = predictions_collection.find({"user_id": str(current_user["_id"])}).sort("created_at", -1)
    predictions = []
    async for p in cursor:
        predictions.append(PredictionHistory(
            id=str(p["_id"]),
            user_id=p["user_id"],
            username=p["username"],
            audio_filename=p["audio_filename"],
            audio_url=p.get("audio_url", ""),
            cloudinary_public_id=p.get("cloudinary_public_id", ""),
            prediction_value=p["prediction_value"],
            predicted_label=p.get("predicted_label"),
            confidence=p.get("confidence"),
            created_at=p["created_at"]
        ))
    return predictions

@app.delete("/predictions/me/{prediction_id}", status_code=204)
async def delete_my_prediction(prediction_id: str, current_user=Depends(get_current_user)):
    """Delete a specific prediction (only if it belongs to the current user)"""
    prediction = await predictions_collection.find_one({"_id": ObjectId(prediction_id)})
    
    if not prediction:
        raise HTTPException(status_code=404, detail="Prediction not found")
    
    # Check if prediction belongs to current user
    if prediction["user_id"] != str(current_user["_id"]):
        raise HTTPException(status_code=403, detail="You can only delete your own predictions")
    
    # Delete from Cloudinary
    try:
        cloudinary_public_id = prediction.get("cloudinary_public_id")
        if cloudinary_public_id:
            cloudinary.uploader.destroy(cloudinary_public_id, resource_type="video")
            logger.info(f"Deleted audio from Cloudinary: {cloudinary_public_id}")
    except Exception as e:
        logger.warning(f"Failed to delete audio from Cloudinary: {e}")
    
    # Delete from database
    await predictions_collection.delete_one({"_id": ObjectId(prediction_id)})
    return None

# === Error Handler ===
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, log_level="info")
