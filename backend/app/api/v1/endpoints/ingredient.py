# backend/app/api/v1/endpoints/ingredient.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from app.schemas.analysis import IngredientAnalysisRequest, SkinLensAnalysisOutput 
from app.services.ai_service import OpenRouterAIService
from app.models.enums import ApplicationArea, ProductType, SkinType, Sensitivity, SkinGoal

router = APIRouter()

class IngredientAnalysisRequest(BaseModel):
    ocr_text: str = Field(..., description="Taranan ham içerik listesi metni")
    application_area: ApplicationArea = Field(..., description="Uygulama bölgesi")
    product_type: ProductType = Field(..., description="Ürün kategorisi")
    skin_type: SkinType = Field(..., description="Kullanıcının profilindeki sabit cilt tipi")
    sensitivities: list[Sensitivity] = Field(default=[], description="Kullanıcının profilindeki hassasiyetler")
    goals: list[SkinGoal] = Field(default=[], description="Kullanıcının profilindeki cilt hedefleri")

@router.post("/analyze", response_model=SkinLensAnalysisOutput)
async def analyze_ingredients(payload: IngredientAnalysisRequest):
    if not payload.ocr_text.strip():
        raise HTTPException(status_code=400, detail="İçerik listesi boş bırakılamaz.")
        
    analysis_report = await OpenRouterAIService.analyze_ingredients(payload)
    return analysis_report