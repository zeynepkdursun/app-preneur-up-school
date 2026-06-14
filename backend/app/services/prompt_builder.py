# backend/app/services/prompt_builder.py
from app.schemas.analysis import IngredientAnalysisRequest


class SkinLensPromptBuilder:

    @staticmethod
    def get_system_instruction() -> str:
        return (
            "Sen bir kozmetik formülasyon uzmanı ve kişiselleştirilmiş cilt analiz asistanısın. "
            "Görevin her INCI maddesini kullanıcının cilt tipi, hassasiyetleri ve hedefleri "
            "doğrultusunda değerlendirmektir.\n\n"
            "CİLT TİPİNE GÖRE RİSK VE FAYDA REHBERİ:\n\n"
            "YAĞLI CİLT:\n"
            "  Kaçınılması gerekenler (avoid / high risk):\n"
            "  - Komedojenik yağlar: Isopropyl Myristate, Myristyl Myristate, "
            "Acetylated Lanolin, Cocos Nucifera Oil, Oleic Acid, Lanolin, "
            "Mineral Oil, Paraffinum Liquidum, Petrolatum, Cetyl Alcohol (yüksek oran)\n"
            "  - Aşırı kurutan: Alcohol Denat., SD Alcohol (fazla kurutup yağ üretimini artırır)\n"
            "  Faydalı (hero): Niacinamide, Zinc PCA, Salicylic Acid, "
            "Retinol / Retinyl Palmitate, Hamamelis Virginiana, Tea Tree Oil, "
            "Kaolin / Clay, Squalane, Hyaluronic Acid\n\n"
            "KURU CİLT:\n"
            "  Kaçınılması gerekenler (avoid / high risk):\n"
            "  - Kurutucu alkoller: Alcohol Denat., SD Alcohol 40, Isopropyl Alcohol, "
            "Benzyl Alcohol (yüksek oran)\n"
            "  - Sert yüzey aktifler: Sodium Lauryl Sulfate, Sodium Laureth Sulfate\n"
            "  Dikkat (caution): Parfum / Fragrance, mentol, okaliptüs (bariyeri hassassa iritan)\n"
            "  Faydalı (hero): Glycerin, Hyaluronic Acid / Sodium Hyaluronate, "
            "Ceramides, Butyrospermum Parkii Butter, Squalane, Panthenol, "
            "Lanolin, Simmondsia Chinensis Oil, Avena Sativa, Urea, "
            "Allantoin, Tocopherol, Bisabolol\n\n"
            "KARMA CİLT:\n"
            "  T-bölgesi için yağlı cilt kuralları, yanaklar için kuru cilt kuralları geçerlidir.\n"
            "  Dikkat: Aşırı komedojenik veya aşırı kurutucu maddeleri uyar.\n"
            "  Faydalı (hero): Niacinamide, Hyaluronic Acid, Glycerin, Squalane\n\n"
            "HASSAS CİLT:\n"
            "  Kaçınılması gerekenler (avoid):\n"
            "  - Parfum / Fragrance, Limonene, Linalool, Citral, Citronellol, Geraniol, "
            "Coumarin (alenjen listesi)\n"
            "  - Alcohol Denat., Menthol, Camphor, Eucalyptus\n"
            "  - SLS / SLES, Methylisothiazolinone, Formaldehyde releasers (DMDM Hydantoin vb.)\n"
            "  - Yüksek konsantrasyon AHA (Glycolic Acid >%10) veya retinoidler\n"
            "  Faydalı (hero): Panthenol, Allantoin, Niacinamide, "
            "Centella Asiatica / Madecassoside, Aloe Barbadensis, "
            "Bisabolol, Ceramides, Oat (Avena Sativa), Zinc Oxide, "
            "Tocopherol, Beta-Glucan, Azelaic Acid\n\n"
            "SINIFLANDIRMA KURALLARI:\n"
            "1. Bir madde birden çok kategoride değerlendirilebilir. "
            "Parfum hem alerjen hem kurutucudur.\n"
            "2. 'avoid': Kullanıcının cilt tipi veya hassasiyetiyle doğrudan çelişen, "
            "yüksek riskli maddeler (komedojenik, alerjen, kurutucu).\n"
            "3. 'caution': Potansiyel risk taşıyan ancak formülasyondaki oranına "
            "veya diğer maddelerle etkileşimine bağlı maddeler.\n"
            "4. 'hero_ingredients': Kullanıcının hedefi ve cilt tipiyle uyumlu, "
            "kanıtlanmış faydalı aktifler. Hedef listesi boşsa cilt tipine uygun "
            "aktifleri seç.\n"
            "5. Aynı maddeyi hem avoid hem caution'a koyma. En uygun bir kategori seç.\n"
            "6. Hassasiyet listesindeki maddelerden içerikte olanları avoid'a koy.\n"
            "7. Açıklamalar (reason) cilt tipine özel, maksimum 10 kelime olmalı. "
            "Örn: 'Gözenek tıkayıcı, yağlı ciltte riskli' veya 'Cilt bariyerini onarır, nemlendirir'\n"
            "8. Pazarlama terimlerini (Aqua = su gibi) açıklama. Sadece gerçek risk/fayda yaz.\n"
            "9. Asla uydurma madde ekleme. Emin değilsen o maddeyi analiz dışı bırak."
        )

    @staticmethod
    def build_user_prompt(request: IngredientAnalysisRequest) -> str:
        areas_str = ", ".join([a.value.upper() for a in request.application_area])
        sensitivities_str = ", ".join(
            [s.value for s in request.sensitivities]
        ) if request.sensitivities else "Yok"
        goals_str = ", ".join(
            [g.value for g in request.goals]
        ) if request.goals else "Belirtilmemiş"

        return f"""
[BAĞLAM VE KULLANICI PROFİLİ]
- Uygulama Bölgeleri: {areas_str}
- Ürün Tipi: {request.product_type.value.upper()}
- Cilt Tipi: {request.skin_type.value.upper()}
- Kullanıcı Hassasiyetleri: {sensitivities_str}
- Kullanıcı Cilt Hedefleri: {goals_str}

[OCR HAM METNİ]:
{request.ocr_text}

[TALİMAT]:
Yukarıdaki OCR ham metninden INCI ingredient listesini tespit et.
Ürün adı, marka, hacim, kullanım talimatı, üretici bilgisi gibi içerik dışı
metinleri analize dahil etme. Sadece gerçek INCI maddelerini analiz et.
OCR hatalarını tolere et (é→e, ü→u, í→i vb.).

Cilt tipi rehberindeki kuralları kullanarak her INCI maddesini sınıflandır.
Aşağıdaki örnekler beklenti formatını gösterir:

ÖRNEK 1 — Yağlı cilt, akne hedefi, parfum hassasiyeti:
  İçerik: Aqua, Isopropyl Myristate, Coconut Oil, Niacinamide, Parfum, Salicylic Acid
  Çıktı:
  {
    "hero_ingredients": [{"ingredient": "Niacinamide", "reason": "Yağ ve akne kontrolü sağlar"}, {"ingredient": "Salicylic Acid", "reason": "Gözenek temizler, akneyi azaltır"}],
    "caution": [],
    "avoid": [{"ingredient": "Isopropyl Myristate", "reason": "Yüksek komedojenik, gözenek tıkar"}, {"ingredient": "Coconut Oil", "reason": "Komedojenik, yağlı ciltte riskli"}, {"ingredient": "Parfum", "reason": "Hassasiyet: parfum içerir"}]
  }

ÖRNEK 2 — Kuru cilt, nemlendirme hedefi:
  İçerik: Aqua, Alcohol Denat., Glycerin, Ceramide NP, Parfum, Panthenol, Lactic Acid
  Çıktı:
  {
    "hero_ingredients": [{"ingredient": "Glycerin", "reason": "Cildi nemlendirir, bariyeri destekler"}, {"ingredient": "Ceramide NP", "reason": "Cilt bariyerini onarır, nemi hapseder"}, {"ingredient": "Panthenol", "reason": "Yatıştırır, nemlendirir, bariyer onarır"}],
    "caution": [{"ingredient": "Parfum", "reason": "Kuru ciltte tahriş edici olabilir"}, {"ingredient": "Alcohol Denat.", "reason": "Kurutucu, kuru ciltte bariyeri zayıflatır"}],
    "avoid": []
  }

ÖRNEK 3 — Hassas cilt, bariyer güçlendirme:
  İçerik: Aqua, Centella Asiatica, Parfum, Limonene, Panthenol, Niacinamide, Linalool
  Çıktı:
  {
    "hero_ingredients": [{"ingredient": "Centella Asiatica", "reason": "Yatıştırır, hassas cilt onarımı"}, {"ingredient": "Panthenol", "reason": "Yatıştırır, bariyer onarır"}, {"ingredient": "Niacinamide", "reason": "Bariyer güçlendirir, tahrişi azaltır"}],
    "caution": [{"ingredient": "Parfum", "reason": "Hassas ciltte alerjik reaksiyon riski"}],
    "avoid": [{"ingredient": "Limonene", "reason": "Alerjen, hassas ciltte tahriş edici"}, {"ingredient": "Linalool", "reason": "Alerjen, hassas ciltte tahriş edici"}]
  }

Kurallar:
- hero_ingredients: Cilt tipine ve hedefe uygun faydalı aktifler
- caution: Potansiyel riskli, dikkat edilmesi gerekenler
- avoid: Cilt tipiyle çelişen veya hassasiyete giren yüksek riskli maddeler
- Her liste öğesinde "ingredient" ve "reason" (maks 10 kelime) zorunlu
- Hiçbir madde eşleşmezse boş liste döndür. Asla uydurma madde ekleme.
                """