## Öncelik Sıralaması (Roadmap)
Karmaşayı önlemek için şu sırayla gitmek "Cursor" ile kod yazarken size hız kazandıracaktır:

**Aşama 1:** Temel İskelet ve Veritabanı (Setup)
İlk işimiz veritabanı şemasını ayağa kaldırmak.

Infrastructure: .env dosyasını oluşturup PostgreSQL bağlantı ayarlarını ve Gemini API anahtarını eklemek.

Models: ingredients_master ve users tablolarını SQLModel ile tanımlamak. JSONB alanları (goals, sensitivities) için Pydantic entegrasyonunu kurmak.

Health Check: main.py ve Swagger'ın çalıştığını teyit etmek.

**Aşama 2:** Master Veri ve Arama (Static Layer)
Seeding: ingredients_master tablosuna örnek veriler (INCI isimleri) eklemek.

Search API: GET /api/v1/ingredients/search endpoint'ini yazmak. Burada alias bazlı (C Vitamini vs. L-Ascorbic Acid) arama mantığını kurmak kritik.

**Aşama 3:** Gemini Entegrasyonu (Dynamic Layer)
Prompt Engineering: PRD'deki 7 kelime kuralı ve JSON output kısıtlamalarını içeren system_prompt yapısını services/gemini.py içinde kurmak.

Hybrid Logic: DB'den gelen statik bilgi ile Gemini'den gelen dinamik risk analizini birleştiren (merge) servisi yazmak.

**Aşama 4:** Analiz Endpoint'i (Core Value)
Analyze API: POST /api/v1/analyze endpoint'ini tamamlamak. OCR metnini alıp, kategori filtrelemesi yaparak nihai sonucu dönmek.

**Aşama 5:** Profil ve Güvenlik
Kullanıcı hedeflerini kaydetme ve günlük rate-limit (istek sınırı) mekanizmasını eklemek.