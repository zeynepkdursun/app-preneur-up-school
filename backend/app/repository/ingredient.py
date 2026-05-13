from typing import List, Optional
from sqlalchemy import or_, func, String  # <--- String buraya eklendi
from sqlmodel import Session, select
from app.models.ingredient import IngredientsMaster

class IngredientRepository:
    def __init__(self, session: Session):
        self.session = session

    def bulk_insert(self, ingredients: List[IngredientsMaster]):
        self.session.add_all(ingredients)
        self.session.commit()

    def search_by_name_or_alias(self, query: str) -> List[IngredientsMaster]:
        # Eğer sorgu boşsa veya None ise direkt boş liste döndür (ya da tümünü)
        if not query:
            return []
        search_term = query.lower()
        
        statement = select(IngredientsMaster).where(
            or_(
                func.lower(IngredientsMaster.inci_name).contains(search_term),
                # Artık 'String' tanımlı olduğu için cast işlemi hata vermeyecek
                IngredientsMaster.aliases.cast(String).ilike(f"%{search_term}%")
            )
        )
        return self.session.exec(statement).all()

    def get_all(self):
        return self.session.exec(select(IngredientsMaster)).all()