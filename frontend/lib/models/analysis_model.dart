
// PRD 4.2: Enum Tanımları
enum SkinType { KARMA, YAGLI, KURU, NORMAL, HASSAS }

enum RiskLevel { SAFE, CAUTION, AVOID }

class IngredientAnalysis {
  final String ingredient;
  final RiskLevel safety;
  final String? reason;

  IngredientAnalysis({
    required this.ingredient,
    required this.safety,
    this.reason,
  });

  factory IngredientAnalysis.fromJson(Map<String, dynamic> json) {
    return IngredientAnalysis(
      ingredient: json['ingredient'],
      // String gelen veriyi Enum'a çeviriyoruz
      safety: RiskLevel.values.firstWhere(
        (e) => e.name == (json['safety'] as String).toUpperCase(),
      ),
      reason: json['reason'],
    );
  }
}

class AnalysisResponse {
  final String productType;
  final List<IngredientAnalysis> alerts;
  final List<Map<String, String>> heroIngredients;
  final Map<String, String> overallRecommendation;

  AnalysisResponse({
    required this.productType,
    required this.alerts,
    required this.heroIngredients,
    required this.overallRecommendation,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      productType: json['product_type'],
      alerts: (json['alerts'] as List)
          .map((i) => IngredientAnalysis.fromJson(i))
          .toList(),
      heroIngredients: List<Map<String, String>>.from(
        json['hero_ingredients'].map((x) => Map<String, String>.from(x)),
      ),
      overallRecommendation: Map<String, String>.from(json['overall_recommendation']),
    );
  }
}