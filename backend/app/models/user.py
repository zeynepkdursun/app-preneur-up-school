from sqlmodel import SQLModel, Field, Column
from sqlalchemy.dialects.postgresql import JSONB
from typing import Optional, Dict, List
from app.models.enums import SkinType

# 1. ORTAK ALANLAR (Temel Veri Yapısı)
class UserBase(SQLModel):
    username: str = Field(unique=True, index=True)
    email: str = Field(unique=True, index=True)
    
    # Bu alanları 'Optional' (İsteğe bağlı) ve varsayılan değerli yaptık.
    # Böylece ilk kayıtta gönderilmeleri zorunlu olmayacak.
    skin_type: Optional[SkinType] = Field(default=None, nullable=True)
    goals: Dict[str, List[str]] = Field(default={}, sa_column=Column(JSONB))
    sensitivities: List[str] = Field(default=[], sa_column=Column(JSONB))
    favorites: List[int] = Field(default=[], sa_column=Column(JSONB))

# 2. VERİTABANI TABLOSU
class User(UserBase, table=True): # Java'daki @Entity ve @Table(name="user")
    id: Optional[int] = Field(default=None, primary_key=True)
    hashed_password: str

# 3. İLK KAYIT ESNASINDA İSTENEN VERİ (Request Body)
class UserCreate(SQLModel):
    username: str
    email: str
    password: str

# 4. PROFİL GÜNCELLEME ESNASINDA İSTENEN VERİ (Request Body)
class UserUpdate(SQLModel):
    skin_type: Optional[SkinType] = None
    goals: Optional[Dict[str, List[str]]] = None
    sensitivities: Optional[List[str]] = None

# 5. API'DEN DIŞARIYA DÖNEN VERİ (Response Body)
class UserPublic(UserBase):
    id: int