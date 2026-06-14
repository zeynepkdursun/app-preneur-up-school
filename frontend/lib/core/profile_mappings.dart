class ProfileMappings {
  ProfileMappings._();

  static const Map<String, String> skinTypeLabelsToBackend = {
    'Yağlı': 'yagli',
    'Kuru': 'kuru',
    'Karma': 'karma',
    'Normal': 'normal',
    'Hassas': 'hassas',
  };

  static const Map<String, String> sensitivityLabelsToBackend = {
    'Alkol': 'alkol',
    'Parfüm': 'parfum',
    'Gluten / Diğer': 'gluten',
  };

  static String skinTypeToDisplay(String? backendType) {
    if (backendType == null || backendType.isEmpty) return 'Belirtilmedi';

    final normalized = backendType.toLowerCase();
    for (final entry in skinTypeLabelsToBackend.entries) {
      if (entry.value == normalized) return entry.key;
    }
    return 'Karma';
  }

  static String? backendToSkinTypeLabel(String? backendType) {
    if (backendType == null || backendType.isEmpty) return null;

    final normalized = backendType.toLowerCase();
    for (final entry in skinTypeLabelsToBackend.entries) {
      if (entry.value == normalized) return entry.key;
    }
    return null;
  }

  static String? backendToSensitivityLabel(String backendValue) {
    final normalized = backendValue.toLowerCase();
    for (final entry in sensitivityLabelsToBackend.entries) {
      if (entry.value == normalized) return entry.key;
    }

    for (final label in sensitivityLabelsToBackend.keys) {
      if (label.toLowerCase() == normalized) return label;
    }
    return null;
  }

  static List<String> backendSensitivitiesToLabels(List<String> backendValues) {
    return backendValues
        .map(backendToSensitivityLabel)
        .whereType<String>()
        .toList();
  }
}
