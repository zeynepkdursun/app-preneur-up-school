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


**Aşama 3:** Köprü Kurma (Backend-Frontend Integration)
Feature'lara geçmeden önce Flutter ve FastAPI'nin birbiriyle konuşabildiğinden emin olmalıyız.

CORS & Middleware: Flutter uygulamasının (mobil emülatör/web) FastAPI'ye erişebilmesi için CORSMiddleware yapılandırmasını tamamla.

Pydantic Model Sync: Backend'deki User, Ingredient ve AnalysisResult modellerini oluşturup Cursor'dan bunların Dart karşılıklarını (Data Classes) üretmesini iste

**Aşama 4:** Profil ve Kişiselleştirme (UI: skin_type_selection.png)
Uygulamanın kalbi olan kişiselleştirme verisini backend'e bağlayalım.

Endpoint: POST /api/v1/users/profile

İşlev: Kullanıcının seçtiği cilt tipi (Kuru, Yağlı, Normal, Hassas) ve hassasiyetlerini PostgreSQL'deki users tablosuna (JSONB formatında) kaydet.

UI Entegrasyonu: "Profili Kaydet" butonuna basıldığında bu endpoint'e istek at ve kullanıcıyı ana sayfaya yönlendir.

**Aşama 5:** Hibrit Analiz Motoru (UI: scan_screen.png & analysis_result_screen.png)
Ödevinin en teknik ve puan getirecek kısmı burasıdır.

Endpoint: POST /api/v1/analyze

Backend Mantığı: 1. Flutter'dan gelen OCR metnini al.
2. Önce DB'den (ingredients_master) statik tanımları çek.
3. Kullanıcı profiliyle birlikte metni Gemini'ye gönder (7 kelime kuralı burada devreye girer).
4. Dinamik Karar: Eğer kullanıcı "Hassas" ciltliyse ve içerikte alkol varsa, Gemini bunu Avoid (Kırmızı) olarak işaretlemeli.

UI Çıktısı: analysis_result_screen.png'deki renk kodlu (Yeşil/Sarı/Kırmızı) listeyi bu API'den dönen JSON ile besle.

**Aşama 6:** Dijital Raf ve Geçmiş (UI: home_screen.png)
Uygulamanın sürekliliğini sağlayan "Raf" özelliğini backend tarafında tamamlayalım.

Endpoint: GET /api/v1/users/me/history

İşlev: Kullanıcının daha önce yaptığı analizleri tarih sırasına göre getir.

UI Entegrasyonu: Ana sayfadaki "Son Analizlerin" kartlarını bu endpoint'ten gelen verilerle (Ürün adı, uyumluluk yüzdesi, görsel URL) doldur.

Endpoint: POST /api/v1/users/me/shelf

UI Entegrasyonu: Analiz sonucu ekranındaki "Rafa Ekle (Favori)" butonunu bu endpoint'e bağla.

**Aşama 7:** Kimlik Doğrulama (UI: bottom_sheet_login.png)
Endpoint: POST /api/v1/auth/google & POST /api/v1/auth/login

İşlev: Firebase Auth veya özel bir JWT yapısı kullanarak kullanıcıyı sisteme dahil et.

Entegrasyon: Giriş yapılmadan "Rafa Ekle" veya "Profil Belirle" fonksiyonlarını korumaya al (Middleware).