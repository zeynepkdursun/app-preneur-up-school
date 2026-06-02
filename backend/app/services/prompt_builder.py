from app.schemas.analysis import IngredientAnalysisRequest
class SkinLensPromptBuilder:
    
    @staticmethod
    def get_system_instruction() -> str:
        return (
            "Sen bir kozmetik formülasyon uzmanı ve kişiselleştirilmiş cilt analiz asistanısın.\n\n"
            "GÖREVİN:\n"
            "Gelen içerik listesini; ürün tipini, uygulama bölgesini, kullanıcının cilt tipini, "
            "hassasiyetlerini ve hedeflerini analiz etmektir.\n\n"
            "ANALİZ KURALLARI:\n"
            "1. Sadece 'caution' (dikkat) ve 'avoid' (kaçın) maddelerini listele. 'safe' olanları listeye ekleme[cite: 1].\n"
            "2. 'Hero Ingredients' kısmında, sadece kullanıcının HEDEFİYLE (Goal) doğrudan örtüşen maddeleri listele[cite: 1].\n"
            "3. Bir madde genel olarak faydalı olsa bile, kullanıcının HEDEFİNE aykırıysa veya kullanıcının HASSASİYET listesindeki "
            "bir maddeyi tetikliyorsa onu mutlaka 'caution' veya 'avoid' olarak işaretle ve nedenini açıkla[cite: 1].\n"
            "4. Açıklamalar (reason) kullanıcı hedefine/profiline özel olmalı ve KESİNLİKLE MAKSİMUM 7 KELİME olmalıdır[cite: 1]."
        )

    @staticmethod
    def build_user_prompt(request: IngredientAnalysisRequest) -> str:
        # Enum listelerini promptun anlayacağı temiz metinlere dönüştürüyoruz
        sensitivities_str = ", ".join([s.value for s in request.sensitivities]) if request.sensitivities else "Yok"
        goals_str = ", ".join([g.value for g in request.goals]) if request.goals else "Belirtilmemiş"

        return f"""
                [BAĞLAM VE KULLANICI PROFİLİ]
                - Uygulama Bölgesi: {request.application_area.value.upper()}
                - Ürün Tipi: {request.product_type.value.upper()}
                - Cilt Tipi: {request.skin_type.value.upper()}
                - Kullanıcı Hassasiyetleri: {sensitivities_str}
                - Kullanıcı Cilt Hedefleri: {goals_str}

                [İÇERİK LİSTESİ]:
                {request.ocr_text}
                [CRUCIAL HINT]:
                You must generate a valid JSON containing 'caution', 'avoid', and 'hero_ingredients' fields based on the rules. 
                Do not leave lists empty if there are clear matches like 'parfum' for sensitivity or 'urea' for goals.
                """