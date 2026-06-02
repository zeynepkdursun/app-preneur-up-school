# backend/app/services/ai_service.py

import json
import httpx
from fastapi import HTTPException
from app.schemas.analysis import SkinLensAnalysisOutput, IngredientAnalysisRequest
from app.services.prompt_builder import SkinLensPromptBuilder
import os 
from dotenv import load_dotenv

# .env dosyasını yükle
load_dotenv()

# Anahtarı değişkene ata
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

class OpenRouterAIService:
    """
    SOLID - Single Responsibility: Sadece OpenRouter API entegrasyonu
    ve ham verinin şemaya uygun doğrulanmasından sorumludur.
    """
    
    @staticmethod
    async def analyze_ingredients(request: IngredientAnalysisRequest) -> dict:
        system_instruction = SkinLensPromptBuilder.get_system_instruction()
        user_prompt = SkinLensPromptBuilder.build_user_prompt(request)
        
        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "Content-Type": "application/json"
        }
        
        data = {
            "model": "google/gemini-2.5-flash",
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": user_prompt}
            ],
            "response_format": {
                "type": "json_object",
                "schema": SkinLensAnalysisOutput.model_json_schema()
            },
            "temperature": 0.4,
            "max_tokens": 1000
        }
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.post(OPENROUTER_URL, headers=headers, json=data)
                response.raise_for_status()
                
                result = response.json()
                raw_content = result['choices'][0]['message']['content']
                
                # Model kurallara uymuş mu diye Pydantic şemamız üzerinden süzüyoruz
                validated_data = SkinLensAnalysisOutput.model_validate_json(raw_content)
                
                return validated_data.model_dump()
                
            except httpx.HTTPStatusError as e:
                raise HTTPException(status_code=e.response.status_code, detail=f"OpenRouter Bağlantı Hatası: {e.response.text}")
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"AI Analiz Motoru Hatası: {str(e)}")