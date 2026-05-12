from sqlmodel import create_engine, SQLModel, Session
from app.core.config import settings

engine = create_engine(settings.DATABASE_URL, echo=True)

def init_db():
    # Sadece keşif (discovery) için importlar
    from app.models.user import User
    from app.models.ingredient import IngredientsMaster
    SQLModel.metadata.create_all(engine)

def get_session():
    with Session(engine) as session:
        yield session