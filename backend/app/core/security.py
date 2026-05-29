from datetime import datetime, timedelta
from typing import Optional
from jose import jwt, JWTError
from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
import bcrypt
# İhtiyacımız olan tüm FastAPI bağımlılıklarını buraya ekledik:
from fastapi import Depends, HTTPException, status

# Veritabanı sorguları ve Modeller için gerekli importlar:
from sqlmodel import Session, select
from app.db.session import get_session
from app.models.user import User

# Güvenlik Ayarları
PWD_CONTEXT = CryptContext(schemes=["bcrypt"], deprecated="auto")
SECRET_KEY = "SÜPER_GİZLİ_ANAHTAR"  # Gerçek projede bunu .env dosyasında saklamalısın
ALGORITHM = "HS256"

def hash_password(password: str) -> str:
    # Şifreyi byte formatına çevir
    pwd_bytes = password.encode('utf-8')
    # Tuz (salt) oluştur ve hash'le
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pwd_bytes, salt).decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return bcrypt.checkpw(
        plain_password.encode('utf-8'), 
        hashed_password.encode('utf-8')
    )

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """JWT Token oluşturur."""
    to_encode = data.copy()
    expire = datetime.utcnow() + (expires_delta or timedelta(minutes=60))
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)

# OAuth2 şeması (Token'ın nereden alınacağını belirtir)
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/v1/auth/token")

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_session)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,  # Küçük bir yazım hatası düzeltildi: 01 yerine 401
        detail="Geçersiz kimlik bilgileri.",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        # Sabit string yerine yukarıdaki SECRET_KEY değişkenini verdik
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
        
    user = db.exec(select(User).where(User.email == email)).first()
    if user is None:
        raise credentials_exception
    return user