from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # .env içindeki karşılıkları
    DATABASE_URL: str
    GEMINI_API_KEY: str
    PROJECT_NAME: str = "SkinLens API"

    # Hata veren kısmı burası düzeltiyor:
    model_config = SettingsConfigDict(
        env_file=".env", 
        extra="ignore"  # Sınıfta tanımlı olmayan değişkenleri görmezden gel
    )

settings = Settings()