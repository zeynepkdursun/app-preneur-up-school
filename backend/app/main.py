from fastapi import FastAPI
from app.db.session import init_db
from app.api.v1.endpoints import ingredient

app = FastAPI(title="SkinLens API", version="1.4")

@app.on_event("startup")
def on_startup():
    init_db()

@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "healthy", "version": "1.4-mobile-hybrid"}

@app.get("/")
def root():
    return {"status": "SkinLens Backend Online"}
# Route'ları bağla
app.include_router(ingredient.router, prefix="/api/v1/ingredient", tags=["Ingredients"])

# Swagger: http://localhost:8000/docs