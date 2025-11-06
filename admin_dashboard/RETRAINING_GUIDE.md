# 🧠 NeoParental Model Retraining Guide

## Overview

The NeoParental Admin Dashboard now includes a powerful model retraining feature that allows administrators to update the baby cry classification model with new training data.

## Features

✅ **Upload Custom Datasets** - Upload ZIP files containing labeled audio samples  
✅ **Real-time Training** - Train the model directly from the admin dashboard  
✅ **Comprehensive Metrics** - View accuracy, precision, recall, F1-score, and ROC-AUC  
✅ **Safe Model Management** - Review metrics before deciding to save or discard  
✅ **Training History** - Track all training sessions with timestamps and results  
✅ **Automatic Backup** - Previous models are automatically backed up before replacement

---

## 📋 Preparing Your Training Dataset

### 1. Dataset Structure

Your training data must be organized in the following folder structure:

```
training_dataset/
├── Belly_pain/
│   ├── audio_1.wav
│   ├── audio_2.wav
│   └── ...
├── Burping/
│   ├── audio_1.wav
│   ├── audio_2.wav
│   └── ...
├── Discomfort/
│   ├── audio_1.wav
│   ├── audio_2.wav
│   └── ...
├── Hungry/
│   ├── audio_1.wav
│   ├── audio_2.wav
│   └── ...
└── Tired_Sleepy/
    ├── audio_1.wav
    ├── audio_2.wav
    └── ...
```

### 2. Supported Audio Formats

- **WAV** (`.wav`) - Recommended
- **MP3** (`.mp3`)
- **FLAC** (`.flac`)

### 3. Audio Requirements

- **Sample Rate**: Any (will be resampled to 16kHz)
- **Duration**: Minimum 1 second recommended
- **Quality**: Higher quality audio produces better results

### 4. Dataset Size Recommendations

- **Minimum**: 50 samples per class (250 total)
- **Recommended**: 200+ samples per class (1000+ total)
- **Optimal**: 500+ samples per class (2500+ total)

### 5. Creating the ZIP File

**Windows:**

1. Right-click the `training_dataset` folder
2. Select "Send to" → "Compressed (zipped) folder"

**Mac:**

1. Right-click the `training_dataset` folder
2. Select "Compress"

**Linux:**

```bash
zip -r training_dataset.zip training_dataset/
```

---

## 🚀 Using the Retraining Feature

### Step 1: Access the Admin Dashboard

1. Log in to the admin dashboard at `http://localhost:8501`
2. Use your admin credentials

### Step 2: Navigate to Retrain Page

1. Click the **"🧠 Retrain Model"** button in the sidebar
2. You'll be redirected to the Model Retraining page

### Step 3: Upload Your Dataset

1. Read the instructions on the page
2. Click **"Browse files"** or drag and drop your ZIP file
3. Verify the file information (name, size, type)

### Step 4: Start Training

1. Click the **"🚀 Start Training"** button
2. Wait for the training to complete (may take several minutes)
3. A spinner will indicate progress

### Step 5: Review Metrics

After training, you'll see:

#### Main Metrics

- **🎯 Accuracy**: Overall correctness (e.g., 92.5%)
- **📊 Precision**: How many predictions were correct (e.g., 91.8%)
- **🔍 Recall**: How many actual labels were found (e.g., 92.1%)
- **⚖️ F1 Score**: Balance of precision and recall (e.g., 91.9%)
- **📈 ROC-AUC**: Multi-class performance score (e.g., 0.965)

#### Interpretation Guide

| Metric    | Excellent | Good      | Fair      | Poor   |
| --------- | --------- | --------- | --------- | ------ |
| Accuracy  | > 90%     | 80-90%    | 70-80%    | < 70%  |
| Precision | > 90%     | 80-90%    | 70-80%    | < 70%  |
| Recall    | > 90%     | 80-90%    | 70-80%    | < 70%  |
| F1 Score  | > 90%     | 80-90%    | 70-80%    | < 70%  |
| ROC-AUC   | > 0.95    | 0.90-0.95 | 0.85-0.90 | < 0.85 |

### Step 6: Save or Discard Model

#### Option A: Save Model ✅

1. If metrics are satisfactory, click **"✅ Save Model"**
2. The model will be saved and deployed immediately
3. A backup of the old model is created automatically
4. All future predictions will use the new model

