from fastapi import FastAPI
from app.db.session import init_db

app = FastAPI(title="SkinLens API", version="1.4")

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "version": "1.4-mobile-hybrid"}

# Swagger: http://localhost:8000/docs