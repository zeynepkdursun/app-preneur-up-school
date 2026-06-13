# backend/app/services/prompt_builder.py
from app.schemas.analysis import IngredientAnalysisRequest

class SkinLensPromptBuilder:
    
    @staticmethod
    def get_system_instruction() -> str:
        return (
            "Sen bir kozmetik formülasyon uzmanı ve kişiselleştirilmiş cilt analiz asistanısın.\n\n"
            "GÖREVİN:\n"
            "Gelen içerik listesini; ürün tipini, uygulama bölgelerini (birden fazla olabilir), kullanıcının cilt tipini, "
            "hassasiyetlerini ve hedeflerini analiz etmektir.\n\n"
            "ANALİZ KURALLARI:\n"
            "1. Sadece 'caution' (dikkat) ve 'avoid' (kaçın) maddelerini listele. 'safe' olanları listeye ekleme.\n"
            "2. 'hero_ingredients' kısmında kullanıcının hedefiyle örtüşen maddeleri listele.\n"
            "3. Hassasiyet listesindeki bir madde içerikte varsa onu 'caution' veya 'avoid' olarak işaretle.\n"
            "4. Hassasiyet listesi boşsa, cilt tipine göre bilinen riskli maddeleri yine de değerlendir "
            "(ör. yağlı cilt + Sodium Laureth Sulfate → avoid, kuru cilt + alkol → caution).\n"
            "5. Belirtilen uygulama bölgelerinin tümünü dikkate al. Örneğin ürün hem 'yuz' hem 'vucut' için seçildiyse, "
            "yüzün hassasiyetini ve vücudun tolere edebilirliğini dengeli yorumla.\n"
            "6. Hedef listesi boşsa, cilt tipine uygun faydalı aktifleri hero_ingredients'e ekle.\n"
            "7. Açıklamalar (reason) profil/cilt tipine özel olmalı ve KESİNLİKLE MAKSİMUM 7 KELİME olmalıdır.\n"
            "8. İçerik listesinde eşleşme varsa listeleri boş bırakma."
        )

    @staticmethod
    def build_user_prompt(request: IngredientAnalysisRequest) -> str:
        # Liste olarak gelen uygulama bölgelerini virgülle ayırarak üst string haline getiriyoruz
        areas_str = ", ".join([a.value.upper() for a in request.application_area])
        sensitivities_str = ", ".join([s.value for s in request.sensitivities]) if request.sensitivities else "Yok"
        goals_str = ", ".join([g.value for g in request.goals]) if request.goals else "Belirtilmemiş"

        return f"""
                [BAĞLAM VE KULLANICI PROFİLİ]
                - Uygulama Bölgeleri: {areas_str}
                - Ürün Tipi: {request.product_type.value.upper()}
                - Cilt Tipi: {request.skin_type.value.upper()}
                - Kullanıcı Hassasiyetleri: {sensitivities_str}
                - Kullanıcı Cilt Hedefleri: {goals_str}

                [İÇERİK LİSTESİ]:
                {request.ocr_text}
                
                [CRUCIAL HINT]:
                You must generate a valid JSON containing 'caution', 'avoid', and 'hero_ingredients' fields.
                Do not leave all lists empty when the ingredient list contains analyzable INCI names.
                If sensitivities include 'parfum' and Parfum is present, it MUST appear in avoid or caution.
                If goals include 'yag_dengeleme' and Zinc PCA or Niacinamide is present, add to hero_ingredients.
                """