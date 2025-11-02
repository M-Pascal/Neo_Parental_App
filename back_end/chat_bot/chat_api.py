from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
from openai import OpenAI
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI(title="NeoParental Assistant API")

# Allow Flutter to talk to this backend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # You can restrict this to your Flutter app's domain later
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class Message(BaseModel):
    message: str

@app.post("/chat")
def chat_endpoint(data: Message):
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

    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            system_message,
            {"role": "user", "content": data.message},
        ],
        max_tokens=60,
        temperature=0.8
    )

    return {"reply": response.choices[0].message.content.strip()}
