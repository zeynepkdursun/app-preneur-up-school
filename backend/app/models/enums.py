from enum import Enum
from pydantic import BaseModel
from typing import List, Optional, Dict

class SkinType(str, Enum):
    OILY = "yagli"
    DRY = "kuru"
    COMBINATION = "karma"
    NORMAL = "normal"
    SENSITIVE = "hassas"

class ApplicationArea(str, Enum):
    YUZ = "yuz"
    EL = "el"
    VUCUT = "vucut"
    SAC = "sac"

class ProductType(str, Enum):
    YUZ_NEMLENDIRICI = "yuz_nemlendiricisi"
    GUNES_KREMI = "gunes_kremi"
    TONIK = "tonik"
    YUZ_TEMIZLEME_JELI = "yuz_temizleme_jeli"
    EL_KREMI = "el_kremi"
    VUCUT_LOSYONU = "vucut_losyonu"
    SAMPUAN = "sampuan"

class Sensitivity(str, Enum):
    PARFUM = "parfum"
    ALKOL = "alkol"
    ARBUTIN = "arbutin"
    KUVVETLI_ASITLER = "kuvvetli_asitler"
    GLUTEN = "gluten"

class SkinGoal(str, Enum):
    PULLANMAYI_ONLEME = "pullanmayi_onleme"
    YAG_DENGELEME = "yag_dengeleme"
    LEKE_ACMA = "leke_acma"
    BARIYER_GUCLENDIRME = "bariyer_guclendirme"
    AKNE_KARSITI = "akne_karsiti"


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