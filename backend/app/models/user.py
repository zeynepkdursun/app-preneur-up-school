from sqlmodel import SQLModel, Field, Column
from sqlalchemy.dialects.postgresql import JSONB
from typing import Optional, Dict, List
from app.models.enums import SkinType

class User(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(unique=True, index=True)
    skin_type: SkinType
    # JSONB alanları için sa_column kullanıyoruz
    goals: Dict[str, List[str]] = Field(default={}, sa_column=Column(JSONB))
    sensitivities: List[str] = Field(default=[], sa_column=Column(JSONB))
    favorites: List[int] = Field(default=[], sa_column=Column(JSONB))