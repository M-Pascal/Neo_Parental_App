import streamlit as st
import requests
import pandas as pd
from datetime import datetime
import plotly.express as px
import plotly.graph_objects as go
from typing import Dict, List
import base64
from pathlib import Path
import zipfile
import io
import tempfile
from urllib.request import urlopen

# Configuration
API_BASE_URL = "http://localhost:8000"  # Our FastAPI URL

# Helper function to load and encode images
def get_icon_html(icon_name: str, size: int = 20, color: str = None) -> str:
    """
    Load a custom icon and return HTML to display it.
    Place your icon files in: admin_dashboard/assets/icons/
    Supported formats: PNG, SVG
    
    Args:
        icon_name: Name of the icon file (e.g., 'lock.png', 'chart.svg')
        size: Size of the icon in pixels
        color: Optional color (works with SVG icons)
    
    Returns:
        HTML string to display the icon
    """
    icon_path = Path(__file__).parent / "assets" / "icons" / icon_name
    
    if not icon_path.exists():
        # Fallback: return empty string if icon not found
        return ""
    
    try:
        if icon_name.endswith('.svg'):
            # For SVG files, read and inject directly
            with open(icon_path, 'r', encoding='utf-8') as f:
                svg_content = f.read()
                # Properly handle SVG attributes
                # Remove any existing style attributes first
                import re
                svg_content = re.sub(r'<svg[^>]*>', '<svg>', svg_content)
                
                # Build style string
                style = f'width:{size}px;height:{size}px;vertical-align:middle;display:inline-block;'
                
                # Apply color if specified
                if color:
                    # Replace fill attribute or add it
                    if 'fill=' in svg_content:
                        svg_content = re.sub(r'fill="[^"]*"', f'fill="{color}"', svg_content)
                    else:
                        svg_content = svg_content.replace('<path', f'<path fill="{color}"')
                
                # Add style to SVG tag
                svg_content = svg_content.replace('<svg>', f'<svg style="{style}">')
                
                return svg_content
        else:
            # For PNG/JPG files, encode as base64
            with open(icon_path, 'rb') as f:
                data = base64.b64encode(f.read()).decode()
                ext = icon_path.suffix[1:]
                return f'<img src="data:image/{ext};base64,{data}" style="width:{size}px;height:{size}px;vertical-align:middle;display:inline-block;" />'
    except Exception as e:
        return ""

