# SkinLens (UP SCHOOL) — Proje Durumu

> Son güncelleme: Mayıs 2026  
> Ürün: AI destekli cilt bakım içerik analizi (Flutter + FastAPI + PostgreSQL + Gemini)

---

## 1. Ürün Özeti

**SkinLens**, kozmetik ürün INCI listelerini kullanıcının cilt tipi ve hassasiyetlerine göre analiz eden mobil uygulamadır. MVP hedefi: OCR ile metin yakalama, statik içerik sözlüğü (PostgreSQL) + dinamik risk kararı (Gemini) hibrit motoru.

**Teknoloji yığını:**
| Katman | Teknoloji |
|--------|-----------|
| Mobil | Flutter (iOS / Android / Web) |
| Backend | FastAPI, SQLModel, PostgreSQL |
| AI (planlanan) | Google Gemini API |
| OCR (planlanan) | `google_ml_kit` veya Vision API |

---

## 2. Tamamlananlar

### 2.1 Dokümantasyon ve planlama
- [x] **README.md** — ödev yapısı, ekran görüntüleri
- [x] **mvp.md** — MVP kapsamı (V3.0, Flutter & AI Hybrid)
- [x] **prd.md** — ürün gereksinimleri (v1.4)
- [x] **plan.md** — faz bazlı geliştirme planı
- [x] **progress-frontend.md** — Flutter UI ilerleme notları
- [x] **backend/roadmap.md** — backend aşama sıralaması

### 2.2 Backend (FastAPI)
- [x] Proje iskeleti: `main.py`, health check (`/health`), root endpoint
- [x] **CORS** — Flutter emülatör/web erişimi için yapılandırma
- [x] **PostgreSQL + SQLModel** — `init_db()`, session yönetimi
- [x] **Kullanıcı modeli** (`User`): `username`, `email`, `hashed_password`, `skin_type`, `goals`, `sensitivities`, `favorites` (JSONB)
- [x] **İçerik sözlüğü** (`IngredientsMaster`): INCI adı, alias’lar, Türkçe açıklama, `RiskLevel`
- [x] **Enum’lar**: `SkinType`, `RiskLevel`, analiz şema modelleri (`IngredientAnalysis`, `AnalysisResponse`)
- [x] **Ingredient API**
  - `GET /api/v1/ingredient/search` — alias destekli arama
  - `POST /api/v1/ingredient/seed` — örnek veri (Hyaluronic Acid, Niacinamide, SLES, Retinol vb.)
  - `POST /api/v1/ingredient/bulk` — toplu ekleme
- [x] **Profil API** — `POST /api/v1/users/profile` (cilt tipi + hassasiyetler; şu an sabit `user_id=1` / `test_user`)
- [x] **Kimlik doğrulama (temel)**
  - `POST /api/v1/auth/signup` — kayıt, bcrypt hash
  - `POST /api/v1/auth/token` — OAuth2 form ile giriş, JWT döner
  - `app/core/security.py` — bcrypt hash/doğrulama, JWT üretimi

### 2.3 Frontend (Flutter)
- [x] Modüler yapı: `core/`, `widgets/`, `screens/`, `models/`
- [x] **Tasarım sistemi** — `AppColors`, `AppTextStyles` (Noto Serif + Manrope, lüks kozmetik paleti)
- [x] **Ana sayfa** (`HomeScreen`) — analiz kartı, tarama butonu, mock “Son Analizler”, alt navigasyon, giriş durumu (`_isLoggedIn`)
- [x] **Giriş paneli** (`AuthBottomSheet`) — e-posta/şifre, backend `login()` entegrasyonu
- [x] **Cilt tipi ekranı** (`SkinTypeScreen`) — 5 cilt tipi + hassasiyet chipleri → `ApiService.saveProfile()`
- [x] **Tarama ekranı** (`ScanScreen`) — kamera placeholder, overlay, içerik/barkod segmenti
- [x] **Analiz sonucu ekranı** (`AnalysisResultScreen`) — statik/mock UI (puan halkası, içerik listesi)
- [x] Widget’lar: `AnalysisCard`, `ProductCard`, `ScanOverlay`, `SkinTypeOption`, `SensitivityChip`, `IngredientAnalysisTile`, `AnalysisScoreCircle`
- [x] **ApiService** — profil kaydetme (`http`), giriş (`dio` + `flutter_secure_storage`)
- [x] **AuthManager** — JWT’yi güvenli depolama (sınıf hazır, ana ekranda tam bağlı değil)
- [x] Bağımlılıklar: `http`, `dio`, `google_fonts`, `flutter_secure_storage`

### 2.4 Entegrasyon (kısmi)
- [x] Flutter ↔ FastAPI profil kaydı (`POST /users/profile`)
- [x] Flutter ↔ FastAPI giriş (`POST /auth/token`) ve token saklama
- [x] Ekranlar arası navigasyon (Home → SkinType, Scan → AnalysisResult)

