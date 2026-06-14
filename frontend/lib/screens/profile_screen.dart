import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/profile_mappings.dart';
import '../widgets/profile_menu_item.dart';
import 'home_screen.dart';
import 'skin_type_screen.dart';
import '../core/auth_manager.dart';
import '../core/api_service.dart';
import '../core/local_profile_manager.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();

  bool _isLoggedIn = false;
  String? _userSkinType;
  List<String> _userSensitivities = [];
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthManager.getToken();
    if (!mounted) return;
    setState(() => _isLoggedIn = token != null);
    if (token != null) {
      await _loadProfile();
    } else {
      await _loadLocalProfile();
    }
  }

  Future<void> _loadProfile() async {
    final profile = await _apiService.getProfile();
    if (!mounted) return;

    setState(() {
      _isLoadingProfile = false;
      if (profile != null) {
        _userSkinType = profile.skinType;
        _userSensitivities =
            ProfileMappings.backendSensitivitiesToLabels(profile.sensitivities);
      }
    });
  }

  Future<void> _loadLocalProfile() async {
    final localProfile = await LocalProfileManager.loadProfile();
    if (!mounted) return;

    setState(() {
      _isLoadingProfile = false;
      if (localProfile != null) {
        _userSkinType = localProfile.skinType;
        _userSensitivities =
            ProfileMappings.backendSensitivitiesToLabels(localProfile.sensitivities);
      }
    });
  }

  String _getSkinTypeTranslation(String? backendType) {
    return ProfileMappings.skinTypeToDisplay(backendType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle("HESAP VE BAKIM AYARLARI"),
            const SizedBox(height: 12),
            _buildMenuGroup(context),
            const SizedBox(height: 40),
            _buildLegalDisclaimer(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "PROFİLİM",
        style: TextStyle(
          color: AppColors.ink,
          fontSize: 12,
          letterSpacing: 2,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              "SKINLENS",
              style: AppTextStyles.logoStyle.copyWith(fontSize: 16),
            ),
          ),
        ),
      ],
      shape: const Border(
        bottom: BorderSide(color: AppColors.sand, width: 0.5),
      ),
    );
  }

  Widget _buildUserHeader() {
    return Row(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.warmWhite,
            border: Border.all(color: AppColors.sand, width: 1.5),
          ),
          child: const Center(
            child: Icon(
              Icons.person_outline,
              size: 36,
              color: AppColors.ink,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Cilt Analiz Profili",
                style: AppTextStyles.monoLabel.copyWith(
                  color: AppColors.sand,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _isLoggedIn ? "Kullanıcı" : "Misafir", 
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.monoLabel.copyWith(
        color: AppColors.textMuted,
        fontSize: 11,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.bubble_chart_outlined,
          title: "Cilt Profilini Güncelle",
          trailingText: _isLoadingProfile
              ? "..."
              : _getSkinTypeTranslation(_userSkinType),
          onTap: _isLoadingProfile ? () {} : () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SkinTypeScreen(
                  initialSkinType: _userSkinType,
                  initialSensitivities: _userSensitivities,
                  isGuest: !_isLoggedIn,
                ),
              ),
            );

            if (result != null && mounted) {
              if (_isLoggedIn) {
                final profile = result as UserProfile;
                setState(() {
                  _userSkinType = profile.skinType;
                  _userSensitivities =
                      ProfileMappings.backendSensitivitiesToLabels(
                    profile.sensitivities,
                  );
                });
              } else {
                await _loadLocalProfile();
              }
            }
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.bookmark_border_rounded,
          title: "Dijital Rafım (Favoriler)",
          onTap: () {
            // PRD 4.3 - GET /api/v1/favorites sayfasına yönlendirme yapılacak
          },
        ),
        const SizedBox(height: 12),
        ProfileMenuItem(
          icon: Icons.shield_moon_outlined,
          title: "Hassasiyet Bildirimleri",
          onTap: () {},
        ),
        const SizedBox(height: 24),
        const Divider(color: AppColors.sand, thickness: 0.5),
        const SizedBox(height: 12),
        _isLoggedIn
            ? ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: "Oturumu Kapat",
                isDestructive: true,
                onTap: () async {
                  await AuthManager.logout();
                  ApiService().reset();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
                    );
                  }
                },
              )
            : ProfileMenuItem(
                icon: Icons.login_rounded,
                title: "Giriş Yap",
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (route) => false,
                  );
                },
              ),
      ],
    );
  }

  Widget _buildLegalDisclaimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Tıbbi tavsiye değildir, yapay zeka destekli bilgilendirmedir.",
              style: AppTextStyles.bodyMd.copyWith(
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}