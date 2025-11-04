import os
from dotenv import load_dotenv
import cloudinary
import cloudinary.uploader
import cloudinary.api

# Load environment variables
load_dotenv()

print("=" * 60)
print("CLOUDINARY CONFIGURATION TEST")
print("=" * 60)

# Check environment variables
print("\n1. Environment Variables:")
print("-" * 60)

cloudinary_url = os.getenv("CLOUDINARY_URL")
cloud_name = os.getenv("CLOUDINARY_CLOUD_NAME")
api_key = os.getenv("CLOUDINARY_API_KEY")
api_secret = os.getenv("CLOUDINARY_API_SECRET")

print(f"CLOUDINARY_URL: {cloudinary_url[:50] + '...' if cloudinary_url else 'NOT SET'}")
print(f"CLOUDINARY_CLOUD_NAME: {cloud_name if cloud_name else 'NOT SET'}")
print(f"CLOUDINARY_API_KEY: {api_key if api_key else 'NOT SET'}")
print(f"CLOUDINARY_API_SECRET: {'SET' if api_secret else 'NOT SET'}")

# Try configuration method 1: Individual credentials
print("\n2. Testing Configuration Method 1 (Individual Credentials):")
print("-" * 60)
try:
    if all([cloud_name, api_key, api_secret]):
        cloudinary.config(
            cloud_name=cloud_name,
            api_key=api_key,
            api_secret=api_secret
        )
        print("SUCCESS: Configured with individual credentials")
        
        # Verify
        config = cloudinary.config()
        print(f"  - Cloud Name: {config.cloud_name}")
        print(f"  - API Key: {config.api_key}")
        print(f"  - API Secret: {'SET' if config.api_secret else 'NOT SET'}")
    else:
        print("FAILED: Missing individual credentials")
except Exception as e:
    print(f"ERROR: {e}")

# Try configuration method 2: CLOUDINARY_URL
print("\n3. Testing Configuration Method 2 (CLOUDINARY_URL):")
print("-" * 60)
try:
    if cloudinary_url:
        cloudinary.config(cloudinary_url=cloudinary_url)
        print("SUCCESS: Configured with CLOUDINARY_URL")
        
        # Verify
        config = cloudinary.config()
        print(f"  - Cloud Name: {config.cloud_name}")
        print(f"  - API Key: {config.api_key}")
        print(f"  - API Secret: {'SET' if config.api_secret else 'NOT SET'}")
    else:
        print("FAILED: CLOUDINARY_URL not set")
except Exception as e:
    print(f"ERROR: {e}")

# Test connection
print("\n4. Testing Cloudinary Connection:")
print("-" * 60)
try:
    result = cloudinary.api.ping()
    print(f"SUCCESS: Cloudinary ping successful")
    print(f"Response: {result}")
except Exception as e:
    print(f"FAILED: {e}")

# Test upload (optional - creates a small test file)
print("\n5. Testing Upload Capability:")
print("-" * 60)
try:
    # Create a tiny test file
    test_file = "test_upload.txt"
    with open(test_file, "w") as f:
        f.write("test")
    
    result = cloudinary.uploader.upload(
        test_file,
        resource_type="raw",
        public_id="test/test_upload"
    )
    print(f"SUCCESS: Test upload successful")
    print(f"URL: {result.get('secure_url')}")
    
    # Cleanup
    cloudinary.uploader.destroy("test/test_upload", resource_type="raw")
    os.remove(test_file)
    print("Cleanup: Test file deleted")
    
except Exception as e:
    print(f"FAILED: {e}")

print("\n" + "=" * 60)
print("TEST COMPLETE")
print("=" * 60)
