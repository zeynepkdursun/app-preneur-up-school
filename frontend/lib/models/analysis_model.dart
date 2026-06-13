
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


class IngredientReportItem {
  final String ingredient;
  final String reason;

  IngredientReportItem({
    required this.ingredient,
    required this.reason,
  });

  factory IngredientReportItem.fromJson(Map<String, dynamic> json) {
    return IngredientReportItem(
      ingredient: json['ingredient'] ?? '',
      reason: json['reason'] ?? '',
    );
  }
}

class SkinLensAnalysisOutput {
  final List<IngredientReportItem> caution;
  final List<IngredientReportItem> avoid;
  final List<IngredientReportItem> heroIngredients;

  SkinLensAnalysisOutput({
    required this.caution,
    required this.avoid,
    required this.heroIngredients,
  });

  factory SkinLensAnalysisOutput.fromJson(Map<String, dynamic> json) {
    return SkinLensAnalysisOutput(
      caution: (json['caution'] as List? ?? [])
          .map((i) => IngredientReportItem.fromJson(i))
          .toList(),
      avoid: (json['avoid'] as List? ?? [])
          .map((i) => IngredientReportItem.fromJson(i))
          .toList(),
      heroIngredients: (json['hero_ingredients'] as List? ?? [])
          .map((i) => IngredientReportItem.fromJson(i))
          .toList(),
    );
  }
}

// Backend POST request gövdesi için DTO (Data Transfer Object)
class IngredientAnalysisRequest {
  final String ocrText;
  final List<String> applicationArea; // String yerine List<String> yapıldı
  final String productType;
  final String skinType;
  final List<String> sensitivities;
  final List<String> goals;

  IngredientAnalysisRequest({
    required this.ocrText,
    required this.applicationArea,
    required this.productType,
    required this.skinType,
    this.sensitivities = const [],
    this.goals = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'ocr_text': ocrText,
      // Tüm seçimleri küçük harfe çevirerek listeliyoruz
      'application_area': applicationArea.map((e) => e.toLowerCase()).toList(),
      'product_type': productType.toLowerCase(),
      'skin_type': skinType.toLowerCase(),
      'sensitivities': sensitivities,
      'goals': goals,
    };
  }
}