import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/analysis_score_circle.dart';
import '../widgets/ingredient_analysis_tile.dart';

class AnalysisResultScreen extends StatelessWidget {
  const AnalysisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: AppColors.primary),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: AppColors.secondary.withOpacity(0.2), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Score Section
              const Center(
                child: AnalysisScoreCircle(score: 85, label: "İyi"),
              ),
              const SizedBox(height: 24),
              const Text(
                "TAHMİN EDİLEN",
                style: TextStyle(letterSpacing: 2, fontSize: 12, color: AppColors.secondary),
              ),
              const Text(
                "Güneş Kremi",
                style: TextStyle(fontFamily: 'NotoSerif', fontSize: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 32),

              // Product Image placeholder
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  border: Border.all(color: AppColors.secondary.withOpacity(0.1)),
                ),
                child: Image.network(
                  "https://placeholder.com/prod_image", // Gerçek URL gelecek
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),

              // Personal Analysis Card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.secondary),
                      color: AppColors.surfaceContainer,
                    ),
                    child: const Text(
                      "Bu ürün yağlı cildin için uygundur, gözenek tıkama riski düşük. Formülündeki hafif doku sayesinde gün boyu ağırlık yapmaz.",
                      style: TextStyle(fontSize: 18, height: 1.6, color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.surfaceContainer,
                      child: const Text(
                        "Sizin İçin",
                        style: TextStyle(fontSize: 12, color: AppColors.secondary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // Ingredient Analysis List
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
              const IngredientAnalysisTile(
                name: "Aqua",
                category: "Nemlendirici",
                icon: Icons.check_circle,
                iconColor: Color(0xFFB4CDB8),
              ),
              const IngredientAnalysisTile(
                name: "Glycerin",
                category: "Yumuşatıcı",
                icon: Icons.check_circle,
                iconColor: Color(0xFFB4CDB8),
              ),
              const IngredientAnalysisTile(
                name: "Parfum",
                category: "Hassasiyet Riski!",
                icon: Icons.warning,
                iconColor: Color(0xFFFDCB9B),
                textColor: Color(0xFF79542D),
              ),
              const IngredientAnalysisTile(
                name: "Oxybenzone",
                category: "Kaçınmalısın",
                icon: Icons.dangerous,
                iconColor: Colors.red,
                textColor: Colors.red,
              ),
              
              const SizedBox(height: 48),
              const Text("BU BİR TIBBİ TAVSİYE DEĞİLDİR.", style: TextStyle(fontSize: 10, letterSpacing: 1, color: Colors.grey)),
              const SizedBox(height: 100), // Alt buton için boşluk
            ],
          ),
        ),
      ),
      // Bottom Action Bar
      bottomSheet: Container(
        padding: const EdgeInsets.all(24),
        color: AppColors.surfaceContainer.withOpacity(0.8),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 64),
            shape: const RoundedRectangleBorder(),
          ),
          onPressed: () {},
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
      ),
    );
  }
}