# Page configuration
st.set_page_config(
    page_title="NeoParental Admin Dashboard",
    page_icon="👶",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS - Matching Flutter app design
st.markdown("""
    <style>
    /* Import Google Fonts */
    @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700&display=swap');
    
    /* Global Font */
    html, body, [class*="css"] {
        font-family: 'Poppins', sans-serif;
    }
    
    /* Main background with subtle gradient */
    .main {
        background: linear-gradient(135deg, #ffffff 0%, #fff5f0 100%);
    }
    
    /* Metric styling */
    [data-testid="stMetricValue"] {
        font-size: 36px;
        color: #D64612;
        font-weight: 700;
    }
    
    [data-testid="stMetricLabel"] {
        font-size: 14px;
        color: #666666;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    [data-testid="stMetricDelta"] {
        font-size: 14px;
    }
    
    /* Card backgrounds with gradient border */
    div[data-testid="metric-container"] {
        background: linear-gradient(white, white) padding-box,
                    linear-gradient(135deg, #FF6B35, #D2691E) border-box;
        border: 2px solid transparent;
        padding: 24px;
        border-radius: 15px;
        box-shadow: 0 4px 6px rgba(214, 70, 18, 0.1);
        transition: transform 0.2s ease;
    }
    
    div[data-testid="metric-container"]:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(214, 70, 18, 0.15);
    }
    
    /* Header styling */
    h1 {
        color: #D64612;
        font-weight: 700;
        font-size: 48px !important;
        margin-bottom: 10px !important;
        background: linear-gradient(135deg, #D64612, #FB8239);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        background-clip: text;
    }
    
    h2 {
        color: #D64612;
        font-weight: 600;
        font-size: 28px !important;
        margin-top: 2.5rem !important;
        margin-bottom: 1.5rem !important;
        padding-bottom: 10px;
        border-bottom: 3px solid #FF6B35;
        display: inline-block;
    }
    
    h3 {
        color: #FB8239;
        font-weight: 600;
        font-size: 22px !important;
    }
    
    /* Table styling */
    [data-testid="stDataFrame"] {
        border: 2px solid #FFE5DC;
        border-radius: 15px;
        overflow: hidden;
    }
    
    [data-testid="stDataFrame"] tbody tr:hover {
        background-color: #FFF5F0 !important;
    }
    
    /* Sidebar styling with gradient */
    [data-testid="stSidebar"] {
        background: linear-gradient(180deg, #D64612 0%, #FB8239 100%);
        padding-top: 2rem;
    }
    
    [data-testid="stSidebar"] > div:first-child {
        background: linear-gradient(180deg, #D64612 0%, #FB8239 100%);
    }
    
    [data-testid="stSidebar"] h1, 
    [data-testid="stSidebar"] h2, 
    [data-testid="stSidebar"] h3,
    [data-testid="stSidebar"] p,
    [data-testid="stSidebar"] label,
    [data-testid="stSidebar"] .stMarkdown {
        color: white !important;
    }
    
    /* Sidebar divider */
    [data-testid="stSidebar"] hr {
        border-color: rgba(255, 255, 255, 0.3);
        margin: 20px 0;
    }
    
    /* Info box in sidebar */
    [data-testid="stSidebar"] .element-container div[data-testid="stMarkdownContainer"] p {
        background-color: rgba(255, 255, 255, 0.2);
        padding: 12px;
        border-radius: 10px;
        border-left: 4px solid white;
    }
    
    /* Button styling - Primary */
    .stButton > button {
        background: linear-gradient(135deg, #D64612, #FB8239);
        color: white;
        border: none;
        border-radius: 15px;
        padding: 12px 24px;
        font-weight: 600;
        font-size: 16px;
        box-shadow: 0 4px 6px rgba(214, 70, 18, 0.3);
        transition: all 0.3s ease;
        width: 100%;
    }
    
    .stButton > button:hover {
        background: linear-gradient(135deg, #FB8239, #D64612);
        box-shadow: 0 6px 12px rgba(214, 70, 18, 0.4);
        transform: translateY(-2px);
    }
    
    .stButton > button:active {
        transform: translateY(0);
    }
    
    /* Download button styling */
    .stDownloadButton > button {
        background: linear-gradient(135deg, #4CAF50, #45a049);
        color: white;
        border: none;
        border-radius: 15px;
        padding: 12px 24px;
        font-weight: 600;
        box-shadow: 0 4px 6px rgba(76, 175, 80, 0.3);
    }
    
    .stDownloadButton > button:hover {
        background: linear-gradient(135deg, #45a049, #4CAF50);
        box-shadow: 0 6px 12px rgba(76, 175, 80, 0.4);
    }
    
    /* Input fields */
    .stTextInput > div > div > input,
    .stNumberInput > div > div > input {
        border-radius: 15px;
        border: 2px solid #FFE5DC;
        padding: 12px;
        font-size: 14px;
    }
    
    .stTextInput > div > div > input:focus,
    .stNumberInput > div > div > input:focus {
        border-color: #D64612;
        box-shadow: 0 0 0 2px rgba(214, 70, 18, 0.1);
    }
    
    /* Input field labels */
    .stTextInput label,
    .stNumberInput label {
        color: #333333 !important;
        font-weight: 500 !important;
        font-size: 14px !important;
    }
    
    /* Form styling for login */
    .stForm {
        background: white;
        padding: 40px;
        border-radius: 20px;
        box-shadow: 0 8px 24px rgba(214, 70, 18, 0.15);
        border: 2px solid #FFE5DC;
    }
    
    /* Spinner */
    .stSpinner > div {
        border-top-color: #D64612 !important;
    }
    
    /* Success message */
    .stSuccess {
        background-color: #E8F5E9;
        color: #2E7D32;
        border-left: 4px solid #4CAF50;
        border-radius: 10px;
        padding: 12px;
    }
    
    /* Error message */
    .stError {
        background-color: #FFEBEE;
        color: #C62828;
        border-left: 4px solid #F44336;
        border-radius: 10px;
        padding: 12px;
    }
    
    /* Info message */
    .stInfo {
        background-color: #FFF5F0;
        color: #D64612;
        border-left: 4px solid #FB8239;
        border-radius: 10px;
        padding: 12px;
    }
    
    /* Plotly charts */
    .js-plotly-plot {
        border-radius: 15px;
        overflow: hidden;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    
    /* Tab styling */
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
    }
    
    .stTabs [data-baseweb="tab"] {
        border-radius: 10px 10px 0 0;
        padding: 12px 24px;
        background-color: white;
        border: 2px solid #FFE5DC;
        border-bottom: none;
    }
    
    .stTabs [aria-selected="true"] {
        background: linear-gradient(135deg, #D64612, #FB8239);
        color: white;
        border-color: #D64612;
    }
    
    /* Expander */
    .streamlit-expanderHeader {
        background-color: #FFF5F0;
        border-radius: 10px;
        border: 2px solid #FFE5DC;
        font-weight: 600;
        color: #D64612;
    }
    
    .streamlit-expanderHeader:hover {
        background-color: #FFE5DC;
    }
    </style>
""", unsafe_allow_html=True)

# Authentication state
if 'token' not in st.session_state:
    st.session_state.token = None
if 'user' not in st.session_state:
    st.session_state.user = None
if 'current_page' not in st.session_state:
    st.session_state.current_page = 'dashboard'
if 'training_history' not in st.session_state:
    st.session_state.training_history = []

def login(username: str, password: str) -> bool:
    """Authenticate user and get access token"""
    try:
        # OAuth2PasswordRequestForm expects form data, not JSON
        response = requests.post(
            f"{API_BASE_URL}/login",
            data={
                "username": username,
                "password": password,
                "grant_type": "password"  # Required for OAuth2
            },
            headers={"Content-Type": "application/x-www-form-urlencoded"}
        )
        
        if response.status_code == 200:
            data = response.json()
            st.session_state.token = data["access_token"]
            
            # Get user info
            headers = {"Authorization": f"Bearer {st.session_state.token}"}
            user_response = requests.get(f"{API_BASE_URL}/users/me", headers=headers)
            if user_response.status_code == 200:
                st.session_state.user = user_response.json()
                return True
            else:
                st.error(f"Failed to get user info: {user_response.status_code}")
                return False
        else:
            st.error(f"Login failed: {response.status_code} - {response.text}")
            return False
    except Exception as e:
        st.error(f"Login error: {e}")
        import traceback
        st.error(traceback.format_exc())
        return False

def get_headers():
    """Get authorization headers"""
    return {"Authorization": f"Bearer {st.session_state.token}"}

def fetch_all_predictions() -> List[Dict]:
    """Fetch all predictions from the API"""
    try:
        response = requests.get(
            f"{API_BASE_URL}/admin/predictions",
            headers=get_headers()
        )
        if response.status_code == 200:
            return response.json()
        return []
    except Exception as e:
        st.error(f"Error fetching predictions: {e}")
        return []

def fetch_all_users() -> List[Dict]:
    """Fetch all users from the API"""
    try:
        response = requests.get(
            f"{API_BASE_URL}/admin/users",
            headers=get_headers()
        )
        if response.status_code == 200:
            return response.json()
        return []
    except Exception as e:
        st.error(f"Error fetching users: {e}")
        return []

def fetch_user_predictions(user_id: str) -> List[Dict]:
    """Fetch predictions for a specific user"""
    try:
        response = requests.get(
            f"{API_BASE_URL}/admin/users/{user_id}/predictions",
            headers=get_headers()
        )
        if response.status_code == 200:
            return response.json()
        return []
    except Exception as e:
        st.error(f"Error fetching user predictions: {e}")
        return []

def calculate_metrics(predictions: List[Dict]) -> Dict:
    """Calculate various metrics from predictions"""
    if not predictions:
        return {
            "total_audio": 0,
            "by_label": {},
            "avg_confidence": 0
        }
    
    df = pd.DataFrame(predictions)
    
    # Count by label
    label_counts = df['predicted_label'].value_counts().to_dict()
    
    # Average confidence
    avg_confidence = df['confidence'].mean() if 'confidence' in df.columns else 0
    
    return {
        "total_audio": len(predictions),
        "by_label": label_counts,
        "avg_confidence": avg_confidence
    }

def create_user_summary(users: List[Dict], predictions: List[Dict]) -> pd.DataFrame:
    """Create a summary DataFrame with user info and prediction counts by label"""
    if not users:
        return pd.DataFrame()
    
    # Create predictions DataFrame
    pred_df = pd.DataFrame(predictions) if predictions else pd.DataFrame()
    
    user_data = []
    labels = ["Belly_pain", "Burping", "Discomfort", "Hungry", "Tired/Sleepy"]
    
    for user in users:
        user_id = user['id']
        
        # Get predictions for this user
        user_preds = pred_df[pred_df['user_id'] == user_id] if not pred_df.empty else pd.DataFrame()
        
        # Count by label
        label_counts = {}
        for label in labels:
            label_counts[label] = len(user_preds[user_preds['predicted_label'] == label]) if not user_preds.empty else 0
        
        user_data.append({
            'User ID': user_id,
            'Name': f"{user['first_name']} {user['last_name']}",
            'Phone': user['telephone'],
            'Email': user['email'],
            'Total Audio': len(user_preds),
            'Belly Pain': label_counts['Belly_pain'],
            'Burping': label_counts['Burping'],
            'Discomfort': label_counts['Discomfort'],
            'Hungry': label_counts['Hungry'],
            'Tired/Sleepy': label_counts['Tired/Sleepy']
        })
    
    return pd.DataFrame(user_data)

def retrain_model(zip_file) -> Dict:
    """
    Call the backend API to retrain the model with uploaded dataset
    API endpoint: POST /admin/retrain
    """
    try:
        # Reset file pointer to beginning
        zip_file.seek(0)
        
        # Prepare the file for upload
        files = {
            'file': (zip_file.name, zip_file.getvalue(), 'application/zip')
        }
        
        # Get headers with authentication token
        headers = get_headers()
        
        # Call the API endpoint
        response = requests.post(
            f"{API_BASE_URL}/admin/retrain",
            files=files,
            headers=headers,
            timeout=600  # 10 minutes timeout for training
        )
        
        if response.status_code == 200:
            result = response.json()
            
            # Add timestamp if not present
            if 'timestamp' not in result:
                result['timestamp'] = datetime.now().isoformat()
            
            return {
                "status": "success",
                "message": result.get("status", "Model retrained successfully"),
                "metrics": {
                    "accuracy": result.get("accuracy", 0),
                    "precision": result.get("precision", 0),
                    "recall": result.get("recall", 0),
                    "f1_score": result.get("f1_score", 0),
                    "roc_auc": result.get("roc_auc", "N/A")
                },
                "timestamp": result.get('timestamp', datetime.now().isoformat())
            }
        else:
            return {
                "status": "error",
                "message": f"API error: {response.status_code} - {response.text}"
            }
            
    except requests.exceptions.Timeout:
        return {
            "status": "error",
            "message": "Request timeout. Training took too long. Please try with a smaller dataset."
        }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Error during retraining: {str(e)}"
        }

