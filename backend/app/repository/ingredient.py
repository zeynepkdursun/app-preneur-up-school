from typing import List, Optional
from sqlalchemy import or_, func
from sqlmodel import Session, select
from app.models.ingredient import IngredientsMaster

class IngredientRepository:
    def __init__(self, session: Session):
        self.session = session

    def bulk_insert(self, ingredients: List[IngredientsMaster]):
        """Veritabanına toplu madde girişi yapar."""
        self.session.add_all(ingredients)
        self.session.commit()

    def search_by_name_or_alias(self, query: str) -> List[IngredientsMaster]:
        """INCI ismi veya alias (JSONB) içinde arama yapar."""
        search_query = f"%{query.lower()}%"
        
        # PostgreSQL JSONB içerisindeki alias'ları ve inci_name'i kontrol eder
        statement = select(IngredientsMaster).where(
            or_(
                func.lower(IngredientsMaster.inci_name).contains(query.lower()),
                # JSONB alias listesi içinde herhangi bir eşleşme var mı kontrolü
                IngredientsMaster.aliases.cast(str).ilike(search_query)
            )
        )
        results = self.session.exec(statement).all()
        return results