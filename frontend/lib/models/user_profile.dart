class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? skinType;
  final List<String> sensitivities;

  const UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.skinType,
    this.sensitivities = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      skinType: json['skin_type']?.toString(),
      sensitivities: (json['sensitivities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
