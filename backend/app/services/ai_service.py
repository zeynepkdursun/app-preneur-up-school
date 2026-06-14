# backend/app/services/ai_service.py

import json
import re
import httpx
from fastapi import HTTPException
from app.schemas.analysis import SkinLensAnalysisOutput, IngredientAnalysisRequest
from app.services.prompt_builder import SkinLensPromptBuilder
from app.services.ingredient_knowledge import classify_ingredients
import os 
from dotenv import load_dotenv

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions"

SKIN_TYPES_MAP = {"yagli": "oily", "kuru": "dry", "karma": "combination", "hassas": "sensitive"}

SENSITIVITY_MAP = {
    "parfum": "Parfum", "parfuem": "Parfum",
    "alkol": "Alcohol Denat.",
    "alkoller": "Alcohol Denat.",
    "sles": "Sodium Laureth Sulfate",
    "sls": "Sodium Lauryl Sulfate",
    "silikon": "Dimethicone",
    "retinol": "Retinol",
}


class OpenRouterAIService:

    @staticmethod
    def _normalize_ai_payload(raw_content: str) -> str:
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
    def _parse_ingredient_lines(raw_text: str) -> list[str]:
        cleaned = re.sub(r"(?:^|\n)\s*(?:İçindekiler|Ingredients|INCI|Bileşenler)\s*[:]\s*", ",", raw_text, flags=re.IGNORECASE)
        parts = re.split(r"[,;]\s*", cleaned)
        seen = set()
        result = []
        for p in parts:
            p = p.strip().strip(".")
            if not p:
                continue
            if len(p) < 2:
                continue
            if re.match(r"^\d+\s*(ml|gr|g|oz|l|kg)$", p, re.IGNORECASE):
                continue
            if re.match(r"^(kullanım|üretici|son.tüketim|üretim|seri|barkod)", p, re.IGNORECASE):
                continue
            key = p.lower()
            if key not in seen:
                seen.add(key)
                result.append(p)
        return result

    @staticmethod
    async def analyze_ingredients(request: IngredientAnalysisRequest) -> dict:
        skin_type_key = SKIN_TYPES_MAP.get(request.skin_type.value, "oily")
        raw_text = request.ocr_text

        ingredient_names = OpenRouterAIService._parse_ingredient_lines(raw_text)

        rule_result = classify_ingredients(ingredient_names, skin_type_key, request.sensitivities)

        known_ingredients = set()
        for lst in [rule_result["hero_ingredients"], rule_result["caution"], rule_result["avoid"]]:
            for item in lst:
                known_ingredients.add(item["ingredient"].lower())

        unknown_ingredients = [n for n in ingredient_names if n.lower() not in known_ingredients]

        if not unknown_ingredients:
            return SkinLensAnalysisOutput(
                hero_ingredients=rule_result["hero_ingredients"],
                caution=rule_result["caution"],
                avoid=rule_result["avoid"],
            ).model_dump()

        def fmt_list(items: list[dict]) -> str:
            return "\n".join(f'  - "{i["ingredient"]}": {i["level"]} — {i["reason"]}' for i in items)

        known_section = ""
        if rule_result["hero_ingredients"] or rule_result["caution"] or rule_result["avoid"]:
            known_section = (
                "Kurallarla önceden analiz edilen maddeler (bunları tekrar listeleme):\n"
                "  HERO:\n" + fmt_list(rule_result["hero_ingredients"]) + "\n"
                "  CAUTION:\n" + fmt_list(rule_result["caution"]) + "\n"
                "  AVOID:\n" + fmt_list(rule_result["avoid"]) + "\n\n"
                "Analiz edilmemiş maddeler (bunları sen değerlendir):\n"
            )

        unknown_text = ", ".join(unknown_ingredients)

        hybrid_prompt = (
            f"[BAĞLAM VE KULLANICI PROFİLİ]\n"
            f"- Uygulama Bölgeleri: {', '.join(a.value.upper() for a in request.application_area)}\n"
            f"- Ürün Tipi: {request.product_type.value.upper()}\n"
            f"- Cilt Tipi: {request.skin_type.value.upper()}\n"
            f"- Kullanıcı Hassasiyetleri: {', '.join(s.value for s in request.sensitivities) if request.sensitivities else 'Yok'}\n"
            f"- Kullanıcı Cilt Hedefleri: {', '.join(g.value for g in request.goals) if request.goals else 'Belirtilmemiş'}\n\n"
            f"[İÇERİK LİSTESİ]:\n{unknown_text}\n\n"
            f"[ÖN ANALİZ SONUÇLARI]:\n{known_section}"
            f"[TALİMAT]:\n"
            f"Sadece 'Analiz edilmemiş maddeler' listesindeki INCI maddelerini cilt tipi rehberine göre sınıflandır.\n"
            f"Önceden analiz edilen maddeleri tekrar listeleme.\n"
            f"JSON formatında 'hero_ingredients', 'caution', 'avoid' arrayleri döndür.\n"
            f"Her öğede 'ingredient' ve 'reason' (maks 10 kelime) alanları zorunlu.\n"
            f"Hiçbir yeni madde eşleşmezse boş array döndür."
        )

        system_instruction = SkinLensPromptBuilder.get_system_instruction()

        headers = {
            "Authorization": f"Bearer {OPENROUTER_API_KEY}",
            "Content-Type": "application/json"
        }

        data = {
            "model": "google/gemini-2.5-flash",
            "messages": [
                {"role": "system", "content": system_instruction},
                {"role": "user", "content": hybrid_prompt}
            ],
            "response_format": {
                "type": "json_object",
                "schema": SkinLensAnalysisOutput.model_json_schema()
            },
            "temperature": 0.2,
            "max_tokens": 2000
        }

        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.post(OPENROUTER_URL, headers=headers, json=data)
                response.raise_for_status()

                result = response.json()
                raw_content = result['choices'][0]['message']['content']
                normalized_content = OpenRouterAIService._normalize_ai_payload(raw_content)
                ai_data = json.loads(normalized_content)

                merged = {
                    "hero_ingredients": (
                        rule_result["hero_ingredients"] + ai_data.get("hero_ingredients", [])
                    ),
                    "caution": (
                        rule_result["caution"] + ai_data.get("caution", [])
                    ),
                    "avoid": (
                        rule_result["avoid"] + ai_data.get("avoid", [])
                    ),
                }

                validated_data = SkinLensAnalysisOutput.model_validate(merged)
                output = validated_data.model_dump()

                if not any([output["caution"], output["avoid"], output["hero_ingredients"]]):
                    raise HTTPException(
                        status_code=502,
                        detail="AI analizi boş döndü. sensitivities ve goals alanlarını doldurun.",
                    )

                return output

            except httpx.HTTPStatusError as e:
                raise HTTPException(status_code=e.response.status_code, detail=f"OpenRouter Bağlantı Hatası: {e.response.text}")
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"AI Analiz Motoru Hatası: {str(e)}")