#### Option B: Discard Model 🗑️

1. If metrics are not satisfactory, click **"🗑️ Discard Model"**
2. The trained model will be discarded
3. The current production model remains active
4. You can try again with a different dataset

---

## 📊 Understanding Training History

The training history shows all previous training sessions:

- **Run Number**: Sequential training session number
- **Timestamp**: When the training was completed
- **Metrics**: All evaluation metrics for comparison
- **Saved Status**: Whether the model was deployed (✅) or discarded (❌)

You can:

- Compare current results with previous trainings
- Track model improvements over time
- Download history as CSV for analysis

---

## 🔧 Backend API Endpoints

### POST `/admin/retrain`

Trains a new model with uploaded dataset.

**Request:**

- Method: `POST`
- Content-Type: `multipart/form-data`
- Body: ZIP file with training data
- Headers: `Authorization: Bearer <token>`

**Response:**

```json
{
  "status": "Retrained successfully",
  "accuracy": 0.925,
  "precision": 0.918,
  "recall": 0.921,
  "f1_score": 0.919,
  "roc_auc": 0.965,
  "timestamp": "2025-11-06T14:30:00"
}
```

### POST `/admin/save_model`

Saves the trained model to production.

**Request:**

- Method: `POST`
- Headers: `Authorization: Bearer <token>`

**Response:**

```json
{
  "status": "success",
  "message": "Model saved successfully and is now active",
  "timestamp": "2025-11-06T14:35:00"
}
```

---

## 🛠️ Technical Details

### Feature Extraction

The model extracts the following features from audio:

- **MFCC** (40 coefficients): Mel-frequency cepstral coefficients
- **Mel Spectrogram** (128 bands): Frequency content over time
- **Chroma**: Pitch class profiles
- **Spectral Contrast** (7 bands): Spectral peak and valley differences
- **Tonnetz**: Tonal centroid features

### Model Architecture

- **Algorithm**: Decision Tree Classifier
- **Imbalance Handling**: Random Oversampling
- **Train/Test Split**: 80/20
- **Random Seed**: 42 (for reproducibility)

### Performance Optimization

- Automatic class imbalance correction
- Multi-class ROC-AUC calculation
- Macro-averaged metrics for fair evaluation

---

## ⚠️ Important Notes

1. **Admin Access Required**: Only users with admin role can retrain models
2. **Training Time**: Depends on dataset size (typically 2-10 minutes)
3. **Model Backup**: Old models are backed up with timestamp before replacement
4. **Session Storage**: Trained model is stored temporarily until saved or discarded
5. **Server Restart**: If server restarts before saving, unsaved models are lost

---

## 🐛 Troubleshooting

### Error: "No folders found inside the ZIP file"

**Solution**: Ensure your ZIP contains a folder with labeled subfolders

### Error: "No valid audio files found"

**Solution**: Check that audio files are in supported formats (WAV, MP3, FLAC)

### Error: "Request timeout"

**Solution**: Dataset may be too large. Try with a smaller dataset first

### Error: "Admin access required"

**Solution**: Ensure you're logged in with an admin account

### Low Accuracy Results

**Possible Causes:**

- Insufficient training data
- Poor audio quality
- Class imbalance (some classes have very few samples)
- Mislabeled audio files

**Solutions:**

- Increase dataset size (aim for 200+ samples per class)
- Use higher quality audio recordings
- Ensure balanced distribution across all 5 classes
- Verify all audio files are correctly labeled

---

## 📞 Support

For issues or questions:

1. Check this guide thoroughly
2. Review training history for patterns
3. Try with a small test dataset first
4. Contact development team if problems persist

---

## 🔐 Security Considerations

- Only admin users can access retraining features
- All uploads are validated for file type
- Temporary files are automatically cleaned up
- Model backups prevent accidental data loss
- JWT authentication protects all endpoints

---

## 📈 Best Practices

1. **Start Small**: Test with a small dataset first
2. **Validate Quality**: Ensure all audio is correctly labeled
3. **Monitor Metrics**: Compare with previous training results
4. **Backup Data**: Keep copies of your training datasets
5. **Document Changes**: Note why you retrained and what changed
6. **Test Predictions**: After saving, test with known audio samples
7. **Gradual Improvements**: Retrain incrementally with new data

---

**Version**: 1.0  
**Last Updated**: November 6, 2025  
**NeoParental Team** 👶
