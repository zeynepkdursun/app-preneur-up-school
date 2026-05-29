from pydantic import BaseModel, EmailStr
from typing import Dict, Optional, List
from app.models.enums import SkinType

# JWT Token yanıtı için (Değişmedi)
class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

# 1. AŞAMA: Flutter Bottom Sheet'ten gelecek Kayıt DTO'su (Request)
class UserCreateSchema(BaseModel):
    username: str
    email: EmailStr
    password: str

# 2. AŞAMA: Flutter Skin Type Seçim Ekranından gelecek Profil Güncelleme DTO'su (Request)
class ProfileUpdate(BaseModel):
    skin_type: SkinType
    # Esneklik için dictionary veya liste olarak alabiliriz, enums'a göre senkronize ettik:
    sensitivities: Optional[List[str]] = []
    goals: Optional[Dict[str, List[str]]] = {}