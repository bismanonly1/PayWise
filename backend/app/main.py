from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.shifts import router as shifts_router
from app.repositories.shifts import initialize_database


app = FastAPI(
    title="PayWise API",
    version="0.1.0",
    description="Personal payroll verification backend"
)

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"^http://(localhost|127\.0\.0\.1):\d+$",
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["*"],
)

initialize_database()
app.include_router(shifts_router)

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
