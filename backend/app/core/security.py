from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import jwt, JWTError
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
import bcrypt
from fastapi import Depends, HTTPException, status
from sqlmodel import Session, select

from app.db.session import get_session
from app.models.user import User
from app.core.config import settings  # Ayarlarımızı içeri alıyoruz

# Güvenlik Ayarları (Artık şifreleme motoru passlib yerine direkt bcrypt kütüphanenle yönetiliyor)
PWD_CONTEXT = CryptContext(schemes=["bcrypt"], deprecated="auto")

# OAuth2 şeması: Flutter'ın token'ı HTTP Header'da 'Authorization: Bearer <token>' olarak göndereceğini belirtir.
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/token")

def hash_password(password: str) -> str:
    pwd_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(
        plain_password.encode('utf-8'), 
        hashed_password.encode('utf-8')
    )

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    
    # Eğer özel bir süre verilmediyse .env'den gelen ACCESS_TOKEN_EXPIRE_MINUTES'ı kullanıyoruz
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        
    to_encode.update({"exp": expire})
    
    # ARTIK GÜVENLİ: .env dosyasından okunan SECRET_KEY ve ALGORITHM kullanılıyor
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_session)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Geçersiz kimlik bilgileri.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # ARTIK GÜVENLİ: Çözerken de .env'deki SECRET_KEY ve ALGORITHM kullanılıyor
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    user = db.exec(select(User).where(User.email == email)).first()
    if user is None:
        raise credentials_exception
    return user