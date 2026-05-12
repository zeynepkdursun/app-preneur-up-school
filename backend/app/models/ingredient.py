from sqlmodel import SQLModel, Field, Column
from sqlalchemy.dialects.postgresql import JSONB
from typing import Optional, List
from app.models.enums import RiskLevel

class Ingredient(SQLModel, table=True):
    __tablename__ = "ingredients_master"
    
    id: Optional[int] = Field(default=None, primary_key=True)
    inci_name: str = Field(index=True, unique=True)
    aliases: List[str] = Field(default=[], sa_column=Column(JSONB)) #
    description_tr: str
    general_risk_level: RiskLevel = Field(default=RiskLevel.SAFE)