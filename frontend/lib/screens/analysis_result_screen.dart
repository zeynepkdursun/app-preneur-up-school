// lib/screens/analysis_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../core/constants.dart';
import '../core/api_service.dart';
import '../models/analysis_model.dart';
import '../widgets/analysis_score_circle.dart';
import '../widgets/ingredient_analysis_tile.dart';

class AnalysisResultScreen extends StatefulWidget {
  final IngredientAnalysisRequest analysisRequest;

  const AnalysisResultScreen({super.key, required this.analysisRequest});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  final IApiService _apiService = ApiService();
  late Future<SkinLensAnalysisOutput> _analysisFuture;

  @override
  void initState() {
    super.initState();
    // Ekran ayağa kalktığı an backend servis çağrısını başlatıyoruz
    _analysisFuture = _apiService.analyzeIngredients(widget.analysisRequest);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ANALİZ SONUCU",
          style: TextStyle(
            color: AppColors.primary,
            letterSpacing: 2.0,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share, color: AppColors.primary),
          ),
        ],
      ),
      body: FutureBuilder<SkinLensAnalysisOutput>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    "İçerikler analiz ediliyor...", // PRD: UX Feedbacks
                    style: TextStyle(color: AppColors.secondary, letterSpacing: 1.2),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  "${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text("Veri alınamadı."));
          }

          final data = snapshot.data!;

          if (kDebugMode) {
            print("Analiz sonucu — caution: ${data.caution.length}, avoid: ${data.avoid.length}, hero: ${data.heroIngredients.length}");
          }
          
          // Dinamik Skor Hesaplama Mantığı (Basitçe riskli madde sayısına göre oranlayabiliriz)
          final int penalty = (data.avoid.length * 20) + (data.caution.length * 7);
          final int calculatedScore = (100 - penalty).clamp(0, 100);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Center(
                    child: AnalysisScoreCircle(
                      score: calculatedScore, 
                      label: calculatedScore > 75 ? "İyi" : (calculatedScore > 45 ? "Hassas" : "Riskli"),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "ÜRÜN TİPİ",
                    style: TextStyle(letterSpacing: 2, fontSize: 12, color: AppColors.secondary),
                  ),
                  Text(
                    widget.analysisRequest.productType,
                    style: const TextStyle(fontFamily: 'NotoSerif', fontSize: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: 32),

                  // Personal Analysis Card (PRD'deki 7 kelimelik özetleri ve yorumları besliyoruz)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.secondary),
                          color: AppColors.surfaceContainer,
                        ),
                        child: Text(
                          data.avoid.isNotEmpty 
                              ? "Bu ürün rutininiz için ciddi riskli maddeler barındırıyor. Detayları aşağıdan inceleyebilirsiniz."
                              : "Ürün hedeflerinize büyük oranda hizmet ediyor. Güvenle değerlendirebilirsiniz.",
                          style: const TextStyle(fontSize: 16, height: 1.6, color: AppColors.primary),
                        ),
                      ),
                      Positioned(
                        top: -12,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          color: AppColors.surfaceContainer,
                          child: const Text(
                            "Sizin İçin AI Özeti",
                            style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // İçerik Analizi Başlığı
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.secondary.withOpacity(0.2))),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text("İÇERİK ANALİZİ", style: TextStyle(letterSpacing: 2, fontSize: 10, color: AppColors.secondary)),
                      ),
                      Expanded(child: Divider(color: AppColors.secondary.withOpacity(0.2))),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. HERO INGREDIENTS (Faydalı Maddeler)
                  ...data.heroIngredients.map((item) => IngredientAnalysisTile(
                        name: item.ingredient,
                        category: item.reason,
                        icon: Icons.check_circle,
                        iconColor: const Color(0xFFB4CDB8), // PRD Green
                      )),

                  // 2. CAUTION INGREDIENTS (Dikkat Edilmesi Gerekenler)
                  ...data.caution.map((item) => IngredientAnalysisTile(
                        name: item.ingredient,
                        category: item.reason, // Maks 7 Kelimelik Açıklama
                        icon: Icons.warning,
                        iconColor: const Color(0xFFFDCB9B), // PRD Yellow
                        textColor: const Color(0xFF79542D),
                      )),

                  // 3. AVOID INGREDIENTS (Kesinlikle Kaçınılması Gerekenler)
                  ...data.avoid.map((item) => IngredientAnalysisTile(
                        name: item.ingredient,
                        category: item.reason, // Cilt tipine özel neden
                        icon: Icons.dangerous,
                        iconColor: Colors.red, // PRD Red
                        textColor: Colors.red,
                      )),

                  // Eğer hiçbir liste dolu gelmediyse statik temiz mesajı verelim
                  if (data.avoid.isEmpty && data.caution.isEmpty && data.heroIngredients.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Herhangi bir riskli veya öne çıkan hero bileşene rastlanmadı."),
                    ),

                  const SizedBox(height: 48),
                  const Text(
                    "TIBBİ TAVSİYE DEĞİLDİR, YAPAY ZEKA DESTEKLİ BİLGİLENDİRMEDİR.", // PRD Legal Disclaimer
                    style: TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: _buildBottomSheet(),
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surfaceContainer.withOpacity(0.8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 64),
          shape: const RoundedRectangleBorder(),
        ),
        onPressed: () {
          // TODO: Favori rafına ekleme endpoint'ini tetikle (/api/v1/favorites)
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark, color: Color(0xFFFFDCBD)),
            SizedBox(width: 12),
            Text(
              "RAFA EKLE (FAVORİ)",
              style: TextStyle(color: Color(0xFFFFDCBD), letterSpacing: 2, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}