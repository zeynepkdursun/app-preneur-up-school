# Product Requirements Document (PRD): SkinLens Platform
 
**Sürüm:** 1.4 (Mobile & AI Hybrid Edition)[cite: 1]
**Project Status:** Geliştirme Aşamasında (AI & Personalization Focus)
**Core Logic:** Hybrid Engine (Static DB + Dynamic LLM Override)
**Tech Stack:** Flutter, FastAPI, PostgreSQL, Gemini API

---

## 1. Executive Summary & Vision
SkinLens, statik içerik bilgilerini kullanıcının o anki hedefleri (Goals) ve profiliyle (Skin Type) harmanlayan AI tabanlı bir kişisel analiz asistanıdır. Sadece içerik tanımlamakla kalmaz; kullanıcının tercihlerine (Örn: Leke açmak mı istiyor yoksa çillerini korumak mı?) göre Dinamik Karar Mekanizması işletir.
* **Core Value Prop:** Barkod bağımlılığı olmadan, on-device OCR ve LLM (Gemini) entegrasyonu ile her kozmetik ürünü saniyeler içinde analiz ederek şeffaf içerik bilgisi sunmak[cite: 1].

---

## 2. Personas & User Stories
**1) Tarama (Input):** Kullanıcı ürün içerik listesini fotoğraflar (On-device OCR).

**2) Bağlam Seçimi (Context):** Uygulama "Bu ürün nereye uygulanıyor?" (Yüz, Saç, Vücut) ve "Tipi nedir?" (Şampuan, Nemlendirici vb.) sorularıyla bağlamı netleştirir.

**3) Akıllı Filtreleme:** Backend, kullanıcının sadece seçilen bölgeyle ilgili hedeflerini (Örn: Saç dökülmesi karşıtı) veritabanından çeker.

**4) Hibrit Analiz:**
Statik: DB'den genel INCI tanımları çekilir.
Dinamik: Kullanıcı profili + Hedefler + Bağlam Gemini'ye gönderilir.

---

## 3. Specifications & Architectural (Functional Requirements??)

### 3.1. Veritabanı Yapısı (PostgreSQL)
Veri bütünlüğü ve performans için **Master Table** ve **JSONB** yapısı hibrit şekilde kullanılır:

* **Enum Alanları:**
    * `SkinType`: (Karma, Yağlı, Kuru, Normal)
    * `SafetyStatus`: (Safe, Caution, Avoid)
* **Master Tables:**
    * `GoalsMaster`: Tüm hedeflerin (Leke açma, Yağ dengeleme vb.) kategori bazlı tutulduğu referans tablosu.
    * `IngredientsMaster`: ~10.000 maddelik statik sözlük (`inci_name`, `description_tr`, `general_risk`).
* **Kullanıcı Profili (JSONB):** Hedefler kategori bazlı saklanır:
    ```json
    {"face": ["oil_control", "anti-aging"], "hair": ["volume", "anti-hairloss"]}
    ```

### 3.2. Backend Mantığı (FastAPI & Gemini)
Backend, Gemini'ye "Odaklanmış Veri" (Curated Context) göndererek token tasarrufu ve doğruluk sağlar:
* **Kategori Filtreleme:** Ürün "Şampuan" ise "Yüz" hedefleri prompt'tan temizlenir.
* **Niyet Duyarlılığı:** Kullanıcı "Çillerimi seviyorum" diyorsa, leke açıcılar `Caution` olarak işaretlenir.
* **Override Hiyerarşisi:** LLM'den gelen kişiselleştirilmiş uyarı, DB'den gelen genel "Safe" bilgisinin üzerine yazılır.
* **Image Processing:** Flutter istemcisi, görselleri backend'e iletmeden önce mutlaka optimize etmeli ve sıkıştırmalıdır. (?)


### 3.3. AI Analiz Motoru (Gemini Integration)
* **Logic Constraints:** 
    * `Safe` içerikler için `reason: null` döner[cite: 1].
    * `Caution` ve `Avoid` durumları için cilt tipine özel açıklayıcı bir `reason` zorunludur[cite: 1].
    * 
### 3.4. Hybrid Data Merging (LLM + DB)
Analiz süreci şu iki katmanı birleştirir[cite: 1]:
* **Dynamic Layer (AI):** Maddenin kullanıcıya özel risk durumu (`Safe/Caution/Avoid`)[cite: 1].
* **Static Layer (DB):** Maddenin genel fonksiyonu (Örn: "Nemlendirici", "Antioksidan")[cite: 1].
* **Merge Logic:** FastAPI, AI'dan gelen sınıflandırmayı DB'deki `ingredients_master` verisiyle `inci_name` ve `aliases` üzerinden eşleştirerek nihai objeyi oluşturur[cite: 1].
* 
---

## 4. Technical Specifications

### 4.1. Data Schema (PostgreSQL & SQLModel)
* **`users`:** `id (UUID)`, `skin_type (Enum)`, `goals (JSONB)`, `sensitivities (JSONB)`, `favorites (Array)`.
   Not: goals alanı {"face": ["oil_control"], "hair": ["volume"]} formatında kategori bazlı saklanır.
* **`ingredients_master`:** `id`, `inci_name (Indexed)`, `aliases (JSONB)`, `description_tr`, `general_risk_level (Enum)`.
  
