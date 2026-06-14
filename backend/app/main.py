from fastapi import FastAPI
from app.db.session import init_db
from app.api.v1.endpoints import ingredient
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.endpoints import auth
from app.api.v1.endpoints import ocr
app = FastAPI(title=settings.PROJECT_NAME, version="1.4")


# İzin verilen kökenler
origins = [
    "http://localhost",
    "http://localhost:8080", # Flutter web için genelde bu port kullanılır
    "*", # Geliştirme aşamasında tüm cihazların (emülatör/mobil) erişmesi için
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "version": "1.4-mobile-hybrid"}

@app.get("/")
def root():
    return {"status": "SkinLens Backend Online", 
            "message": f"Welcome to {settings.PROJECT_NAME}"}
# Route'ları bağla
app.include_router(ingredient.router, prefix="/api/v1/ingredient", tags=["Ingredients"])


# app/main.py içinde bir yere ekle:
from app.api.v1.endpoints import user
app.include_router(user.router, prefix="/api/v1/users", tags=["users"])

# Swagger: http://localhost:8000/docs

app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])

app.include_router(ocr.router, prefix="/api/v1/ocr", tags=["OCR"])