---

## 3. Devam Eden / Eksik Kalanlar (bilinen)

| Konu | Durum |
|------|--------|
| Kayıt (signup) UI | Backend var, Flutter yok |
| `AuthManager` ↔ `HomeScreen` | TODO: token ile oturum kontrolü |
| JWT korumalı endpoint’ler | `/profile`, `/analyze` korumasız |
| Profil endpoint | Sabit `user_id=1`, giriş yapan kullanıcıya bağlı değil |
| `Authorization` header | ApiService isteklerine token eklenmiyor |
| Cilt tipi enum uyumu | Frontend `DRY`/`COMBINATION` gönderiyor; backend `yagli`/`kuru` vb. bekliyor olabilir |
| `SECRET_KEY` | Kod içinde sabit; `.env`’e taşınmalı |
| Gemini / analyze | Henüz yok |
| OCR / gerçek kamera | UI var, işlev yok |
| `products` tablosu, geçmiş, raf | Planlandı, uygulanmadı |

---

## 4. Sonraki Adımlar (Yapılacaklar)

Öncelik sırası `backend/roadmap.md` ve `plan.md` ile uyumludur.

### Aşama A — Auth’u tamamlama (yüksek öncelik)
- [ ] `SECRET_KEY` ve JWT ayarlarını `.env` / `settings` üzerinden yönet
- [ ] `get_current_user` dependency: Bearer token doğrulama
- [ ] `/users/profile` ve gelecekteki kişisel endpoint’leri JWT ile koru
- [ ] Profil güncellemesini giriş yapan kullanıcıya bağla (`user_id=1` kaldır)
- [ ] Flutter: **Kayıt ol** akışı (`POST /auth/signup`)
- [ ] Flutter: `HomeScreen`’de `AuthManager.getToken()` ile oturum kontrolü
- [ ] Flutter: `ApiService` tüm isteklere `Authorization: Bearer <token>` ekle
- [ ] Çıkış yap (`AuthManager.logout`) ve UI güncellemesi
- [ ] Frontend ↔ backend **SkinType enum** değerlerini hizala
- [ ] `auth.py` login’de `clean_email` kullanımı ve tekrarlayan doğrulama temizliği
- [ ] Debug `print` ifadelerini kaldır

### Aşama B — Profil ve kişiselleştirme
- [ ] Profil kaydında JWT zorunluluğu
- [ ] `GET /users/me` — mevcut kullanıcı profilini döndür
- [ ] Flutter: profil ekranında backend’den veri yükleme
- [ ] `goals` (yüz/saç/vücut hedefleri) JSONB yapısını modele ve UI’a ekle

### Aşama C — Hibrit analiz motoru (MVP’nin çekirdeği)
- [ ] `services/ai_service.py` — Gemini client
- [ ] System prompt: yalnızca JSON, `reason` sadece Caution/Avoid için
- [ ] `POST /api/v1/analyze` — OCR metni + kullanıcı profili → Gemini + DB merge
- [ ] `ingredients_master` ile `inci_name` / `aliases` eşleştirme
- [ ] Flutter: analiz sonucunu API’den besle (mock veriyi kaldır)
- [ ] Yasal uyarı (disclaimer) analiz sonuç ekranında

### Aşama D — OCR ve tarama
- [ ] `google_ml_kit` (veya Vision) entegrasyonu
- [ ] `camera` paketi ile gerçek kamera önizlemesi
- [ ] Deklanşör → metin çıkar → `/analyze` çağrısı
- [ ] Görüntü sıkıştırma (PRD 4.2)

### Aşama E — Ürünler, raf ve geçmiş
- [ ] `products` tablosu: barkod, ürün adı, içerik listesi, `is_verified`
- [ ] Self-enrichment: bilinmeyen ürünleri taslak olarak kaydet
- [ ] Verification Score: %80 eşleşme altı → taslak
- [ ] `GET /users/me/history` — son analizler
- [ ] `POST /users/me/shelf` — favori / rafa ekle
- [ ] Home ekranındaki `ProductCard` listesini API’ye bağla

### Aşama F — Kalite ve yayın
- [ ] Hata / offline fallback UI
- [ ] Rate limiting (kullanıcı başına günlük analiz limiti)
- [ ] Backend deploy (Render/Railway vb.)
- [ ] APK / store build hazırlığı
- [ ] (Opsiyonel) Google OAuth (`POST /auth/google`)
- [ ] (Opsiyonel) Dark mode — `ThemeData` extension

### Aşama G — Ödev / ders takibi (README)
- [ ] Ödev 1: MVP + PRD (büyük ölçüde tamam)
- [ ] Ödev 2: Plan + backend/frontend kurulum (büyük ölçüde tamam)
- [ ] Ödev 3: **Frontend Integration** — auth, profil, analiz, raf uçtan uca

---

## 5. Hızlı Referans

**Backend çalıştırma:**
```bash
cd backend
uvicorn app.main:app --reload