def save_trained_model() -> Dict:
    """
    Call the backend API to save the trained model
    API endpoint: POST /admin/save_model
    """
    try:
        response = requests.post(
            f"{API_BASE_URL}/admin/save_model",
            headers=get_headers(),
            timeout=30
        )
        
        if response.status_code == 200:
            return {"status": "success", "message": "Model saved successfully"}
        else:
            return {"status": "error", "message": f"Failed to save model: {response.text}"}
    except Exception as e:
        return {"status": "error", "message": f"Error saving model: {str(e)}"}

def deploy_model() -> Dict:
    """
    Call the backend API to deploy the saved model
    API endpoint: POST /admin/deploy_model
    """
    try:
        response = requests.post(
            f"{API_BASE_URL}/admin/deploy_model",
            headers=get_headers(),
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            return {
                "status": "success",
                "message": result.get("message", "Model deployed successfully"),
                "deployment_status": result.get("deployment_status", "on")
            }
        else:
            return {"status": "error", "message": f"Failed to deploy model: {response.text}"}
    except Exception as e:
        return {"status": "error", "message": f"Error deploying model: {str(e)}"}

def get_deployment_status() -> Dict:
    """
    Call the backend API to get deployment status
    API endpoint: GET /admin/deployment_status
    """
    try:
        response = requests.get(
            f"{API_BASE_URL}/admin/deployment_status",
            headers=get_headers(),
            timeout=30
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            return {
                "deployment_status": "unknown",
                "error": f"Failed to get status: {response.text}"
            }
    except Exception as e:
        return {
            "deployment_status": "unknown",
            "error": f"Error getting status: {str(e)}"
        }

def deactivate_model() -> Dict:
    """
    Call the backend API to deactivate the deployed model
    API endpoint: POST /admin/deactivate_model
    """
    try:
        response = requests.post(
            f"{API_BASE_URL}/admin/deactivate_model",
            headers=get_headers(),
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            return {
                "status": "success",
                "message": result.get("message", "Model deactivated successfully"),
                "deployment_status": result.get("deployment_status", "off")
            }
        else:
            return {"status": "error", "message": f"Failed to deactivate model: {response.text}"}
    except Exception as e:
        return {"status": "error", "message": f"Error deactivating model: {str(e)}"}

def download_audio_files_by_label(predictions_data: List[Dict]) -> bytes:
    """
    Download all audio files from Cloudinary URLs and organize them by label in a ZIP file.
    
    Args:
        predictions_data: List of prediction dictionaries containing audio_url and predicted_label
    
    Returns:
        Bytes of the ZIP file
    """
    # Create a BytesIO object to store the ZIP file in memory
    zip_buffer = io.BytesIO()
    
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        # Group predictions by label
        label_groups = {}
        for pred in predictions_data:
            label = pred.get('predicted_label', 'Unknown')
            if label not in label_groups:
                label_groups[label] = []
            label_groups[label].append(pred)
        
        # Process each label group
        for label, predictions in label_groups.items():
            # Sanitize label for folder name
            folder_name = label.replace('/', '_').replace('\\', '_')
            
            for idx, pred in enumerate(predictions, 1):
                audio_url = pred.get('audio_url')
                original_filename = pred.get('audio_filename', f'audio_{idx}')
                
                if not audio_url:
                    continue
                
                try:
                    # Download the audio file from Cloudinary
                    response = requests.get(audio_url, timeout=30)
                    
                    if response.status_code == 200:
                        # Get file extension from original filename
                        file_ext = Path(original_filename).suffix or '.wav'
                        
                        # Create unique filename: username_timestamp_original
                        username = pred.get('username', 'user')
                        timestamp = pred.get('created_at', '')
                        if timestamp:
                            timestamp_str = pd.to_datetime(timestamp).strftime('%Y%m%d_%H%M%S')
                        else:
                            timestamp_str = f'{idx:04d}'
                        
                        new_filename = f"{username}_{timestamp_str}_{original_filename}"
                        
                        # Add to ZIP under label folder
                        file_path_in_zip = f"Audio/{folder_name}/{new_filename}"
                        zip_file.writestr(file_path_in_zip, response.content)
                        
                except Exception as e:
                    # Log error but continue with other files
                    print(f"Error downloading {audio_url}: {e}")
                    continue
    
    # Get the ZIP file bytes
    zip_buffer.seek(0)
    return zip_buffer.getvalue()

# Login page
if not st.session_state.token:
    # Create centered layout with background
    st.markdown("""
        <div style="text-align: center; padding: 20px 0;">
            <h1 style="font-size: 64px; margin-bottom: 10px;">👶</h1>
            <h1 style="font-size: 42px; margin-bottom: 5px;">NeoParental</h1>
            <p style="color: #FB8239; font-size: 18px; font-weight: 600;">Admin Dashboard</p>
        </div>
    """, unsafe_allow_html=True)
    
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        with st.form("login_form"):
            lock_icon = get_icon_html("lock.svg", size=24, color="#D64612")
            st.markdown(f"<h3 style='text-align: center; color: #D64612; margin-bottom: 20px;'>{lock_icon} Admin Login</h3>", unsafe_allow_html=True)
            
            username = st.text_input("Username or Email", placeholder="Enter your username or email")
            password = st.text_input("Password", type="password", placeholder="Enter your password")
            
            st.markdown("<br>", unsafe_allow_html=True)
            submit = st.form_submit_button("↪ Login", use_container_width=True)
            
            if submit:
                with st.spinner("Authenticating..."):
                    if login(username, password):
                        # Check if user is admin
                        if st.session_state.user.get('role') == 'admin':
                            st.success("Login successful! Redirecting...")
                            st.rerun()
                        else:
                            st.error("Admin access required")
                            st.session_state.token = None
                            st.session_state.user = None
                    else:
                        st.error("Invalid credentials. Please try again.")
        
        st.markdown("""
            <div style="text-align: center; margin-top: 30px; padding: 20px; background-color: #FFF5F0; border-radius: 15px; border: 2px solid #FFE5DC;">
                <p style="color: #666; font-size: 14px; margin: 0;">
                    <strong>Note:</strong> This dashboard is restricted to authorized administrators only.
                </p>
            </div>
        """, unsafe_allow_html=True)
    
    st.stop()

# Main Dashboard
st.markdown("""
    <div style="text-align: center; margin-bottom: 20px;">
        <h1><span style="color: inherit; -webkit-text-fill-color: initial;">👶</span> NeoParental Admin Dashboard</h1>
        <p style="color: #FB8239; font-size: 18px; font-weight: 500;">Complete Analytics & User Management</p>
    </div>
""", unsafe_allow_html=True)

# Sidebar
with st.sidebar:
    st.markdown("""
        <div style="text-align: center; padding: 20px 0; margin-bottom: 20px;">
            <div style="font-size: 64px; margin-bottom: 10px;">👶</div>
            <h2 style="color: white; font-size: 24px; margin: 0;">NeoParental</h2>
            <p style="color: rgba(255,255,255,0.9); font-size: 14px; margin-top: 5px;">Admin Control Panel</p>
        </div>
    """, unsafe_allow_html=True)
    
    st.markdown("---")
    
    # User info card
    st.markdown(f"""
        <div style="background-color: rgba(255,255,255,0.15); padding: 15px; border-radius: 10px; margin-bottom: 20px;">
            <div style="font-size: 34px; text-align: center; margin-bottom: 10px;">👤</div>
            <p style="color: white; font-weight: 600; text-align: center; margin: 5px 0; font-size: 16px;">
                {st.session_state.user['username']}
            </p>
            <p style="color: rgba(255,255,255,0.9); text-align: center; margin: 0; font-size: 14px;">
                🛡️ {st.session_state.user['role'].upper()}
            </p>
        </div>
    """, unsafe_allow_html=True)
    
    st.markdown("---")
    
    # Quick actions
    st.markdown("<h3 style='color: white; font-size: 18px; margin-bottom: 15px;'>⚡ Quick Actions</h3>", unsafe_allow_html=True)
    
    if st.button("⟲ Refresh Data", use_container_width=True):
        st.rerun()
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Navigate to retrain page
    if st.button("Retrain Model", use_container_width=True):
        st.session_state.current_page = 'retrain'
        st.rerun()
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    if st.button("↩︎ Logout", use_container_width=True):
        st.session_state.token = None
        st.session_state.user = None
        st.rerun()
    
    st.markdown("---")
    
    # Stats summary in sidebar - use icon in markdown
    chart_icon = get_icon_html("chart.svg", size=18, color="white")
    st.markdown(f"<h3 style='color: white; font-size: 18px; margin-bottom: 15px;'>{chart_icon} Quick Stats</h3>", unsafe_allow_html=True)
    
    # We'll update this after fetching data
    if 'sidebar_stats' in st.session_state:
        stats = st.session_state.sidebar_stats
        st.markdown(f"""
            <div style="background-color: rgba(255,255,255,0.15); padding: 15px; border-radius: 10px;">
                <p style="color: white; margin: 5px 0;">
                    <strong>Total Users:</strong> {stats.get('users', 0)}
                </p>
                <p style="color: white; margin: 5px 0;">
                    <strong>Total Audio:</strong> {stats.get('audio', 0)}
                </p>
                <p style="color: white; margin: 5px 0;">
                    <strong>Avg Confidence:</strong> {stats.get('confidence', 0):.1f}%
                </p>
            </div>
        """, unsafe_allow_html=True)

# =======================
# RETRAIN MODEL PAGE
# =======================
if st.session_state.current_page == 'retrain':
    st.markdown("""
        <div style="text-align: center; margin-bottom: 20px;">
            <h1>Model Retraining</h1>
            <p style="color: #FB8239; font-size: 18px; font-weight: 500;">Train a new model with custom dataset</p>
        </div>
    """, unsafe_allow_html=True)
    
    # Back button
    col1, col2, col3 = st.columns([1, 2, 1])
    with col1:
        if st.button("← Back to Dashboard", use_container_width=True):
            st.session_state.current_page = 'dashboard'
            st.rerun()
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Instructions
    st.markdown("""
        <div style="background: linear-gradient(135deg, #FFF5F0, #FFE5DC); padding: 20px; border-radius: 15px; border: 2px solid #FFE5DC; margin-bottom: 30px;">
            <h3 style="color: #D64612; margin-top: 0;">📋 Instructions:</h3>
            <ol style="color: #666; line-height: 1.8;">
                <li>Prepare your training data as a <strong>ZIP file</strong></li>
                <li>The ZIP should contain audio files organized in folders by label:
                    <ul>
                        <li>/Belly_pain/</li>
                        <li>/Burping/</li>
                        <li>/Discomfort/</li>
                        <li>/Hungry/</li>
                        <li>/Tired_Sleepy/</li>
                    </ul>
                </li>
                <li>Each folder should contain WAV audio files for that category</li>
                <li>Upload the ZIP file below to start training</li>
                <li>Training may take several minutes depending on dataset size</li>
            </ol>
        </div>
    """, unsafe_allow_html=True)
    
    # File upload section
    st.markdown("<h2>Upload Training Data</h2>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    
    uploaded_file = st.file_uploader(
        "Choose a ZIP file containing training data",
        type=['zip'],
        help="Upload a ZIP file with audio files organized by label folders"
    )
    
    if uploaded_file is not None:
        # Display file info
        file_size_mb = uploaded_file.size / (1024 * 1024)
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("_File_Name", uploaded_file.name)
        with col2:
            st.metric("_File_Size", f"{file_size_mb:.2f} MB")
        with col3:
            st.metric("_File_Type", uploaded_file.type)

        st.markdown("<br>", unsafe_allow_html=True)
        
        # Start training button
        if st.button("Start Training", use_container_width=False, type="primary"):
            # Reset file pointer to beginning
            uploaded_file.seek(0)
            
            with st.spinner("Training model...  This may take several minutes..."):
                # Call the retrain function
                result = retrain_model(uploaded_file)
                
                if result["status"] == "success":
                    st.success(f" {result['message']}")
                    
                    # Store in session state for review
                    st.session_state.last_training_result = result
                    
                    # Display metrics
                    st.markdown("<br><h2> Model Evaluation Metrics</h2>", unsafe_allow_html=True)
                    st.markdown("<br>", unsafe_allow_html=True)
                    
                    # Main metrics
                    metric_col1, metric_col2, metric_col3, metric_col4, metric_col5 = st.columns(5)
                    
                    # Note: st.metric() doesn't support HTML, so we use emojis for now
                    with metric_col1:
                        st.metric(
                            label=" Accuracy",
                            value=f"{result['metrics']['accuracy']:.1%}"
                        )
                    
                    with metric_col2:
                        st.metric(
                            label=" Precision",
                            value=f"{result['metrics']['precision']:.1%}"
                        )
                    
                    with metric_col3:
                        st.metric(
                            label=" Recall",
                            value=f"{result['metrics']['recall']:.1%}"
                        )
                    
                    with metric_col4:
                        st.metric(
                            label=" F1 Score",
                            value=f"{result['metrics']['f1_score']:.1%}"
                        )
                    
                    with metric_col5:
                        roc_auc = result['metrics'].get('roc_auc', 'N/A')
                        st.metric(
                            label=" ROC-AUC",
                            value=f"{roc_auc:.3f}" if isinstance(roc_auc, (int, float)) else roc_auc
                        )
                    
                    st.markdown("<br><br>", unsafe_allow_html=True)
                    
                    # Metrics interpretation
                    st.markdown("""
                        <div style="background: linear-gradient(135deg, #E8F5E9, #C8E6C9); padding: 20px; border-radius: 15px; border-left: 5px solid #4CAF50; margin-bottom: 20px;">
                            <h4 style="color: #2E7D32; margin-top: 0;"> Metrics Interpretation</h4>
                            <ul style="color: #1B5E20; line-height: 1.8; margin-bottom: 0;">
                                <li><strong>Accuracy:</strong> Overall correctness of predictions</li>
                                <li><strong>Precision:</strong> How many predicted labels were correct</li>
                                <li><strong>Recall:</strong> How many actual labels were found</li>
                                <li><strong>F1 Score:</strong> Harmonic mean of precision and recall</li>
                                <li><strong>ROC-AUC:</strong> Area under the ROC curve (multi-class)</li>
                            </ul>
                        </div>
                    """, unsafe_allow_html=True)
                    
                    st.markdown("<br>", unsafe_allow_html=True)
                    
                    # Model decision section
                    st.markdown("<h2> Model Management</h2>", unsafe_allow_html=True)
                    st.markdown("<p style='color: #666; font-size: 16px;'>Review the metrics above and decide whether to save or discard this model</p>", unsafe_allow_html=True)
                    st.markdown("<br>", unsafe_allow_html=True)
                    
                    col1, col2, col3 = st.columns([1, 1, 1])
                    
                    with col1:
                        if st.button("Save Model", use_container_width=True, type="primary"):
                            with st.spinner("Saving model..."):
                                save_result = save_trained_model()
                                
                                if save_result["status"] == "success":
                                    st.success(f" {save_result['message']}")
                                    
                                    # Add to training history
                                    result['saved'] = True
                                    st.session_state.training_history.append(result)
                                    
                                    st.balloons()
                                    st.info("Model saved successfully! Use the 'Deploy Model' button below to activate it for predictions.")
                                else:
                                    st.error(f" {save_result['message']}")
                    
                    with col2:
                        if st.button("Discard Model", use_container_width=True):
                            st.warning("Model discarded. The previous model remains active.")
                            result['saved'] = False
                            st.session_state.training_history.append(result)
                            st.session_state.last_training_result = None
                    
                    with col3:
                        # Show comparison with previous models
                        if st.session_state.training_history:
                            with st.expander(" Compare with History"):
                                history_metrics = []
                                for idx, hist in enumerate(st.session_state.training_history[-5:], 1):
                                    history_metrics.append({
                                        'Run': f"#{len(st.session_state.training_history) - 5 + idx}",
                                        'Accuracy': f"{hist['metrics']['accuracy']:.1%}",
                                        'F1': f"{hist['metrics']['f1_score']:.1%}",
                                        'Saved': 'OK' if hist.get('saved', False) else ''
                                    })
                                
                                if history_metrics:
                                    st.dataframe(pd.DataFrame(history_metrics), hide_index=True, use_container_width=True)
                    
                    st.markdown("<br>", unsafe_allow_html=True)
                    
                else:
                    st.error(f" Training failed: {result.get('message', 'Unknown error')}")
                    st.info(" Please check:\n- ZIP file structure is correct\n- Audio files are in supported formats (WAV, MP3, FLAC)\n- Backend server is running\n- API endpoint is accessible")
    
    # Model Deployment Section
    st.markdown("<br><br>", unsafe_allow_html=True)
    st.markdown("<h2> Model Deployment</h2>", unsafe_allow_html=True)
    st.markdown("<p style='color: #666; font-size: 16px;'>Control which model is actively used for predictions</p>", unsafe_allow_html=True)
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Get current deployment status
    deployment_info = get_deployment_status()
    deployment_status = deployment_info.get('deployment_status', 'unknown')
    
    # Status indicator
    col_status1, col_status2 = st.columns([1, 3])
    
    with col_status1:
        if deployment_status == "on":
            st.markdown("""
                <div style="background: linear-gradient(135deg, #22c55e 0%, #16a34a 100%); 
                            padding: 20px; border-radius: 10px; text-align: center;">
                    <h3 style="color: white; margin: 0; font-size: 18px;">Status: ON</h3>
                    <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Deployed model is active</p>
                </div>
            """, unsafe_allow_html=True)
        elif deployment_status == "off":
            st.markdown("""
                <div style="background: linear-gradient(135deg, #ef4444 0%, #dc2626 100%); 
                            padding: 20px; border-radius: 10px; text-align: center;">
                    <h3 style="color: white; margin: 0; font-size: 18px;">Status: OFF</h3>
                    <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Using saved model</p>
                </div>
            """, unsafe_allow_html=True)
        else:
            st.markdown("""
                <div style="background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); 
                            padding: 20px; border-radius: 10px; text-align: center;">
                    <h3 style="color: white; margin: 0; font-size: 18px;">Status: UNKNOWN</h3>
                    <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Unable to fetch status</p>
                </div>
            """, unsafe_allow_html=True)
    
    with col_status2:
        st.markdown("""
            <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; border-left: 4px solid #D64612;">
                <h4 style="margin: 0 0 10px 0; color: #333;">Deployment Information</h4>
                <p style="margin: 5px 0; color: #666; font-size: 14px;">
                    <strong>Current Mode:</strong> {mode}
                </p>
                <p style="margin: 5px 0; color: #666; font-size: 14px;">
                    <strong>Current Model:</strong> {model_name}
                </p>
                <p style="margin: 5px 0; color: #666; font-size: 14px;">
                    <strong>Model Path:</strong> <span style="font-size: 12px;">{path}</span>
                </p>
                <hr style="margin: 10px 0; border: none; border-top: 1px solid #ddd;">
                <p style="margin: 5px 0; color: #666; font-size: 14px;">
                    <strong>Saved Model (Fallback):</strong> <span style="font-size: 12px;">{saved_path}</span>
                </p>
                {latest_deployment}
            </div>
        """.format(
            mode=deployment_info.get('model_type', 'Unknown'),
            model_name=deployment_info.get('current_model_name', 'N/A'),
            path=deployment_info.get('current_model_path', 'N/A'),
            saved_path=deployment_info.get('saved_model_path', 'N/A'),
            latest_deployment=f"""
                <hr style="margin: 10px 0; border: none; border-top: 1px solid #ddd;">
                <p style="margin: 5px 0; color: #666; font-size: 14px;">
                    <strong>Last Deployment:</strong>
                </p>
                <p style="margin: 5px 0; color: #666; font-size: 13px; padding-left: 15px;">
                    Model: {deployment_info.get('latest_deployment', {}).get('model_name', 'N/A')}
                </p>
                <p style="margin: 5px 0; color: #666; font-size: 13px; padding-left: 15px;">
                    By: {deployment_info.get('latest_deployment', {}).get('deployed_by', 'N/A')}
                </p>
                <p style="margin: 5px 0; color: #666; font-size: 13px; padding-left: 15px;">
                    At: {pd.to_datetime(deployment_info.get('latest_deployment', {}).get('deployed_at')).strftime('%Y-%m-%d %H:%M:%S') if deployment_info.get('latest_deployment', {}).get('deployed_at') else 'N/A'}
                </p>
            """ if deployment_info.get('latest_deployment') else ""
        ), unsafe_allow_html=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Deployment controls
    col_deploy1, col_deploy2, col_deploy3 = st.columns([1, 1, 1])
    
    with col_deploy1:
        if st.button("Deploy Model", use_container_width=True, type="primary", disabled=(deployment_status == "on")):
            with st.spinner("Deploying model..."):
                deploy_result = deploy_model()
                
                if deploy_result["status"] == "success":
                    st.success(f" {deploy_result['message']}")
                    st.balloons()
                    st.rerun()
                else:
                    st.error(f" {deploy_result['message']}")
    
    with col_deploy2:
        if st.button("Deactivate Model", use_container_width=True, disabled=(deployment_status != "on")):
            with st.spinner("Deactivating model..."):
                deactivate_result = deactivate_model()
                
                if deactivate_result["status"] == "success":
                    st.warning(f" {deactivate_result['message']}")
                    st.rerun()
                else:
                    st.error(f" {deactivate_result['message']}")
    
    with col_deploy3:
        if st.button("Refresh Status", use_container_width=True):
            st.rerun()
    
    # Help information
    with st.expander(" How Deployment Works"):
        st.markdown("""
            <div style="padding: 10px;">
                <h4>Understanding Model Deployment</h4>
                <p style="color: #666; margin-bottom: 10px;">The system maintains two separate model directories:</p>
                <ul style="color: #666; line-height: 1.8;">
                    <li><strong>Saved Model (Fallback):</strong> Located in <code>Model/saved_model/</code> - This is the original production model that remains unchanged</li>
                    <li><strong>Admin Models:</strong> Located in <code>Model/admin_saved_model/</code> - New models trained by admins are saved here with timestamps</li>
                </ul>
                <h4 style="margin-top: 15px;">Deployment Controls:</h4>
                <ul style="color: #666; line-height: 1.8;">
                    <li><strong>Deploy Model (ON):</strong> Activates the latest admin model for all predictions across the application</li>
                    <li><strong>Deactivate Model (OFF):</strong> Switches back to using the original saved model (fallback)</li>
                    <li><strong>Status Indicator:</strong> Shows current deployment state in real-time</li>
                    <li><strong>Safe Operation:</strong> You can always revert to the fallback model without losing data</li>
                </ul>
                <p style="color: #FB8239; font-weight: 600; margin-top: 15px;">
                    Note: Always test your model metrics before deploying to production!
                </p>
            </div>
        """, unsafe_allow_html=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Training History Section
    if st.session_state.training_history:
        st.markdown("<br><br>", unsafe_allow_html=True)
        st.markdown("<h2> Training History</h2>", unsafe_allow_html=True)
        st.markdown("<p style='color: #666; font-size: 16px;'>View all previous training sessions and their results</p>", unsafe_allow_html=True)
        st.markdown("<br>", unsafe_allow_html=True)
        
        # Display training history
        history_data = []
        for idx, training in enumerate(reversed(st.session_state.training_history), 1):
            roc_auc = training['metrics'].get('roc_auc', 'N/A')
            history_data.append({
                'Run': f"#{len(st.session_state.training_history) - idx + 1}",
                'Timestamp': pd.to_datetime(training['timestamp']).strftime('%Y-%m-%d %H:%M:%S'),
                'Accuracy': f"{training['metrics']['accuracy']:.1%}",
                'Precision': f"{training['metrics']['precision']:.1%}",
                'Recall': f"{training['metrics']['recall']:.1%}",
                'F1 Score': f"{training['metrics']['f1_score']:.1%}",
                'ROC-AUC': f"{roc_auc:.3f}" if isinstance(roc_auc, (int, float)) else roc_auc,
                'Saved': 'Yes' if training.get('saved', False) else 'No'
            })
        
        history_df = pd.DataFrame(history_data)
        st.dataframe(
            history_df,
            use_container_width=True,
            hide_index=True,
            column_config={
                "Run": st.column_config.TextColumn("Run", width="small"),
                "Timestamp": st.column_config.TextColumn("Timestamp", width="medium"),
                "Accuracy": st.column_config.TextColumn("Accuracy", width="small"),
                "Precision": st.column_config.TextColumn("Precision", width="small"),
                "Recall": st.column_config.TextColumn("Recall", width="small"),
                "F1 Score": st.column_config.TextColumn("F1", width="small"),
                "ROC-AUC": st.column_config.TextColumn("ROC-AUC", width="small"),
                "Saved": st.column_config.TextColumn("Saved", width="small"),
            }
        )
        
        # Download training history
        st.markdown("<br>", unsafe_allow_html=True)
        csv_data = history_df.to_csv(index=False)
        st.download_button(
            label="Download Training History (CSV)",
            data=csv_data,
            file_name=f"training_history_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
            mime="text/csv",
            use_container_width=False
        )
    
    st.stop()

# =======================
# MAIN DASHBOARD PAGE
# =======================

# Fetch data
with st.spinner(" Loading dashboard data..."):
    predictions = fetch_all_predictions()
    users = fetch_all_users()
    metrics = calculate_metrics(predictions)
    
    # Update sidebar stats
    st.session_state.sidebar_stats = {
        'users': len(users),
        'audio': metrics["total_audio"],
        'confidence': metrics["avg_confidence"]
    }

# Display metrics
st.markdown("<h2>Overview Metrics</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="Total Audio Files",
        value=f"{metrics['total_audio']:,}"
    )

with col2:
    st.metric(
        label="Total Users",
        value=f"{len(users):,}"
    )

with col3:
    st.metric(
        label="Average Confidence",
        value=f"{metrics['avg_confidence']:.1f}%"
    )

with col4:
    st.metric(
        label="Unique Labels",
        value=len(metrics["by_label"])
    )

st.markdown("<br><br>", unsafe_allow_html=True)

# Audio counts by label
st.markdown("<h2> Audio_Distribution by Label</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

if metrics["by_label"]:
    col1, col2, col3, col4, col5 = st.columns(5)
    
    labels_order = ["Belly_pain", "Burping", "Discomfort", "Hungry", "Tired/Sleepy"]
    colors = ["#ef4444", "#06b6d4", "#3b82f6", "#f59e0b", "#10b981"]
    label_emojis = ["", "", "", "", ""]
    
    for idx, (col, label, emoji) in enumerate(zip([col1, col2, col3, col4, col5], labels_order, label_emojis)):
        count = metrics["by_label"].get(label, 0)
        with col:
            st.metric(
                label=f"{emoji} {label.replace('_', ' ')}",
                value=f"{count:,}"
            )
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Visualization
    st.markdown("<h3> Visual_Analytics</h3>", unsafe_allow_html=True)
    
    chart_col1, chart_col2 = st.columns(2)
    
    with chart_col1:
        # Pie chart with enhanced styling
        fig_pie = go.Figure(data=[go.Pie(
            labels=[f"{emoji} {label.replace('_', ' ')}" for label, emoji in zip(labels_order, label_emojis)],
            values=[metrics["by_label"].get(label, 0) for label in labels_order],
            hole=.4,
            marker_colors=colors,
            textinfo='label+percent',
            textfont_size=12,
            hovertemplate="<b>%{label}</b><br>Count: %{value}<br>Percentage: %{percent}<extra></extra>"
        )])
        fig_pie.update_layout(
            title={
                'text': "Distribution by Label",
                'y':0.95,
                'x':0.5,
                'xanchor': 'center',
                'yanchor': 'top',
                'font': {'size': 18, 'color': '#D64612', 'family': 'Poppins'}
            },
            showlegend=True,
            legend=dict(
                orientation="v",
                yanchor="middle",
                y=0.5,
                xanchor="left",
                x=1.1
            ),
            height=400,
            paper_bgcolor='rgba(0,0,0,0)',
            plot_bgcolor='rgba(0,0,0,0)'
        )
        st.plotly_chart(fig_pie, use_container_width=True)
    
    with chart_col2:
        # Bar chart with enhanced styling
        fig_bar = go.Figure(data=[go.Bar(
            x=[f"{emoji} {label.replace('_', ' ')}" for label, emoji in zip(labels_order, label_emojis)],
            y=[metrics["by_label"].get(label, 0) for label in labels_order],
            marker_color=colors,
            text=[metrics["by_label"].get(label, 0) for label in labels_order],
            textposition='auto',
            hovertemplate="<b>%{x}</b><br>Count: %{y}<extra></extra>"
        )])
        fig_bar.update_layout(
            title={
                'text': 'Audio Count by Label',
                'y':0.95,
                'x':0.5,
                'xanchor': 'center',
                'yanchor': 'top',
                'font': {'size': 18, 'color': '#D64612', 'family': 'Poppins'}
            },
            xaxis_title="Label",
            yaxis_title="Count",
            height=400,
            showlegend=False,
            paper_bgcolor='rgba(0,0,0,0)',
            plot_bgcolor='rgba(0,0,0,0)',
            xaxis=dict(showgrid=False),
            yaxis=dict(showgrid=True, gridcolor='rgba(214, 70, 18, 0.1)')
        )
        st.plotly_chart(fig_bar, use_container_width=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
else:
    st.info("No label data available yet.")

# User summary table
st.markdown("<h2>User Summary & Analysis</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

user_summary_df = create_user_summary(users, predictions)

if not user_summary_df.empty:
    # Add search and filter with enhanced UI
    col1, col2, col3 = st.columns([2, 1, 1])
    with col1:
        search = st.text_input("Search by name or email", "", placeholder="Type to search...")
    with col2:
        min_audio = st.number_input("Min audio files", min_value=0, value=0)
    with col3:
        # Sort options
        sort_by = st.selectbox("Sort by", 
            ["Total Audio", "Name", "Belly Pain", "Burping", "Discomfort", "Hungry", "Tired/Sleepy"],
            index=0
        )
    
    # Filter data
    filtered_df = user_summary_df.copy()
    if search:
        filtered_df = filtered_df[
            filtered_df['Name'].str.contains(search, case=False, na=False) |
            filtered_df['Email'].str.contains(search, case=False, na=False)
        ]
    if min_audio > 0:
        filtered_df = filtered_df[filtered_df['Total Audio'] >= min_audio]
    
    # Sort data
    filtered_df = filtered_df.sort_values(by=sort_by, ascending=False)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Display summary stats
    summary_col1, summary_col2, summary_col3, summary_col4 = st.columns(4)
    with summary_col1:
        st.markdown(f"""
            <div style="background: linear-gradient(135deg, #D64612, #FB8239); color: white; padding: 15px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 24px;">{len(filtered_df)}</h3>
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Showing Users</p>
            </div>
        """, unsafe_allow_html=True)
    
    with summary_col2:
        total_audio = filtered_df['Total Audio'].sum()
        st.markdown(f"""
            <div style="background: linear-gradient(135deg, #3b82f6, #2563eb); color: white; padding: 15px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 24px;">{total_audio:,}</h3>
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Total Audio Files</p>
            </div>
        """, unsafe_allow_html=True)
    
    with summary_col3:
        avg_audio = filtered_df['Total Audio'].mean() if len(filtered_df) > 0 else 0
        st.markdown(f"""
            <div style="background: linear-gradient(135deg, #10b981, #059669); color: white; padding: 15px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 24px;">{avg_audio:.1f}</h3>
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Avg. per User</p>
            </div>
        """, unsafe_allow_html=True)
    
    with summary_col4:
        max_audio = filtered_df['Total Audio'].max() if len(filtered_df) > 0 else 0
        st.markdown(f"""
            <div style="background: linear-gradient(135deg, #f59e0b, #d97706); color: white; padding: 15px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 24px;">{max_audio:,}</h3>
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Max. Audio of single User</p>
            </div>
        """, unsafe_allow_html=True)
    
    st.markdown("<br><br>", unsafe_allow_html=True)
    
    # Display table with enhanced styling
    st.dataframe(
        filtered_df,
        use_container_width=True,
        height=400,
        column_config={
            "User ID": st.column_config.TextColumn("User ID", width="small"),
            "Name": st.column_config.TextColumn("Name", width="medium"),
            "Phone": st.column_config.TextColumn("Phone", width="small"),
            "Email": st.column_config.TextColumn("Email", width="medium"),
            "Total Audio": st.column_config.NumberColumn("Total", width="small"),
            "Belly Pain": st.column_config.NumberColumn("Belly Pain", width="small"),
            "Burping": st.column_config.NumberColumn("Burping", width="small"),
            "Discomfort": st.column_config.NumberColumn("Discomfort", width="small"),
            "Hungry": st.column_config.NumberColumn("Hungry", width="small"),
            "Tired/Sleepy": st.column_config.NumberColumn("Tired/Sleepy", width="small"),
        }
    )
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Download button with enhanced styling
    csv = filtered_df.to_csv(index=False)
    st.download_button(
        label="Download User Summary (CSV)",
        data=csv,
        file_name=f"neoparental_user_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
        mime="text/csv",
        use_container_width=False
    )
else:
    st.info("No user data available yet.")

st.markdown("<br>", unsafe_allow_html=True)

# Recent predictions
st.markdown("<h2>Recent Predictions</h2>", unsafe_allow_html=True)
st.markdown("<p style='color: #666; font-size: 16px;'>Latest 10 audio analysis results from all users</p>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

if predictions:
    recent_df = pd.DataFrame(predictions[:10]).copy()
    recent_df['created_at'] = pd.to_datetime(recent_df['created_at'])
    
    # Add emoji labels
    label_emoji_map = {
        "Belly_pain": "",
        "Burping": "",
        "Discomfort": "",
        "Hungry": "",
        "Tired/Sleepy": ""
    }
    
    recent_df['Label with Icon'] = recent_df['predicted_label'].apply(
        lambda x: f"{label_emoji_map.get(x, '🔹')} {x.replace('_', ' ')}"
    )
    
    st.dataframe(
        recent_df[['username', 'audio_filename', 'Label with Icon', 'confidence', 'created_at']],
        use_container_width=True,
        height=400,
        column_config={
            "username": st.column_config.TextColumn("User", width="medium"),
            "audio_filename": st.column_config.TextColumn("Audio File", width="large"),
            "Label with Icon": st.column_config.TextColumn("Predicted Label", width="medium"),
            "confidence": st.column_config.NumberColumn("Confidence (%)", format="%.1f", width="small"),
            "created_at": st.column_config.DatetimeColumn("Date & Time", format="DD/MM/YYYY HH:mm", width="medium")
        },
        hide_index=True
    )
else:
    st.info("No predictions available yet.")

# Audio Download Section
st.markdown("<br><br>", unsafe_allow_html=True)
st.markdown("<h2>Download Audio Files</h2>", unsafe_allow_html=True)
st.markdown("<p style='color: #666; font-size: 16px;'>Download all uploaded audio files organized by predicted labels</p>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

if predictions:
    # Display summary of available audio files
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.markdown("""
            <div style="background: linear-gradient(135deg, #4F46E5 0%, #7C3AED 100%); 
                        padding: 20px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 32px;">{}</h3>
                <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Total Audio Files</p>
            </div>
        """.format(len(predictions)), unsafe_allow_html=True)
    
    with col2:
        unique_labels = len(set(p.get('predicted_label', 'Unknown') for p in predictions))
        st.markdown("""
            <div style="background: linear-gradient(135deg, #10B981 0%, #059669 100%); 
                        padding: 20px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 32px;">{}</h3>
                <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Different Labels</p>
            </div>
        """.format(unique_labels), unsafe_allow_html=True)
    
    with col3:
        unique_users = len(set(p.get('username', 'Unknown') for p in predictions))
        st.markdown("""
            <div style="background: linear-gradient(135deg, #F59E0B 0%, #D97706 100%); 
                        padding: 20px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 32px;">{}</h3>
                <p style="color: white; margin: 5px 0 0 0; font-size: 14px;">Active Users</p>
            </div>
        """.format(unique_users), unsafe_allow_html=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Show breakdown by label
    label_counts = {}
    for pred in predictions:
        label = pred.get('predicted_label', 'Unknown')
        label_counts[label] = label_counts.get(label, 0) + 1
    
    st.markdown("<h3>Files by Label</h3>", unsafe_allow_html=True)
    breakdown_df = pd.DataFrame([
        {"Label": label.replace('_', ' '), "Count": count} 
        for label, count in sorted(label_counts.items(), key=lambda x: x[1], reverse=True)
    ])
    
    col_table, col_chart = st.columns([1, 1])
    
    with col_table:
        st.dataframe(
            breakdown_df,
            use_container_width=True,
            hide_index=True,
            column_config={
                "Label": st.column_config.TextColumn("Predicted Label", width="medium"),
                "Count": st.column_config.NumberColumn("Audio Files", width="small")
            }
        )
    
    with col_chart:
        fig = px.pie(
            breakdown_df, 
            values='Count', 
            names='Label',
            color_discrete_sequence=px.colors.sequential.Oranges_r
        )
        fig.update_traces(textposition='inside', textinfo='percent+label')
        fig.update_layout(
            showlegend=False,
            height=300,
            margin=dict(t=0, b=0, l=0, r=0)
        )
        st.plotly_chart(fig, use_container_width=True)
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Download button
    col_btn1, col_btn2, col_btn3 = st.columns([1, 1, 1])
    
    with col_btn2:
        if st.button("Download All Audio Files (ZIP)", use_container_width=True, type="primary"):
            with st.spinner("Preparing ZIP file... This may take a few minutes depending on the number of files."):
                try:
                    zip_data = download_audio_files_by_label(predictions)
                    
                    # Generate filename with timestamp
                    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
                    filename = f"neoparental_audio_files_{timestamp}.zip"
                    
                    # Direct download
                    st.download_button(
                        label="Click here to download",
                        data=zip_data,
                        file_name=filename,
                        mime="application/zip",
                        use_container_width=True,
                        key="download_zip"
                    )
                    
                    st.success("Downloaded Successfully!")
                    
                except Exception as e:
                    st.error(f"Error creating ZIP file: {str(e)}")
    
else:
    st.info("No audio files available for download.")

# Footer
st.markdown("<br><br>", unsafe_allow_html=True)
st.markdown("""
    <div style="text-align: center; padding: 30px; background: linear-gradient(135deg, #FFF5F0, #FFE5DC); border-radius: 15px; margin-top: 40px;">
        <p style="color: #D64612; font-size: 18px; font-weight: 600; margin: 0;">
            👶 NeoParental Admin Dashboard
        </p>
        <p style="color: #666; font-size: 14px; margin: 10px 0 0 0;">
            Empowering parents with intelligent baby cry analysis
        </p>
        <p style="color: #999; font-size: 12px; margin: 10px 0 0 0;">
            © 2025 NeoParental. All rights reserved.
        </p>
    </div>
""", unsafe_allow_html=True)