from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from app.db.session import get_session # get_db yerine bunu kullanıyoruz
from app.models.user import User
from app.schemas.user import ProfileUpdate

router = APIRouter()
@router.post("/profile")
async def update_profile(
    profile_data: ProfileUpdate, 
    session: Session = Depends(get_session)
):
    statement = select(User).where(User.id == 1)
    user = session.exec(statement).first()
    
    if not user:
        # HATA ÇÖZÜMÜ: Boş kalan username ve zorunlu alanları dolduruyoruz
        user = User(
            id=1, 
            username="test_user", # None yerine bir değer verelim
            skin_type=profile_data.skin_type,
            goals={},             # Boş JSON objesi
            sensitivities=profile_data.sensitivities,
            favorites=[]          # Boş liste
        )
        session.add(user)
    else:
        # Mevcut kullanıcıyı güncelle
        user.skin_type = profile_data.skin_type
        user.sensitivities = profile_data.sensitivities
        session.add(user)
    
    try:
        session.commit()
        session.refresh(user)
    except Exception as e:
        session.rollback() # Hata olursa işlemi geri al
        raise HTTPException(status_code=500, detail=f"Veritabanı hatası: {str(e)}")
    
    return {"status": "success", "user_id": user.id}