from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="PayWise API",
    version="0.1.0",
    description="Personal payroll verification backend"
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1):\d+$",
    allow_credentials=False,
    allow_methods=["GET"],
    allow_headers=["*"]
)

@app.get("/")
def home():
    return {
        "app": "PayWise",
        "message": "Welcome to PayWise API"
    }

@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "service": "paywise-backend"
    }
