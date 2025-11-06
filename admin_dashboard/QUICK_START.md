# 🚀 Quick Start Guide - Model Retraining Feature

## ✅ What's Been Implemented

Your admin dashboard now has a **complete model retraining system**! Here's what you can do:

1. **Upload training datasets** (ZIP files with labeled audio)
2. **Train new models** with automatic feature extraction
3. **Review comprehensive metrics** (Accuracy, Precision, Recall, F1, ROC-AUC)
4. **Save or discard** trained models before deployment
5. **Track training history** with all past sessions
6. **Automatic backups** of previous models

---

## 📦 Installation

### Step 1: Install Backend Dependencies

```bash
cd back_end
pip install imbalanced-learn==0.12.4
```

### Step 2: Install Dashboard Dependencies

```bash
cd admin_dashboard
pip install streamlit==1.39.0 requests==2.32.3 plotly==5.24.1
```

Or install all at once:

```bash
# Backend
cd back_end
pip install -r requirements.txt

# Dashboard
cd admin_dashboard
pip install -r requirements.txt
```

---

## 🎯 How to Use (In 5 Minutes!)

### 1. Start the Backend

```bash
cd back_end
# Activate virtual environment
source myenv/Scripts/activate  # Windows: myenv\Scripts\activate

# Run the server
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Start the Dashboard

```bash
cd admin_dashboard
streamlit run main.py
```

### 3. Access & Login

- Open browser: `http://localhost:8501`
- Login with admin credentials

### 4. Navigate to Retraining

- Click **"🧠 Retrain Model"** in sidebar

### 5. Prepare Your Dataset

Create this structure:

```
my_training_data/
├── Belly_pain/
│   └── [audio files].wav
├── Burping/
│   └── [audio files].wav
├── Discomfort/
│   └── [audio files].wav
├── Hungry/
│   └── [audio files].wav
└── Tired_Sleepy/
    └── [audio files].wav
```

Then ZIP it!

### 6. Upload & Train

1. Upload the ZIP file
2. Click **"🚀 Start Training"**
3. Wait for results (2-10 minutes)

### 7. Review & Decide

After training, you'll see:

- 🎯 **Accuracy**: 92.5%
- 📊 **Precision**: 91.8%
- 🔍 **Recall**: 92.1%
- ⚖️ **F1 Score**: 91.9%
- 📈 **ROC-AUC**: 0.965

**Good metrics?**

- Click **"✅ Save Model"** to deploy
- Your new model is now live! 🎉

**Need to improve?**

- Click **"🗑️ Discard Model"**
- Try again with more/better data

---

## 🎨 UI Features

### Main Dashboard

- Clean, modern design matching NeoParental theme
- Orange/white color scheme
- Responsive layout

### Retraining Page Includes:

- ✅ Clear instructions with visual guides
- ✅ File upload with drag & drop
- ✅ Real-time progress indicators
- ✅ Beautiful metric cards
- ✅ Color-coded interpretation guide
- ✅ Training history table
- ✅ CSV export functionality

---

## 📊 Understanding Metrics

| Metric        | What It Means                         | Good Value |
| ------------- | ------------------------------------- | ---------- |
| **Accuracy**  | % of correct predictions              | > 85%      |
| **Precision** | When model says X, how often correct? | > 85%      |
| **Recall**    | Of all X cries, how many found?       | > 85%      |
| **F1 Score**  | Balance of precision & recall         | > 85%      |
| **ROC-AUC**   | Overall classification quality        | > 0.90     |

---

## 🔧 API Endpoints

### Train Model

```bash
POST http://localhost:8000/admin/retrain
Headers: Authorization: Bearer <your_token>
Body: multipart/form-data with ZIP file
```

### Save Model

```bash
POST http://localhost:8000/admin/save_model
Headers: Authorization: Bearer <your_token>
```

---

## 🛡️ Security Features

✅ Admin-only access (JWT authentication)  
✅ File type validation  
✅ Automatic cleanup of temporary files  
✅ Model backups before replacement  
✅ Role-based access control

---

## 💡 Pro Tips

1. **Start with 200+ samples per class** for best results
2. **Use high-quality audio** (clear recordings, minimal noise)
3. **Balance your dataset** (similar number of samples per class)
4. **Test incrementally** - start small, then scale up
5. **Save training history** - download CSV for your records
6. **Review before saving** - check all metrics carefully

---

## 🐛 Common Issues & Solutions

### "No folders found in ZIP"

✅ **Fix**: Ensure ZIP contains a folder with 5 subfolders (one per label)

### "No valid audio files found"

✅ **Fix**: Use WAV, MP3, or FLAC files

### "Request timeout"

✅ **Fix**: Dataset too large, try smaller batch first

### "Admin access required"

✅ **Fix**: Login with admin account

### Low accuracy (< 70%)

✅ **Fix**:

- Add more training samples
- Improve audio quality
- Check for mislabeled files
- Ensure balanced distribution

---

## 📚 Documentation

Detailed guides available:

- **RETRAINING_GUIDE.md** - Complete user manual
- **IMPLEMENTATION_SUMMARY.md** - Technical details

---

## ✨ Example Workflow

```
1. Collect 250 baby cry recordings
   ↓
2. Organize into 5 labeled folders
   ↓
3. Create ZIP file
   ↓
4. Upload to admin dashboard
   ↓
5. Start training
   ↓
6. Review metrics:
   - Accuracy: 91.2% ✅
   - F1 Score: 90.8% ✅
   ↓
7. Save model
   ↓
8. Model deployed automatically!
   ↓
9. Test with real predictions
```

---

## 🎉 You're All Set!

Your model retraining feature is **ready to use**! The integration is complete with:

✅ Full backend API implementation  
✅ Beautiful Streamlit dashboard  
✅ Comprehensive evaluation metrics  
✅ Safe model management  
✅ Training history tracking  
✅ Automatic backups

### Need Help?

1. Check `RETRAINING_GUIDE.md` for detailed instructions
2. Review `IMPLEMENTATION_SUMMARY.md` for technical details
3. Test with a small dataset first

---

**Happy Training! 🧠👶**

_NeoParental Development Team_  
_November 6, 2025_
