from pydantic import BaseModel
from typing import Dict, Optional
from app.models.enums import SkinType # Daha önce enums.py'da tanımladığın varsayımıyla

class ProfileUpdate(BaseModel):
    # Frontend'den gelecek veri yapısı
    skin_type: str
    sensitivities: Dict[str, bool] # {"Alkol": true, "Parfüm": false} gibi