### 4.2. Enum Tanımları
* SkinType: KARMA, YAGLI, KURU, NORMAL
* RiskLevel: SAFE, CAUTION, AVOID

### 4.3. API Endpoints (FastAPI)
* `POST /api/v1/analyze`:
  Girdi: OCR metni veya Barkod + Uygulama Bölgesi (Yüz/Saç/Vücut) + Ürün Tipi.  
  İşlev: Önce DB'den statik tanımları çeker, ardından kullanıcı hedefleriyle Gemini üzerinden dinamik override işlemini gerçekleştirir.  
  Çıktı: Kişiselleştirilmiş risk uyarıları, "Hero" içerikler ve 7 kelimelik özet.
* `POST /api/v1/profile`: Kullanıcı kategori bazlı cilt tipi, hassasiyet ve hedef tercihlerini kaydeder.
* `GET /api/v1/ingredients/search`: ingredients_master tablosu üzerinde INCI veya takma isim (alias) bazlı arama yapar.
* `GET /api/v1/favorites`: Kullanıcının dijital rafını (favorilerini) listeler.

* 
### 4.4 Örnek JSON Çıktısı (API Response)
{
  "product_type": "Şampuan",
  "alerts": [
    {
      "ingredient": "Sodium Laureth Sulfate",
      "safety": "caution",
      "reason": "Hassas saç derisinde kuruluk yapabilir."
    }
  ],
  "hero_ingredients": [
    {
      "ingredient": "Zinc PCA",
      "reason": "Saç derinizdeki yağ üretimini dengeler."
    }
  ],
  "overall_recommendation": {
    "action": "safe",
    "reason": "Saç hedeflerinize uygun, matlaştırıcı etkili."
  }
}
---

## 5. Security & Guardrails
* **Legal Disclaimer:** Her analiz raporunun altında: *"Tıbbi tavsiye değildir, yapay zeka destekli bilgilendirmedir."* ibaresi zorunludur[cite: 1].
* **Content Validation:** AI yanıtları `Pydantic` modelleri ile doğrulanmadan istemciye servis edilmez[cite: 1].
* **Rate Limiting:** Kullanıcı başına günlük tarama sınırı uygulanarak API maliyetleri kontrol altında tutulur[cite: 1].

---

## 6. UX/UI Requirements (Mobile Focus)
* **Design Language:** Modern, medikal güven veren, pastel tonlar (Clean-tech estetiği)[cite: 1].
* **Visual Feedback:** Tarama esnasında haptic geri bildirim ve "İçerikler analiz ediliyor..." animasyonu sunulmalıdır[cite: 1].
* **Color Coding:** 
    * **Yeşil:** Safe (Güvenli)[cite: 1]
    * **Sarı:** Caution (Dikkat)[cite: 1]
    * **Kırmızı:** Avoid (Kaçın)[cite: 1]

---

## 4. Prompt Mühendisliği (System Instructions)

Gemini API için belirlenen katı kurallar:
1. **Prompt Constraint:** Model sadece ham JSON döndürmeye zorlanmalı; asla metinsel yorum yapmamalıdır.
2.  **Sadece İstisnalar:** Sadece `Caution` ve `Avoid` durumundaki içerikleri döndür (Pozitif içerikler sadece 'Hero' kısmında yer alır).
3.  **7 Kelime Kuralı:** Tüm açıklamalar maksimum 7 kelime, net ve kullanıcıya hitap eden (2. tekil şahıs) yapıda olmalıdır.
4.  **Hero Ingredients:** Kullanıcının hedefiyle (Goal) eşleşen maddeleri (`Zinc PCA` -> `Yağ dengeleme`) mutlaka öne çıkar.
5.  **Etkileşim Kontrolü:** Ürün içindeki veya rutinindeki (varsa) çakışan içerikleri (Örn: Retinol + C Vitamini) denetle.

---

## 7. Operational Strategy (CPO Notes)

### 7.1. Data Integrity & Self-Enrichment
* **Verification Score:** OCR metin eşleşme oranı **%80**'in altındaysa ürün `is_verified = false` işaretlenir ve Admin onayına düşer[cite: 1].
* **Kirli Veri Önlemi:** Onaylanmamış (`Pending_Review`) ürünler genel aramada çıkmaz; sadece ilk taratan kullanıcı kendi "Rafında" görebilir[cite: 1].
* **Mapping Stratejisi:** Kimyasal varyasyonlar (Örn: Vitamin C vs L-Ascorbic Acid) için `aliases` (takma isimler) kolonu üzerinden eşleşme sağlanması kritiktir[cite: 1].

### 7.2. Success Metrics (KPIs)
* **Scan-to-Result Speed:** Kamerayı açtıktan sonra sonucun gelme süresi (Hedef: < 4 saniye)
* **UGC Growth:** Veritabanına haftalık eklenen organik yeni ürün sayısı
* **User Stickiness:** Kullanıcıların favori listesine eklediği ortalama ürün sayısı

### 7.3 Backend Geliştirme Notları (Giriş)
Framework: FastAPI (Asenkron yapı).
ORM: SQLModel (Pydantic + SQLAlchemy entegrasyonu).
Validation: Pydantic Enum sınıfları ile katı veri tipi kontrolü.
Security: Kullanıcı hassasiyetleri ve hedefleri için JSONB operasyonları.

---

**Date:** May 2026
