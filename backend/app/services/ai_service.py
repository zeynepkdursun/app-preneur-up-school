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
    def _normalize_ai_payload(raw_content: str) -> str:
        """Model bazen 'ingredient' yerine 'item' döndürüyor; şemaya uyarlıyoruz."""
        data = json.loads(raw_content)
        for key in ("caution", "avoid", "hero_ingredients"):
            items = data.get(key)
            if not isinstance(items, list):
                continue
            for entry in items:
                if not isinstance(entry, dict) or "ingredient" in entry:
                    continue
                if "item" in entry:
                    entry["ingredient"] = entry.pop("item")
                elif "name" in entry:
                    entry["ingredient"] = entry.pop("name")
        return json.dumps(data, ensure_ascii=False)
    
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
                normalized_content = OpenRouterAIService._normalize_ai_payload(raw_content)

                validated_data = SkinLensAnalysisOutput.model_validate_json(normalized_content)
                output = validated_data.model_dump()

                if not any([output["caution"], output["avoid"], output["hero_ingredients"]]):
                    raise HTTPException(
                        status_code=502,
                        detail=(
                            "AI analizi boş döndü. Swagger'da örnek gövdeyi kullanın: "
                            "sensitivities (ör. [\"parfum\"]) ve goals (ör. [\"yag_dengeleme\"]) alanlarını doldurun."
                        ),
                    )

                return output
                
            except httpx.HTTPStatusError as e:
                raise HTTPException(status_code=e.response.status_code, detail=f"OpenRouter Bağlantı Hatası: {e.response.text}")
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"AI Analiz Motoru Hatası: {str(e)}")