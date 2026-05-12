from fastapi import APIRouter, Depends, Query, HTTPException
from sqlmodel import Session
from app.db.session import get_session
from app.repository.ingredient import IngredientRepository
from app.models.ingredient import IngredientsMaster
from typing import List
from app.models.enums import RiskLevel
router = APIRouter()

@router.get("/search", response_model=List[IngredientsMaster])
def search_ingredients(
    q: str = Query(..., min_length=2, description="Aramak istediğiniz içerik adı veya takma adı"),
    session: Session = Depends(get_session)
):
    repo = IngredientRepository(session)
    results = repo.search_by_name_or_alias(q)
    return results

@router.post("/seed", status_code=201)
def seed_ingredients(session: Session = Depends(get_session)):
    """Aşama 2: Örnek verilerin toplu girişi (Bulk Insert)"""
    repo = IngredientRepository(session)
    
    sample_data = [
        IngredientsMaster(
            inci_name="Hyaluronic Acid", 
            aliases=["Hiyalüronik Asit", "HA"], 
            description_tr="Cildi nemlendirir ve dolgunlaştırır.",
            general_risk_level=RiskLevel.SAFE
        ),
        IngredientsMaster(
            inci_name="Niacinamide", 
            aliases=["B3 Vitamini", "Nikotinamid"], 
            description_tr="Gözenek görünümünü azaltır, cilt bariyerini güçlendirir.",
            general_risk_level=RiskLevel.SAFE
        ),
        IngredientsMaster(
            inci_name="Sodium Laureth Sulfate", 
            aliases=["SLES", "SLS"], 
            description_tr="Yüzey aktif madde. Hassas ciltlerde kuruluk yapabilir.",
            general_risk_level=RiskLevel.CAUTION
        ),
        IngredientsMaster(
            inci_name="Retinol", 
            aliases=["A Vitamini"], 
            description_tr="Yaşlanma karşıtı ve yenileyici içerik.",
            general_risk_level=RiskLevel.SAFE
        ),
        # ... Diğer maddeler buraya eklenebilir
    ]
    
    try:
        repo.bulk_insert(sample_data)
        return {"message": f"{len(sample_data)} madde başarıyla eklendi."}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))