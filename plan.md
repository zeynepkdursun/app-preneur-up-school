# 🚀 SkinLens: MVP Geliştirme Planı (v1.3 - Mobile Edition)

Bu döküman, projenin teknik uygulama adımlarını içerir. **Flutter** mobil uygulaması ve **FastAPI** backend servisinin entegrasyonu için LLM (AI) asistanları tarafından sırayla takip edilmek üzere tasarlanmıştır.

## 📌 Mimari Özet
- **Backend:** FastAPI (Python) + PostgreSQL + SQLModel.
- **Mobile Frontend:** Flutter (iOS & Android).
- **AI Engine:** Google Gemini API (Dinamik Karar Mekanizması).
- **Veri Kaynağı:** Hibrit (Gemini Kararı + DB Sabit Bilgisi).
- **OCR:** Flutter `google_ml_kit` (On-device) + FastAPI (Fallback).

---

## 🛠 Faz 1: Proje İskeleti ve Çalışma Standartları
**Hedef:** Servislerin izole dizinlerde ayağa kaldırılması ve haberleşmenin sağlanması.

- [ ] **1.1 Backend Kurulumu:**
    - `backend/` dizini oluştur ve Python `venv` aktif et.
    - `requirements.txt`: `fastapi, uvicorn, sqlmodel, pydantic-settings, python-dotenv, asyncpg, google-generativeai`.
    - `main.py` içinde temel `/health` endpoint'i yaz.
- [ ] **1.2 Mobile Kurulumu (Flutter):**
    - `mobile/` dizininde yeni Flutter projesi oluştur.
    - `pubspec.yaml`: `http`, `google_ml_kit`, `camera`, `shared_preferences`, `riverpod`.
    - Temel pastel/light tema ayarlarını yap.
- [ ] **1.3 Ortam Değişkenleri:**
    - Root dizinde `.env` şablonu: `DATABASE_URL`, `GEMINI_API_KEY`, `BACKEND_URL`.

---

## 🗄 Faz 2: Veri Modeli ve Veritabanı Katmanı
**Hedef:** PostgreSQL şemasının oluşturulması ve "Verification Score" altyapısının kurulması.

- [ ] **2.1 Veri Modelleri (SQLModel):**
    - `User`: `id, skin_type (Enum), sensitivities (JSONB)`.
    - `IngredientMaster`: `id, inci_name (index), description_tr, function_group`.
    - `Product`: `id, barcode, product_name, ingredients_list (Array), is_verified (bool)`.
- [ ] **2.2 Database Bağlantısı:** `database.py` içinde asenkron session yönetimi.
- [ ] **2.3 Seed Data:** `ingredients_master` tablosuna en az 20 popüler içerik (Aqua, Niacinamide, Retinol, Alcohol Denat vb.) ekle.

---

## 🧠 Faz 3: AI Servis ve Prompt Mühendisliği
**Hedef:** Gemini API üzerinden kısıtlanmış ve yapılandırılmış veri alma.

- [ ] **3.1 AI Client:** `services/ai_service.py` oluştur.
- [ ] **System Prompt:** Gemini'yi "Sadece JSON dönen, asla yorum yapmayan, `reason` alanını sadece `Caution` ve `Avoid` durumları için dolduran bir uzman" olarak kurgula.
- [ ] **Schema Validation:** Pydantic ile `{"ingredient": str, "status": str, "reason": str | null}` formatını doğrula.

---

## 🔥 Faz 4: Backend API - Hibrit Analiz Motoru
**Hedef:** Projenin kalbi olan `/analyze` akışının kodlanması.

- [ ] **4.1 Analyze Endpoint:**
    - Girdi: Cilt tipi + (Barkod veya Raw Text).
    - Akış:
        1. Barkod DB'de var mı? (Varsa direkt DB'den getir).
        2. Yoksa: Gemini'ye metni gönder ve sınıflandırma al.
        3. **Hybrid Merge:** AI'dan gelen isimleri DB'deki açıklamalarla (`IngredientMaster`) eşleştir.
- [ ] **4.2 Self-Enrichment & Verification:**
    - Yeni ürünleri `is_verified=False` olarak kaydet.
    - Metin eşleşme oranı **%80** altındaysa ürünü "taslak" olarak işaretle.

---

## 🎨 Faz 5: Mobile MVP Kullanıcı Deneyimi (Flutter)
**Hedef:** "Light & Smooth" vizyonuna uygun mobil arayüzün bitirilmesi.

- [ ] **5.1 Onboarding:** Minimalist cilt tipi seçim ekranı (Seçimi `shared_preferences` ile sakla).
- [ ] **5.2 Kamera ve Tarama:** 
    - `google_ml_kit` ile metin yakalama vizörü.
    - Barkod okuma ve backend'e asenkron istek gönderme.
- [ ] **5.3 Result Page:** 
    - Renk kodlu (Yeşil/Sarı/Kırmızı) kartlar.
    - Maddeye tıklayınca açılan DB kaynaklı bilgi kutucuğu.
    - **Yasal Uyarı (Disclaimer):** Sayfa altında "Tıbbi tavsiye değildir" ibaresi.

---

## 🧪 Faz 6: Final Kontrolleri ve Yayına Hazırlık
- [ ] **6.1 Fallback UI:** AI yanıtı bozulursa veya internet yoksa şık bir hata mesajı göster.
- [ ] **6.2 Rate Limiting:** Backend tarafında kullanıcı başına günlük limit ekle.
- [ ] **6.3 Deployment:** Backend'i Render/Railway'e uçur, Flutter APK çıktısını al.

---

## ✅ Kabul Kriterleri (DoD)
- Analiz kararları AI'dan, madde açıklamaları DB'den geliyor.
- `reason` alanı sadece Safe olmayan maddeler için dolu dönüyor.
- Ürün bulunamadığında DB otomatik olarak (skor kontrolüyle) zenginleşiyor.
- Uygulama mobil cihazda akıcı (smooth) bir kamera-analiz deneyimi sunuyor.