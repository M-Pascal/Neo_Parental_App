# Quick Test Script for Model Deployment System
# This script helps test the deployment endpoints

import requests
import json

# Configuration
API_BASE_URL = "https://neo-parental-app-2.onrender.com"
ADMIN_USERNAME = "admin@neoparental.com"
ADMIN_PASSWORD = "YourSecureAdminPassword"

def get_admin_token():
    """Login and get admin token"""
    response = requests.post(
        f"{API_BASE_URL}/login",
        data={
            "username": ADMIN_USERNAME,
            "password": ADMIN_PASSWORD
        }
    )
    if response.status_code == 200:
        return response.json()["access_token"]
    else:
        print(f"Login failed: {response.text}")
        return None

def get_headers(token):
    """Get headers with auth token"""
    return {"Authorization": f"Bearer {token}"}

def test_deployment_status(token):
    """Test getting deployment status"""
    print("\n1. Testing GET /admin/deployment_status...")
    response = requests.get(
        f"{API_BASE_URL}/admin/deployment_status",
        headers=get_headers(token)
    )
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
        return data
    else:
        print(f"Error: {response.text}")
        return None

def test_deploy_model(token):
    """Test deploying model"""
    print("\n2. Testing POST /admin/deploy_model...")
    response = requests.post(
        f"{API_BASE_URL}/admin/deploy_model",
        headers=get_headers(token)
    )
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
        return data
    else:
        print(f"Error: {response.text}")
        return None

def test_deactivate_model(token):
    """Test deactivating model"""
    print("\n3. Testing POST /admin/deactivate_model...")
    response = requests.post(
        f"{API_BASE_URL}/admin/deactivate_model",
        headers=get_headers(token)
    )
    print(f"Status Code: {response.status_code}")
    if response.status_code == 200:
        data = response.json()
        print(f"Response: {json.dumps(data, indent=2)}")
        return data
    else:
        print(f"Error: {response.text}")
        return None

def main():
    """Run all tests"""
    print("=" * 60)
    print("MODEL DEPLOYMENT SYSTEM - API TEST")
    print("=" * 60)
    
    # Login
    print("\nLogging in as admin...")
    token = get_admin_token()
    if not token:
        print("Failed to get admin token. Exiting.")
        return
    print("Successfully logged in!")
    
    # Test 1: Get initial status
    status = test_deployment_status(token)
    if status:
        print(f"Current deployment status: {status.get('deployment_status')}")
    
    # Test 2: Deploy model
    print("\n" + "-" * 60)
    input("Press Enter to deploy model...")
    deploy_result = test_deploy_model(token)
    if deploy_result:
        print("Model deployed successfully!")
    
    # Test 3: Check status after deployment
    print("\n" + "-" * 60)
    print("Checking status after deployment...")
    status = test_deployment_status(token)
    if status:
        print(f"Deployment status is now: {status.get('deployment_status')}")
    
    # Test 4: Deactivate model
    print("\n" + "-" * 60)
    input("Press Enter to deactivate model...")
    deactivate_result = test_deactivate_model(token)
    if deactivate_result:
        print("Model deactivated successfully!")
    
    # Test 5: Check status after deactivation
    print("\n" + "-" * 60)
    print("Checking status after deactivation...")
    status = test_deployment_status(token)
    if status:
        print(f"Deployment status is now: {status.get('deployment_status')}")
    
    print("\n" + "=" * 60)
    print("ALL TESTS COMPLETED!")
    print("=" * 60)

if __name__ == "__main__":
    main()
