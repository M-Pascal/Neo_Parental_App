import streamlit as st
import requests
import pandas as pd
from datetime import datetime
import plotly.express as px
import plotly.graph_objects as go
from typing import Dict, List

# Configuration
API_BASE_URL = "http://localhost:8000"  # Change this to your API URL

# Page configuration
st.set_page_config(
    page_title="NeoParental Admin Dashboard",
    page_icon="NP",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS
st.markdown("""
    <style>
    /* Metric styling */
    [data-testid="stMetricValue"] {
        font-size: 32px;
        color: #1f2937;
        font-weight: 600;
    }
    
    [data-testid="stMetricLabel"] {
        font-size: 14px;
        color: #6b7280;
        font-weight: 500;
    }
    
    /* Card backgrounds */
    div[data-testid="metric-container"] {
        background-color: #ffffff;
        border: 1px solid #e5e7eb;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }
    
    /* Header styling */
    h1 {
        color: #111827;
        font-weight: 700;
    }
    
    h2 {
        color: #374151;
        font-weight: 600;
        margin-top: 2rem;
        margin-bottom: 1rem;
    }
    
    h3 {
        color: #4b5563;
        font-weight: 600;
    }
    
    /* Table styling */
    [data-testid="stDataFrame"] {
        border: 1px solid #e5e7eb;
        border-radius: 8px;
    }
    
    /* Sidebar styling */
    [data-testid="stSidebar"] {
        background-color: #f9fafb;
    }
    
    /* Button styling */
    .stButton > button {
        background-color: #3b82f6;
        color: white;
        border: none;
        border-radius: 6px;
        padding: 0.5rem 1rem;
        font-weight: 500;
    }
    
    .stButton > button:hover {
        background-color: #2563eb;
    }
    </style>
""", unsafe_allow_html=True)

# Authentication state
if 'token' not in st.session_state:
    st.session_state.token = None
if 'user' not in st.session_state:
    st.session_state.user = None

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

# Login page
if not st.session_state.token:
    st.title("NeoParental Admin Login")
    
    col1, col2, col3 = st.columns([1, 2, 1])
    with col2:
        with st.form("login_form"):
            username = st.text_input("Username or Email")
            password = st.text_input("Password", type="password")
            submit = st.form_submit_button("Login", use_container_width=True)
            
            if submit:
                if login(username, password):
                    # Check if user is admin
                    if st.session_state.user.get('role') == 'admin':
                        st.success("Login successful!")
                        st.rerun()
                    else:
                        st.error("Admin access required")
                        st.session_state.token = None
                        st.session_state.user = None
                else:
                    st.error("Invalid credentials")
    st.stop()

# Main Dashboard
st.title("👶 NeoParental Admin Dashboard")

# Sidebar
with st.sidebar:
    st.header(f"Welcome, {st.session_state.user['username']}!")
    st.info(f"Role: {st.session_state.user['role']}")
    
    if st.button("Refresh Data", use_container_width=True):
        st.rerun()
    
    if st.button("Logout", use_container_width=True):
        st.session_state.token = None
        st.session_state.user = None
        st.rerun()

# Fetch data
with st.spinner("Loading data..."):
    predictions = fetch_all_predictions()
    users = fetch_all_users()
    metrics = calculate_metrics(predictions)

# Display metrics
st.header("📊 Overview Metrics")

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="Total Audio Files",
        value=metrics["total_audio"]
    )

with col2:
    st.metric(
        label="Total Users",
        value=len(users)
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

# Audio counts by label
st.header("Audio Distribution by Label")

if metrics["by_label"]:
    col1, col2, col3, col4, col5 = st.columns(5)
    
    labels_order = ["Belly_pain", "Burping", "Discomfort", "Hungry", "Tired/Sleepy"]
    colors = ["#ef4444", "#06b6d4", "#3b82f6", "#f59e0b", "#10b981"]
    
    for idx, (col, label) in enumerate(zip([col1, col2, col3, col4, col5], labels_order)):
        count = metrics["by_label"].get(label, 0)
        with col:
            st.metric(
                label=label.replace("_", " "),
                value=count
            )
    
    # Visualization
    st.subheader("📊 Label Distribution Chart")
    
    chart_col1, chart_col2 = st.columns(2)
    
    with chart_col1:
        # Pie chart
        fig_pie = go.Figure(data=[go.Pie(
            labels=list(metrics["by_label"].keys()),
            values=list(metrics["by_label"].values()),
            hole=.3,
            marker_colors=colors
        )])
        fig_pie.update_layout(title="Distribution by Label")
        st.plotly_chart(fig_pie, use_container_width=True)
    
    with chart_col2:
        # Bar chart
        fig_bar = px.bar(
            x=list(metrics["by_label"].keys()),
            y=list(metrics["by_label"].values()),
            labels={'x': 'Label', 'y': 'Count'},
            title='Audio Count by Label',
            color=list(metrics["by_label"].keys()),
            color_discrete_sequence=colors
        )
        st.plotly_chart(fig_bar, use_container_width=True)

# User summary table
st.header("👥 User Summary")

user_summary_df = create_user_summary(users, predictions)

if not user_summary_df.empty:
    # Add search and filter
    col1, col2 = st.columns([3, 1])
    with col1:
        search = st.text_input("Search by name or email", "")
    with col2:
        min_audio = st.number_input("Min audio files", min_value=0, value=0)
    
    # Filter data
    filtered_df = user_summary_df.copy()
    if search:
        filtered_df = filtered_df[
            filtered_df['Name'].str.contains(search, case=False) |
            filtered_df['Email'].str.contains(search, case=False)
        ]
    if min_audio > 0:
        filtered_df = filtered_df[filtered_df['Total Audio'] >= min_audio]
    
    # Display table
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
    
    # Download button
    csv = filtered_df.to_csv(index=False)
    st.download_button(
        label="Download User Summary (CSV)",
        data=csv,
        file_name=f"user_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
        mime="text/csv"
    )
else:
    st.info("No user data available")

# Recent predictions
st.header("Recent Predictions")

if predictions:
    recent_df = pd.DataFrame(predictions[:10])
    recent_df['created_at'] = pd.to_datetime(recent_df['created_at'])
    
    st.dataframe(
        recent_df[['username', 'audio_filename', 'predicted_label', 'confidence', 'created_at']],
        use_container_width=True,
        column_config={
            "username": "User",
            "audio_filename": "File",
            "predicted_label": "Label",
            "confidence": st.column_config.NumberColumn("Confidence (%)", format="%.1f"),
            "created_at": st.column_config.DatetimeColumn("Date", format="DD/MM/YYYY HH:mm")
        }
    )
else:
    st.info("No predictions available")