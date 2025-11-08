# **NeoParental**

## Project overview

NeoParental is an AI-powered mobile application designed to support new parents in Rwanda, particularly in Kigali, as they navigate early parenthood. The system analyzes and interprets infant cries to help caregivers understand their baby’s needs in real time, reducing stress and improving response to health concerns. It integrates with Community Health Workers to strengthen follow-up and early interventions, contributing to better maternal and child health outcomes.

This project was developed as a BSc. in Software Engineering thesis by Pascal Mugisha, supervised by Mr. Emmanuel, and intended to be completed in November 2025.

#### Important Links to Explore:

- Link to [Figma Design Prototype](https://www.figma.com/proto/VEoDYp7vbH6ahN5du9bKWb/Untitled?node-id=0-1&t=tz9GGUXJTJ9oRpkr-1)
- Link to [GitHub Repository](https://github.com/M-Pascal/NeoParental.git)
- Link to [Demo_video (Final Product)](https://youtu.be/_Ks2d5u4sUA)
  [![YouTube Video _Ks2d5u4sUA](https://utfs.io/f/nGnSqDveMsqxXzMjLs23qxUhHyoDduQT2r7OPjwz5ElgaFKn)](https://www.youtube.com/watch?v=_Ks2d5u4sUA)

## Project Structure

```
Neo_Parental_App/
│
├── back_end/                           # Backend API Server
│   ├── main.py                         # FastAPI application entry point
│   ├── requirements.txt                # Python dependencies
│   ├── test_cloudinary.py             # Cloudinary integration tests
│   ├── database/                       # Database modules
│   │   ├── database.py                # MongoDB connection and queries
│   │   └── requirements.txt           # Database-specific dependencies
│   ├── Model/                          # Machine Learning models
│   │   ├── Capstone_project_[NeoParental].ipynb  # Model training notebook
│   │   └── saved_model/               # Original production model directory
│   │       └── best_model.joblib      # Trained model file (fallback)
│   │   └── admin_saved_model/         # Admin retrained models directory
│   │       └── admin_model_*.joblib   # Timestamped admin models
│   └── temp/                           # Temporary file storage
│
├── admin_dashboard/                    # Admin Web Dashboard
│   ├── main.py                         # Streamlit dashboard application
│   ├── requirements.txt                # Dashboard dependencies
│   └──test_deployment.py             # Model deployment testing script
│
├── neoparent/                          # Flutter Mobile Application
│   ├── lib/                            # Application source code
│   │   ├── main.dart                  # Application entry point
│   │   ├── config/                    # Configuration files
│   │   ├── models/                    # Data models
│   │   ├── providers/                 # State management providers
│   │   ├── Screens/                   # UI screens
│   │   ├── services/                  # API and external services
│   │   ├── utils/                     # Utility functions
│   │   └── widgets/                   # Reusable UI components
│   ├── android/                        # Android-specific configuration
│   ├── ios/                            # iOS-specific configuration
│   ├── assets/                         # Application assets
│   │   └── Pediatrics.json            # Static data
│   ├── pubspec.yaml                   # Flutter dependencies
│   └── test/                           # Widget and unit tests
│
├── Notebook/                           # Jupyter notebooks for analysis
│   └── Capstone_project_[NeoParental].ipynb
│
└── README.md                           # Project documentation
```

## Technology Stack

### Mobile Application (Frontend)

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider pattern
- **HTTP Client**: http package for API communication
- **Secure Storage**: flutter_secure_storage for token management
- **Audio Recording**: audioplayers and audio recording packages
- **File Handling**: file_picker for audio file selection
- **UI Components**: Material Design 3 components
- **Platforms**: Android, iOS, Web (responsive design)

### Backend API Server

- **Framework**: FastAPI (Python 3.9+)
- **API Style**: RESTful API with async/await support
- **Authentication**: JWT (JSON Web Tokens) with OAuth2 password flow
- **Password Hashing**: Argon2 (via passlib) - secure against brute-force attacks
- **Token Management**: python-jose for JWT encoding/decoding
- **CORS**: Configurable Cross-Origin Resource Sharing for Flutter app access

### Database

- **Primary Database**: MongoDB (NoSQL document database)
- **Driver**: motor (async MongoDB driver for Python)
- **Connection**: pymongo for synchronous operations
- **SSL/TLS**: Secure connections via certifi
- **Collections**:
  - users (user authentication and profiles)
  - predictions (audio analysis results)
  - model_deployments (ML model deployment tracking)

### Machine Learning & AI

- **ML Framework**: scikit-learn 1.6.1
- **Model Type**: DecisionTreeClassifier with RandomOverSampler
- **Audio Processing**: librosa 0.11.0 for feature extraction
- **Feature Engineering**:
  - MFCC (Mel-Frequency Cepstral Coefficients) - 40 coefficients
  - Mel Spectrogram - 128 bands
  - Chroma Features - Pitch class profiles
  - Spectral Contrast - 7 bands
  - Tonnetz - Tonal centroid features
- **Class Balancing**: imbalanced-learn 0.12.4 (SMOTE, RandomOverSampler)
- **Model Persistence**: joblib for model serialization
- **Evaluation Metrics**: accuracy, precision, recall, F1-score, ROC-AUC
- **Audio Formats Supported**: WAV, MP3, M4A, FLAC, OGG, AAC

### Cloud Services

- **Cloud Storage**: Cloudinary (audio file storage and CDN)
- **Features**:
  - Automatic file upload and organization
  - Secure URL generation
  - Tag-based categorization
  - Public ID management for retrieval

### Admin Dashboard

- **Framework**: Streamlit 1.39.0
- **Language**: Python
- **Visualization**:
  - Plotly 5.24.1 (interactive charts and graphs)
  - Pandas for data manipulation
- **UI Styling**: Custom CSS with Poppins font and gradient themes
- **HTTP Requests**: requests 2.32.3 for API calls
- **File Operations**: zipfile for bulk audio downloads
- **Features**:
  - Real-time analytics dashboards
  - User management interface
  - Model retraining workflow
  - Deployment control system
  - Audio file bulk download by label

### Development Tools

- **Package Management**:
  - pip (Python)
  - Flutter pub (Dart/Flutter)
- **Version Control**: Git with GitHub
- **API Testing**: FastAPI automatic interactive docs (Swagger UI)
- **Virtual Environment**: venv for Python dependency isolation
- **Code Organization**: Modular architecture with separation of concerns

### Security & Compliance

- **Authentication Flow**: Secure JWT-based authentication
- **Password Policy**: Strong password requirements with Argon2 hashing
- **Token Expiration**: Configurable access token lifetime (default: 60 minutes)
- **Role-Based Access Control (RBAC)**: User and admin roles
- **API Protection**: All sensitive endpoints require authentication
- **Environment Variables**: Sensitive configuration stored in .env files
- **HTTPS Ready**: SSL/TLS support for production deployment

## System Requirements

### For Backend Development

- **Python**: Version 3.9 or higher
- **MongoDB**: Version 4.4 or higher (local or MongoDB Atlas cloud instance)
- **Cloudinary Account**: For audio file storage (free tier available)
- **OpenAI API Key**: For AI-powered features (optional)
- **Operating System**: Windows 10/11, macOS 10.15+, or Linux (Ubuntu 20.04+)
- **RAM**: Minimum 4GB (8GB recommended for model training)
- **Storage**: 2GB free space for dependencies and models

### For Flutter Mobile App Development

- **Flutter SDK**: Version 3.x or higher
- **Dart SDK**: Included with Flutter
- **Android Studio**: For Android development (with Android SDK)
- **Xcode**: For iOS development (macOS only)
- **VS Code or Android Studio**: As IDE
- **Operating System**:
  - Android development: Windows, macOS, or Linux
  - iOS development: macOS only

### For Admin Dashboard

- **Python**: Version 3.9 or higher
- **Web Browser**: Modern browser (Chrome, Firefox, Edge, Safari)
- **Port 8501**: Available for Streamlit dashboard

### Development Tools (Recommended)

- **Git**: Version control system
- **Postman/SwaggUI**: API testing (optional)
- **MongoDB Compass**: Database GUI (optional)

## Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/M-Pascal/NeoParental.git
cd Neo_Parental_App
```

### 2. Backend Setup

```bash
# Navigate to backend directory
cd back_end

# Create and activate virtual environment
python -m venv myenv
# Windows: myenv\Scripts\activate
# macOS/Linux: source myenv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

Configure environment variables by creating a `.env` file:

```env
MONGO_URI=your_mongodb_connection_string
DB_NAME=neoparental_db
JWT_SECRET=your_secure_secret_key
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
```

Run the backend server:

```bash
python main.py
# Server starts at http://localhost:8000
# API docs at http://localhost:8000/docs
```

### 3. Admin Dashboard Setup

```bash
cd ../admin_dashboard

# Create and activate virtual environment
python -m venv venv_admin
# Windows: venv_admin\Scripts\activate
# macOS/Linux: source venv_admin/bin/activate

# Install dependencies and run
pip install -r requirements.txt
streamlit run main.py
# Dashboard opens at http://localhost:8501
```

### 4. Flutter Mobile App Setup

```bash
cd ../neoparent

# Install dependencies
flutter pub get

# Configure API endpoint in lib/config/api_config.dart
# Set: const String apiBaseUrl = 'http://localhost:8000';

# Run the app
flutter run
```

## Usage Guide

### For End Users (Parents/Caregivers)

1. **Register**: Create account with email and phone number
2. **Login**: Access the application with credentials
3. **Record/Upload**: Capture or upload baby cry audio
4. **Analyze**: Submit audio for AI analysis
5. **View Results**: See prediction with confidence score
6. **History**: Access past predictions and patterns

### For Administrators

1. **Login**: Access admin dashboard at http://localhost:8501
2. **Monitor**: View analytics, user activity, and prediction statistics
3. **Manage Users**: View user details and their prediction history
4. **Train Model**: Upload ZIP dataset for model retraining
5. **Deploy Model**: Review metrics and deploy new models
6. **Download Data**: Bulk download audio files organized by labels

### Model Retraining Workflow

The system uses a two-directory architecture for safe model deployment:

- **Saved Model**: `Model/saved_model/best_model.joblib` (fallback model)
- **Admin Models**: `Model/admin_saved_model/admin_model_*.joblib` (retrained models)

Workflow:

1. Prepare dataset as ZIP with folders: Belly_pain, Burping, Discomfort, Hungry, Tired_Sleepy
2. Upload ZIP through admin dashboard
3. Review training metrics (accuracy, precision, recall, F1-score, ROC-AUC)
4. Save and deploy model to production
5. Monitor deployment status and performance

## Troubleshooting

**Backend Issues:**

- MongoDB connection errors: Verify connection string and database availability
- Port conflicts: Change port in main.py or kill conflicting process
- Missing modules: Activate virtual environment and reinstall requirements

**Dashboard Issues:**

- Authentication errors: Ensure backend is running at http://localhost:8000
- File upload failures: Check file size limits and supported formats

**Flutter App Issues:**

- API connection errors: Update API base URL in configuration
- Build errors: Run `flutter clean` then `flutter pub get`

## Security & Performance

**Security Best Practices:**

- Never commit `.env` files to version control
- Use strong JWT secrets (minimum 32 characters)
- Implement HTTPS in production
- Validate and sanitize all file uploads
- Enable rate limiting on API endpoints

**Performance Optimization:**

- Use async/await for database operations
- Implement connection pooling for MongoDB
- Enable feature caching for repeated predictions
- Use batch processing for multiple audio files

## Deployment

**Backend (Production):**

1. Set up production MongoDB instance (MongoDB Atlas recommended)
2. Configure production environment variables
3. Use uvicorn with workers for production server
4. Enable HTTPS with SSL certificates
5. Set up reverse proxy (Nginx/Apache)

**Flutter App:**

- Android: `flutter build apk --release` or `flutter build appbundle --release`
- iOS: `flutter build ios --release` (requires Xcode for App Store)
- Web: `flutter build web --release`

## Contributing

Contributions are welcome! Follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Make changes following code style guidelines (PEP 8 for Python, Dart style guide for Flutter)
4. Test thoroughly
5. Commit with descriptive messages
6. Submit a Pull Request with detailed description

## License

This project is developed as an academic thesis for BSc. in Software Engineering. All rights reserved by Pascal Mugisha.

## Contact & Support

- **Developer**: Pascal Mugisha
- **GitHub**: [M-Pascal](https://github.com/M-Pascal)
- **Issues**: Report bugs via GitHub Issues

## Acknowledgements

- **Emmanuel Annor** - Project Supervisor
- **ALU (African Leadership University)** - Educational Institution
- **Open Source Community** - Libraries and frameworks
