import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfile {
  final String skinType;
  final List<String> sensitivities;

  LocalProfile({required this.skinType, this.sensitivities = const []});

  Map<String, dynamic> toJson() => {
        'skinType': skinType,
        'sensitivities': sensitivities,
      };

  factory LocalProfile.fromJson(Map<String, dynamic> json) => LocalProfile(
        skinType: json['skinType'] as String,
        sensitivities: (json['sensitivities'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class LocalProfileManager {
  LocalProfileManager._();

  static const _skinTypeKey = 'local_skin_type';
  static const _sensitivitiesKey = 'local_sensitivities';

  static Future<void> saveProfile(String skinType, List<String> sensitivities) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_skinTypeKey, skinType);
    await prefs.setString(_sensitivitiesKey, jsonEncode(sensitivities));
  }

  static Future<LocalProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final skinType = prefs.getString(_skinTypeKey);
    final sensitivitiesRaw = prefs.getString(_sensitivitiesKey);

    if (skinType == null) return null;

    List<String> sensitivities = [];
    if (sensitivitiesRaw != null) {
      final decoded = jsonDecode(sensitivitiesRaw) as List<dynamic>;
      sensitivities = decoded.map((e) => e.toString()).toList();
    }

    return LocalProfile(skinType: skinType, sensitivities: sensitivities);
  }

  static Future<bool> hasProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_skinTypeKey);
  }

  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_skinTypeKey);
    await prefs.remove(_sensitivitiesKey);
  }
}
