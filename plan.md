# SkinLens MVP Geliştirme Planı (PRD v1.1’e göre)

Bu plan, `PRD.md` kapsamını **iteratif** şekilde teslim edilebilir parçalara böler. Hedef: Barkod/OCR ile ürün içerik listesini çıkarıp, Gemini ile cilt tipine göre risk analizi yaparak, DB’deki statik ingredient bilgisiyle birleştirilmiş bir rapor üretmek.

---

## 0) Tanımlar ve kabul kriterleri (DoD)

- **Teknik DoD**
  - Backend: FastAPI + Pydantic ile tüm istek/yanıt şemaları doğrulanır.
  - DB: PostgreSQL şeması migrate ile yönetilir.
  - AI: Gemini çıktısı **yalnızca JSON** olacak şekilde kısıtlanır; JSON parse + şema validasyonu yapılır.
  - Güvenlik: Rate limit + temel input doğrulama + log/trace ekleri.
- **Ürün DoD**
  - Analiz ekranında “İçerikler analiz ediliyor…” yükleme durumu.
  - Sonuçlar **renk kodlu** (Safe/Yeşil, Caution/Sarı, Avoid/Kırmızı).
  - Her raporda yasal uyarı: “Tıbbi tavsiye değildir, yapay zeka destekli bilgilendirmedir.”
  - Kirli veri kontrolü: `is_verified=false` (Pending_Review) ürünler genel aramalarda görünmez.

---

## 1) Proje iskeleti ve çalışma standartları (Gün 1)

- **Repo yapısı**
  - `backend/` FastAPI uygulaması
  - `frontend/` Next.js/React uygulaması
- **Ortam değişkenleri**
  - `GEMINI_API_KEY`
  - `GOOGLE_VISION_API_KEY` (veya servis hesabı yaklaşımı seçilecek)
  - `DATABASE_URL`
- **Geliştirici deneyimi**
  - Backend: lint/format (ruff/black vb.), test altyapısı (pytest)
  - Frontend: eslint/prettier, env şablonu

Çıktılar:
- Çalışan “hello world” backend + frontend
- Lokal PostgreSQL’e bağlanan backend iskeleti

---

## 2) Veri modeli ve migrate’ler (Gün 1–2)

PRD şemasına göre tablolar:
- **`users`**
  - `id (UUID)`
  - `skin_type (Enum)` (örn: oily, dry, combination, sensitive)
  - `sensitivities (JSONB)` (opsiyonel)
  - `favorites (Array)` (ürün id’leri veya barkodlar; karar burada netleşecek)
- **`ingredients_master`**
  - `id`
  - `inci_name (indexed)`
  - `aliases` (PRD notu: varyasyon isimleri için kritik)
  - `description_tr`
  - `function_group`
- **`products`**
  - `id`
  - `barcode` (nullable)
  - `product_name`
  - `ingredients_list (Array)`
  - `verification_score (Float)`
  - `is_verified (Boolean)`

Çıktılar:
- Migrate’ler ve temel seed (en azından `ingredients_master` için örnek veri)

---

## 3) Backend API v1 (Gün 2–4)

### 3.1 `POST /api/v1/profile`
- Kullanıcının cilt tipi + hassasiyetlerini kaydeder.
- Basit kimlik: MVP için kullanıcı id’si header/body ile taşınabilir (ileride auth eklenir).

### 3.2 `GET /api/v1/favorites`
- Kullanıcı “dijital raf” listesini döner.
- Kural: Pending ürünler sadece sahibine görünür.

### 3.3 `POST /api/v1/analyze` (MVP’nin kalbi)
Girdi:
- `barcode` veya `image` (multipart)
- `user_id` veya profil bağlamı (skin_type)

Akış:
1. **Hybrid Search**
   - Barkod varsa: `products` tablosunda ara.
   - Bulunursa: ürün içerik listesini kullan.
   - Bulunamazsa: OCR akışına düş.
2. **OCR (Google Vision)**
   - Görselden ham metni çıkar.
   - Bulanıklık/kalite düşükse kullanıcıya anlamlı hata/uyarı dön (PRD: OCR pre-processing uyarısı).
   - Ham metinden ingredient listesini normalize et (büyük/küçük, ayraçlar, trim).
