# 🚀 SkinLens MVP Geliştirme Planı (v1.2)

Bu döküman, SkinLens projesinin teknik uygulama adımlarını içerir. LLM (AI) asistanları tarafından sırayla takip edilmek ve her adımda doğrulanmak üzere tasarlanmıştır.

## 📌 Mimari Özet
- **Backend:** FastAPI (Python) + PostgreSQL + SQLModel.
- **Frontend:** Next.js (TypeScript) + Tailwind CSS.
- **AI Engine:** Google Gemini API (Dinamik Karar).
- **Veri Kaynağı:** Hibrit (LLM Kararı + DB Sabit Bilgisi).
- **Deployment Hedefi:** Vercel (Frontend) + Render/Railway (Backend & DB).

---

## 🛠 Faz 1: Proje İskeleti ve Çalışma Standartları
**Hedef:** Backend ve Frontend servislerinin izole dizinlerde ayağa kaldırılması.

- [ ] **1.1 Backend Kurulumu:**
    - `backend/` dizini oluştur.
    - Python `venv` kur ve aktif et.
    - `requirements.txt` içeriği: `fastapi, uvicorn, sqlmodel, pydantic-settings, python-dotenv, asyncpg, google-generativeai`.
    - `main.py` içinde temel `/health` endpoint'i yaz.
- [ ] **1.2 Frontend Kurulumu:**
    - `frontend/` dizini oluştur (Next.js + TS + Tailwind).
    - `axios` ve `lucide-react` (ikonlar için) ekle.
    - Temel "Hoş Geldiniz" sayfasını hazırla.
- [ ] **1.3 Ortam Değişkenleri:**
    - Root dizinde `.env` şablonu oluştur: `DATABASE_URL`, `GEMINI_API_KEY`.

---

## 🗄 Faz 2: Veri Modeli ve Veritabanı Katmanı
**Hedef:** PostgreSQL şemasının oluşturulması ve statik verilerin (Seed) eklenmesi.

- [ ] **2.1 Veri Modelleri (SQLModel):**
    - `User`: `id, skin_type (Enum), sensitivities (JSONB)`.
    - `IngredientMaster`: `id, inci_name (index), description_tr, function_group`.
    - `Product`: `id, barcode, product_name, ingredients_list (Array), is_verified (bool)`.
- [ ] **2.2 Database Bağlantısı:** `database.py` içinde asenkron session yönetimi.
- [ ] **2.3 Seed Data:** `ingredients_master` tablosuna en az 15 popüler içerik (Aqua, Niacinamide, Retinol, Alcohol Denat vb.) için açıklama ekle.

---

## 🧠 Faz 3: AI Servis ve Prompt Mühendisliği
**Hedef:** Gemini API üzerinden yapılandırılmış (structured) veri alma.

- [ ] **3.1 AI Client:** `services/ai_service.py` oluştur.
- [ ] **System Prompt:** Gemini'yi "Sadece JSON dönen, asla yorum yapmayan bir cilt bakım uzmanı" olarak kurgula.
- [ ] **Schema Validation:** Pydantic ile `{"safe": [], "caution": [], "avoid": []}` formatını doğrula.

---

## 🔥 Faz 4: Backend API - Hibrit Analiz Motoru
**Hedef:** Projenin kalbi olan `/analyze` akışının kodlanması.

- [ ] **4.1 Analyze Endpoint:**
    - Girdi: Cilt tipi + (Barkod veya İçerik Metni).
    - Akış:
        1. Barkod DB'de var mı? (Varsa direkt DB'den getir).
        2. Yoksa: Gemini'ye metni gönder ve sınıflandırma (Safe/Caution/Avoid) al.
        3. **Hybrid Merge:** Gemini'den gelen isimleri DB'deki açıklamalarla (`IngredientMaster`) eşleştir.
- [ ] **4.2 Self-Enrichment:** Analiz edilen yeni ürünleri `is_verified=False` olarak otomatik kaydet.

---

## 🎨 Faz 5: Frontend MVP Kullanıcı Deneyimi
**Hedef:** "Light & Smooth" vizyonuna uygun arayüzün bitirilmesi.

- [ ] **5.1 Onboarding:** Minimalist cilt tipi seçim ekranı.
- [ ] **5.2 Dashboard:** Ürün barkodu girme veya içerik listesi yapıştırma alanı.
- [ ] **5.3 Result Page:** - Renk kodlu (Yeşil/Sarı/Kırmızı) sonuç kartları.
    - Maddeye tıklayınca açılan DB kaynaklı bilgi kutucuğu.
    - **Yasal Uyarı (Disclaimer):** "Tıbbi tavsiye değildir" ibaresinin her analizde görünmesi.

---

## 🧪 Faz 6: Güvenlik ve Final Kontrolleri
**Hedef:** Hata yönetimi ve DoD doğrulaması.

- [ ] **6.1 Rate Limiting:** Kullanıcı başına günlük tarama limiti ekle.
- [ ] **6.2 Fallback UI:** AI yanıtı bozulursa veya içerik okunamazsa kullanıcıya şık bir hata mesajı göster.
- [ ] **6.3 Deployment:** Backend'i Render/Railway'e, Frontend'i Vercel'e yükle.

---

## ✅ Kabul Kriterleri (DoD)
- Backend ve Frontend ayrı servisler olarak çalışıyor.
- Analiz kararları AI'dan, madde açıklamaları DB'den geliyor.
- Geçersiz içerik listeleri için sistem hata fırlatıyor.
- Ürün bulunamadığında DB otomatik olarak zenginleşiyor.