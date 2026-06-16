# backend/app/schemas/analysis.py
from pydantic import BaseModel, Field, ConfigDict
from typing import List
from app.models.enums import ApplicationArea, ProductType, SkinType, Sensitivity, SkinGoal

class IngredientReportItem(BaseModel):
    ingredient: str = Field(description="INCI name of the ingredient")
    reason: str = Field(description="Max 7 words Turkish explanation")

class SkinLensAnalysisOutput(BaseModel):
    caution: List[IngredientReportItem] = Field(default=[], description="Ingredients to be careful about")
    avoid: List[IngredientReportItem] = Field(default=[], description="Ingredients to absolutely avoid")
    hero_ingredients: List[IngredientReportItem] = Field(default=[], description="Top beneficial active ingredients for user goals")

class IngredientAnalysisRequest(BaseModel):
    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "ocr_text": "Aqua, Glycerin, Parfum, Zinc PCA, Sodium Laureth Sulfate",
                "application_area": ["yuz", "vucut"],  # Artık liste olarak gönderilebiliyor
                "product_type": "gunes_kremi",
                "skin_type": "yagli",
                "sensitivities": ["parfum"],
                "goals": ["yag_dengeleme"],
            }
        }
    )

    ocr_text: str = Field(..., description="Taranan ham içerik listesi metni")
    partial_scan: bool = Field(default=False, description="OCR ingredients başlığı bulunamadıysa True, metin gürültülü olabilir")
    # Tekil Enum yerine List[ApplicationArea] yapısına geçtik
    application_area: List[ApplicationArea] = Field(..., min_items=1, description="Uygulama bölgeleri (yuz, el, vucut, sac)")
    product_type: ProductType = Field(..., description="Ürün kategorisi")
    skin_type: SkinType = Field(..., description="Kullanıcının cilt tipi")
    sensitivities: List[Sensitivity] = Field(default=[], description="Hassasiyetler — boş bırakılırsa analiz zayıflar")
    goals: List[SkinGoal] = Field(default=[], description="Cilt hedefleri — boş bırakılırsa hero listesi boş kalır")