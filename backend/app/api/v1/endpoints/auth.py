from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlmodel import Session, select
from app.db.session import get_session
from app.models.user import User, UserPublic
from app.schemas.user import UserCreateSchema  # Yeni DTO'muzu import ettik
from app.core.security import hash_password, verify_password, create_access_token
from app.schemas.user import UserCreateSchema, Token  # Token şemasını da ekledik

router = APIRouter()

@router.post("/signup", response_model=UserPublic)
def signup(user_in: UserCreateSchema, db: Session = Depends(get_session)):
    # 1. E-posta kontrolü (Spring Boot: userRepository.findByEmail)
    user = db.exec(select(User).where(User.email == user_in.email)).first()
    if user:
        raise HTTPException(status_code=400, detail="Bu e-posta zaten kayıtlı.")
        
    if len(user_in.password.encode('utf-8')) > 72:
        raise HTTPException(
            status_code=400, 
            detail="Şifre 72 karakterden uzun olamaz."
        )
        
    # 2. DTO'dan Veritabanı Entity nesnesine eşleme (Mapping)
    # Cilt tipi ve hedefler ilk kayıt anında boş (default) olarak set edilir.
    db_user = User(
        username=user_in.username,
        email=user_in.email,
        hashed_password=hash_password(user_in.password),
        skin_type=None,
        goals={},
        sensitivities=[],
        favorites=[]
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user) # Generated ID'yi almak için refresh yapıyoruz
    return db_user


# --- EKSİK OLAN LOGIN / TOKEN ENDPOINT'İ BURASI ---
@router.post("/token", response_model=Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(), 
    db: Session = Depends(get_session)
):
    """
    Swagger UI kilit butonu ve Flutter giriş ekranı burayı tetikler.
    Kullanıcı adı olarak girilen veriyi e-posta olarak kabul edip doğrulama yapar.
    """
    # 1. Kullanıcıyı e-posta adresine göre DB'den çek (form_data.username burada girilen email'i tutar)
    user = db.exec(select(User).where(User.email == form_data.username)).first()
    
    # 2. Kullanıcı var mı ve şifre doğru mu kontrol et
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-posta veya şifre hatalı.",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 3. JWT Token üret (Spring Boot'taki JWT token generation yapısı)
    # Token içine 'sub' (subject) olarak kullanıcının email bilgisini gömüyoruz
    access_token = create_access_token(data={"sub": user.email})
    
    # Bearer token formatında yanıt dönüyoruz
    return {"access_token": access_token, "token_type": "bearer"}