3. **AI Analiz (Gemini)**
   - Prompt: “Sadece JSON dön” kısıtı.
   - Mantık: `Safe` için `reason=null`; `Caution/Avoid` için tıbbi olmayan açıklama.
4. **Hybrid Merge (AI + DB)**
   - AI sonucu `ingredient_name` üzerinden `ingredients_master` ile eşleştir:
     - Önce `inci_name`, sonra `aliases` üzerinden arama.
   - Çıktıya `function_group` ve `description_tr` ekle.
5. **Self-enrichment**
   - Ürün DB’de yoksa:
     - `products` kaydı oluştur (`is_verified` başlangıçta false olabilir)
     - `verification_score` hesapla: ingredient’ların sözlük eşleşme oranı
     - Skor < %80 ise Pending_Review olarak kalmalı (PRD)

Çıktılar:
- Pydantic response modeli ile doğrulanmış analiz JSON’u
- Hata durumları (OCR başarısız, AI JSON parse edilemedi, rate limit vb.)

---

## 4) Güvenlik, maliyet ve guardrails (Gün 4–5)

- **Rate limiting**
  - Kullanıcı başına günlük tarama limiti (konfigüre edilebilir).
- **JSON şema doğrulama**
  - Gemini yanıtı parse edilmeden frontend’e gitmez.
- **Loglama**
  - Request id + hata sebepleri; (AI yanıtı/logları PII içermeyecek şekilde sınırlı tutulur)
- **Pending görünürlük kuralı**
  - `is_verified=false` ürünler “genel kütüphane” aramalarında listelenmez.

Çıktılar:
- Limit aşıldığında deterministik hata mesajı
- AI yanıtı bozulduğunda güvenli fallback

---

## 5) Frontend MVP akışları (Gün 3–6, backend ile paralel)

### 5.1 Onboarding / Profil
- Cilt tipi seçimi (yağlı/kuru/karma/hassas) + kaydetme

### 5.2 Tarama ekranı
- Barkod girişi (MVP: manuel input) + opsiyonel görsel yükleme
- **Görsel sıkıştırma** (PRD: backend’e gitmeden önce)
- “İçerikler analiz ediliyor…” loading state

### 5.3 Sonuç ekranı
- Safe/Caution/Avoid renk kodları
- Ingredient satırında:
  - isim
  - statik fonksiyon/özet (DB)
  - gerekirse AI nedeni (Caution/Avoid)
- Yasal uyarı (disclaimer) görünür
- “Rafa ekle / favori” aksiyonu

### 5.4 Dijital raf (Favorites)
- Favori ürün listesi
- Pending ürünler sadece kullanıcı rafında görünebilir (PRD kuralı)

Çıktılar:
- Uçtan uca temel kullanıcı akışı tamam

---

## 6) Test planı ve kalite (Gün 5–7)

- **Backend**
  - Unit: ingredient normalize + alias eşleştirme + verification_score
  - Contract: `/analyze` response şeması
  - Mock: Gemini ve Vision API mock’ları
- **Frontend**
  - Kritik akış: profil → analyze → sonuç → favori
  - Hata ekranları: OCR yok, AI parse hatası, rate limit

Çıktılar:
- Minimum regresyon test seti

---

## 7) Release kontrol listesi (Gün 7)

- Env’ler doğru (API key’ler, DB)
- Rate limit açık
- Pending ürünlerin genel görünürlüğü kapalı
- Disclaimer her raporda var
- Basit metrikler/loglar (en az: analyze çağrı sayısı, OCR başarısı, eşleşme oranı)

---

## 8) Sonraki iterasyon önerileri (MVP sonrası)

- Admin paneli: Pending ürünleri onaylama/editleme
- Barkod tarama (kamera) ve daha iyi OCR ön-işleme
- Auth (JWT/Session) ve gerçek kullanıcı yönetimi
- Ingredient sözlüğü zenginleştirme: daha kapsamlı `aliases` ve eşleştirme heuristics

