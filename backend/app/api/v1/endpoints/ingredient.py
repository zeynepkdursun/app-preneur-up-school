# backend/app/api/v1/endpoints/ingredient.py
from fastapi import APIRouter, HTTPException
from app.schemas.analysis import IngredientAnalysisRequest, SkinLensAnalysisOutput
from app.services.ai_service import OpenRouterAIService

router = APIRouter()


@router.post("/analyze", response_model=SkinLensAnalysisOutput)
async def analyze_ingredients(payload: IngredientAnalysisRequest):
    if not payload.ocr_text.strip():
        raise HTTPException(status_code=400, detail="İçerik listesi boş bırakılamaz.")

    analysis_report = await OpenRouterAIService.analyze_ingredients(payload)
    return SkinLensAnalysisOutput.model_validate(analysis_report)
