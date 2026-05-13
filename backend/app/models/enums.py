from enum import Enum
from pydantic import BaseModel
from typing import List, Optional, Dict

class SkinType(str, Enum):
    COMBINATION = "COMBINATION"
    OILY = "OILY"
    DRY = "DRY"
    NORMAL = "NORMAL"
    SENSITIVE = "SENSITIVE"

class RiskLevel(str, Enum):
    SAFE = "SAFE"
    CAUTION = "CAUTION"
    AVOID = "AVOID"

    # PRD 3.3 & 3.4: Analiz Çıktısı Parçaları
class IngredientAnalysis(BaseModel):
    ingredient: str
    safety: RiskLevel
    reason: Optional[str] = None  # Safe içerikler için null

# PRD 4.4: Ana API Yanıtı
class AnalysisResponse(BaseModel):
    product_type: str
    alerts: List[IngredientAnalysis]
    hero_ingredients: List[Dict[str, str]]
    overall_recommendation: Dict[str, str]