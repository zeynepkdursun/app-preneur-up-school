from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session
from app.db.session import get_session
from app.models.user import User, UserPublic
from app.schemas.user import ProfileUpdate

# DOĞRU İMPORT BURASI: auth yerine core.security kullanıyoruz
from app.core.security import get_current_user
router = APIRouter()

# HTTP POST yerine PUT veya PATCH kullanmak REST standartlarına daha uygundur
@router.put("/profile", response_model=UserPublic)
async def update_profile(
    profile_data: ProfileUpdate, 
    session: Session = Depends(get_session),
    current_user: User = Depends(get_current_user) # Spring Boot'taki @AuthenticationPrincipal gibi!
):
    """
    Flutter'daki Cilt Tipi Seçim Ekranından gelen verilerle, 
    giriş yapmış olan kullanıcının profilini günceller.
    """
    
    # Giriş yapmış kullanıcının alanlarını DTO'dan gelen verilerle güncelliyoruz
    current_user.skin_type = profile_data.skin_type
    
    if profile_data.sensitivities is not None:
        current_user.sensitivities = profile_data.sensitivities
        
    if profile_data.goals is not None:
        current_user.goals = profile_data.goals

    try:
        session.add(current_user)
        session.commit()
        session.refresh(current_user)
        return current_user # Geriye şifresiz UserPublic şeması dönecektir
    except Exception as e:
        session.rollback()
        raise HTTPException(status_code=500, detail=f"Profil güncellenirken hata oluştu: {str(e)}")