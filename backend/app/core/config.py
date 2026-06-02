from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # .env içindeki karşılıkları
    DATABASE_URL: str
    GEMINI_API_KEY: str
    PROJECT_NAME: str = "SkinLens API"
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    # Pydantic'e .env dosyasını okumasını söylüyoruz
    model_config = SettingsConfigDict(
        env_file=".env", 
         env_file_encoding="utf-8",
        extra="ignore"  # Sınıfta tanımlı olmayan değişkenleri görmezden gel
    )

settings = Settings()