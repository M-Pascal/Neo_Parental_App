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
            st.markdown("<h3 style='text-align: center; color: #D64612; margin-bottom: 20px;'>🔐 Admin Login</h3>", unsafe_allow_html=True)
            
            username = st.text_input("👤 Username or Email", placeholder="Enter your username or email")
            password = st.text_input("🔑 Password", type="password", placeholder="Enter your password")
            
            st.markdown("<br>", unsafe_allow_html=True)
            submit = st.form_submit_button("🚀 Login", use_container_width=True)
            
            if submit:
                with st.spinner("Authenticating..."):
                    if login(username, password):
                        # Check if user is admin
                        if st.session_state.user.get('role') == 'admin':
                            st.success("✅ Login successful! Redirecting...")
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
        <h1>👶 NeoParental Admin Dashboard</h1>
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
            <div style="font-size: 32px; text-align: center; margin-bottom: 10px;">👤</div>
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
    
    if st.button("🔄 Refresh Data", use_container_width=True):
        st.rerun()
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    if st.button("🚪 Logout", use_container_width=True):
        st.session_state.token = None
        st.session_state.user = None
        st.rerun()
    
    st.markdown("---")
    
    # Stats summary in sidebar
    st.markdown("<h3 style='color: white; font-size: 18px; margin-bottom: 15px;'>📊 Quick Stats</h3>", unsafe_allow_html=True)
    
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

# Fetch data
with st.spinner("🔄 Loading dashboard data..."):
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
st.markdown("<h2>📊 Overview Metrics</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="🎵 Total Audio Files",
        value=f"{metrics['total_audio']:,}"
    )

with col2:
    st.metric(
        label="👥 Total Users",
        value=f"{len(users):,}"
    )

with col3:
    st.metric(
        label="🎯 Average Confidence",
        value=f"{metrics['avg_confidence']:.1f}%"
    )

with col4:
    st.metric(
        label="🏷️ Unique Labels",
        value=len(metrics["by_label"])
    )

st.markdown("<br><br>", unsafe_allow_html=True)

# Audio counts by label
st.markdown("<h2>🎵 Audio Distribution by Label</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

if metrics["by_label"]:
    col1, col2, col3, col4, col5 = st.columns(5)
    
    labels_order = ["Belly_pain", "Burping", "Discomfort", "Hungry", "Tired/Sleepy"]
    colors = ["#ef4444", "#06b6d4", "#3b82f6", "#f59e0b", "#10b981"]
    label_emojis = ["😣", "🍼", "😰", "🍽️", "😴"]
    
    for idx, (col, label, emoji) in enumerate(zip([col1, col2, col3, col4, col5], labels_order, label_emojis)):
        count = metrics["by_label"].get(label, 0)
        with col:
            st.metric(
                label=f"{emoji} {label.replace('_', ' ')}",
                value=f"{count:,}"
            )
    
    st.markdown("<br>", unsafe_allow_html=True)
    
    # Visualization
    st.markdown("<h3>� Visual Analytics</h3>", unsafe_allow_html=True)
    
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
st.markdown("<h2>👥 User Summary & Analysis</h2>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

user_summary_df = create_user_summary(users, predictions)

if not user_summary_df.empty:
    # Add search and filter with enhanced UI
    col1, col2, col3 = st.columns([2, 1, 1])
    with col1:
        search = st.text_input("🔍 Search by name or email", "", placeholder="Type to search...")
    with col2:
        min_audio = st.number_input("📊 Min audio files", min_value=0, value=0)
    with col3:
        # Sort options
        sort_by = st.selectbox("📑 Sort by", 
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
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Avg per User</p>
            </div>
        """, unsafe_allow_html=True)
    
    with summary_col4:
        max_audio = filtered_df['Total Audio'].max() if len(filtered_df) > 0 else 0
        st.markdown(f"""
            <div style="background: linear-gradient(135deg, #f59e0b, #d97706); color: white; padding: 15px; border-radius: 10px; text-align: center;">
                <h3 style="color: white; margin: 0; font-size: 24px;">{max_audio:,}</h3>
                <p style="color: rgba(255,255,255,0.9); margin: 5px 0 0 0; font-size: 14px;">Max by User</p>
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
        label="📥 Download User Summary (CSV)",
        data=csv,
        file_name=f"neoparental_user_summary_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv",
        mime="text/csv",
        use_container_width=False
    )
else:
    st.info("📭 No user data available yet.")

st.markdown("<br>", unsafe_allow_html=True)

# Recent predictions
st.markdown("<h2>🕐 Recent Predictions</h2>", unsafe_allow_html=True)
st.markdown("<p style='color: #666; font-size: 16px;'>Latest 10 audio analysis results from all users</p>", unsafe_allow_html=True)
st.markdown("<br>", unsafe_allow_html=True)

if predictions:
    recent_df = pd.DataFrame(predictions[:10]).copy()
    recent_df['created_at'] = pd.to_datetime(recent_df['created_at'])
    
    # Add emoji labels
    label_emoji_map = {
        "Belly_pain": "😣",
        "Burping": "🍼",
        "Discomfort": "😰",
        "Hungry": "🍽️",
        "Tired/Sleepy": "😴"
    }
    
    recent_df['Label with Icon'] = recent_df['predicted_label'].apply(
        lambda x: f"{label_emoji_map.get(x, '🔹')} {x.replace('_', ' ')}"
    )
    
    st.dataframe(
        recent_df[['username', 'audio_filename', 'Label with Icon', 'confidence', 'created_at']],
        use_container_width=True,
        height=400,
        column_config={
            "username": st.column_config.TextColumn("👤 User", width="medium"),
            "audio_filename": st.column_config.TextColumn("🎵 Audio File", width="large"),
            "Label with Icon": st.column_config.TextColumn("🏷️ Predicted Label", width="medium"),
            "confidence": st.column_config.NumberColumn("🎯 Confidence (%)", format="%.1f", width="small"),
            "created_at": st.column_config.DatetimeColumn("📅 Date & Time", format="DD/MM/YYYY HH:mm", width="medium")
        },
        hide_index=True
    )
else:
    st.info("📭 No predictions available yet.")

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