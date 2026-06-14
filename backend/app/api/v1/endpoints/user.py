from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.db.session import get_session
from app.models.user import User, UserPublic
from app.schemas.user import ProfileUpdate

# DOĞRU İMPORT BURASI: auth yerine core.security kullanıyoruz
from app.core.security import get_current_user
router = APIRouter()
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from fastapi import Request

@router.get("/profile", response_model=UserPublic)
async def get_profile(
    current_user: User = Depends(get_current_user),
):
    return current_user


# HTTP POST yerine PUT veya PATCH kullanmak REST standartlarına daha uygundur
@router.put("/profile", response_model=UserPublic)
async def update_profile(
    profile_data: ProfileUpdate, 
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user)
):
    current_user.skin_type = profile_data.skin_type
    
    # Verileri SQLModel/PostgreSQL'in seveceği temiz Python tiplerine zorluyoruz
    if profile_data.sensitivities is not None:
        current_user.sensitivities = list(profile_data.sensitivities)
        
    if profile_data.goals is not None:
        current_user.goals = dict(profile_data.goals)

    try:
        session.add(current_user)
        session.commit()
        session.refresh(current_user)
        return current_user
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Profil güncellenirken hata oluştu: {str(e)}")