# backend/app/schemas/analysis.py
from pydantic import BaseModel, Field
from typing import List, Literal
from app.models.enums import ApplicationArea, ProductType, SkinType, Sensitivity, SkinGoal

class IngredientReportItem(BaseModel):
    ingredient: str = Field(description="INCI name of the ingredient")
    reason: str = Field(description="Max 7 words Turkish explanation")

"""class SkinLensAnalysisOutput(BaseModel):
    caution: List[IngredientReportItem] = Field(default=[])
    avoid: List[IngredientReportItem] = Field(default=[])
    hero_ingredients: List[IngredientReportItem] = Field(default=[])"""

class SkinLensAnalysisOutput(BaseModel):
    caution: List[IngredientReportItem] = Field(default=[], description="Ingredients to be careful about")
    avoid: List[IngredientReportItem] = Field(default=[], description="Ingredients to absolutely avoid")
    hero_ingredients: List[IngredientReportItem] = Field(default=[], description="Top beneficial active ingredients for user goals")
# --- REQUEST MODELİ ---
""" class IngredientAnalysisRequest(BaseModel):
    ocr_text: str = Field(..., description="Taranan ham içerik listesi metni")
    application_area: ApplicationArea = Field(..., description="Uygulama bölgesi")
    product_type: ProductType = Field(..., description="Ürün kategorisi")
    skin_type: SkinType = Field(..., description="Kullanıcının profilindeki sabit cilt tipi")
    sensitivities: List[Sensitivity] = Field(default=[], description="Kullanıcının profilindeki hassasiyetler")
    goals: List[SkinGoal] = Field(default=[], description="Kullanıcının profilindeki cilt hedefleri")
"""
class IngredientAnalysisRequest(BaseModel):
    ocr_text: str
    application_area: ApplicationArea
    product_type: ProductType
    skin_type: SkinType
    sensitivities: List[Sensitivity] = []
    goals: List[SkinGoal] = []