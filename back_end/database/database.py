import os
import ssl
import certifi
import motor.motor_asyncio
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr, Field
from passlib.context import CryptContext
from jose import JWTError, jwt
from datetime import datetime, timedelta
from typing import Optional, List
from bson import ObjectId
from dotenv import load_dotenv

# === Load environment variables ===
load_dotenv()

# === Configuration ===
MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
JWT_SECRET = os.getenv("JWT_SECRET", "your_secret_key")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60

# === MongoDB connection with SSL ===
try:
    client = motor.motor_asyncio.AsyncIOMotorClient(
        MONGO_URI,
        tlsCAFile=certifi.where(),
        serverSelectionTimeoutMS=30000
    )
    db = client[DB_NAME]
    users_collection = db["users"]
except Exception as e:
    print(f"MongoDB connection failed: {e}")
    raise


# === Password hashing ===
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# === FastAPI app ===
app = FastAPI()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# === Helpers ===
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


# === Pydantic models ===
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


# === Auth dependencies ===
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


# === Routes ===
@app.get("/health")
async def health_check():
    try:
        # Run a simple command to ping the database
        await db.command("ping")
        return {"status": "MongoDB connected successfully"}
    except Exception as e:
        return {"status": "MongoDB connection failed", "error": str(e)}


@app.post("/register", response_model=UserOut)
async def register(user_in: UserIn):
    # Check duplicates
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
        "role": "user",  # always default
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }

    result = await users_collection.insert_one(doc)
    doc["id"] = str(result.inserted_id)

    return {
        "id": doc["id"],
        "username": doc["username"],
        "first_name": doc["first_name"],
        "last_name": doc["last_name"],
        "email": doc["email"],
        "telephone": doc["telephone"],
        "address": doc["address"],
        "role": doc["role"],
        "created_at": doc["created_at"],
    }

@app.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends()):
    # Accepts username or email
    query = {"$or": [{"email": form_data.username}, {"username": form_data.username}]}
    user = await users_collection.find_one(query)
    if not user or not verify_password(form_data.password, user["password_hash"]):
        raise HTTPException(status_code=400, detail="Incorrect username or password")

    access_token = create_access_token({"sub": str(user["_id"]), "role": user.get("role", "user")})
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=UserOut)
async def read_me(current_user=Depends(get_current_user)):
    return {
        "id": str(current_user["_id"]),
        "username": current_user["username"],
        "first_name": current_user["first_name"],
        "last_name": current_user["last_name"],
        "email": current_user["email"],
        "telephone": current_user["telephone"],
        "address": current_user["address"],
        "role": current_user.get("role", "user"),
        "created_at": current_user.get("created_at"),
    }

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
    return {
        "id": str(user["_id"]),
        "username": user["username"],
        "first_name": user["first_name"],
        "last_name": user["last_name"],
        "email": user["email"],
        "telephone": user["telephone"],
        "address": user["address"],
        "role": user.get("role", "user"),
        "created_at": user.get("created_at"),
    }

@app.get("/users", response_model=List[UserOut])
async def list_users(admin_user=Depends(require_admin)):
    cursor = users_collection.find().sort("created_at", -1).limit(100)
    users = []
    async for u in cursor:
        users.append({
            "id": str(u["_id"]),
            "username": u["username"],
            "first_name": u["first_name"],
            "last_name": u["last_name"],
            "email": u["email"],
            "telephone": u["telephone"],
            "address": u["address"],
            "role": u.get("role", "user"),
            "created_at": u.get("created_at")
        })
    return users

@app.delete("/users/{user_id}", status_code=204)
async def delete_user(user_id: str, admin_user=Depends(require_admin)):
    res = await users_collection.delete_one({"_id": ObjectId(user_id)})
    if res.deleted_count == 0:
        raise HTTPException(status_code=404, detail="User not found")
    return None