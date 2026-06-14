import 'package:flutter/material.dart';
import 'dart:ui';
import '../core/constants.dart';
import '../core/auth_manager.dart';
import '../core/api_service.dart';
import '../core/profile_mappings.dart';
import '../widgets/analysis_card.dart';
import '../widgets/product_card.dart';
import '../widgets/auth_bottom_sheet.dart';
import '../screens/skin_type_screen.dart';
import '../screens/scan_screen.dart';

// 1. Sınıf tanımı (StatefulWidget)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// 2. Asıl işin döndüğü "State" sınıfı
class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  String? _userSkinType;
  List<String> _userSensitivities = [];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = await AuthManager.getToken();
    if (!mounted) return;

    setState(() {
      _isLoggedIn = token != null;
    });

    if (token != null) {
      await _loadProfile();
    } else if (mounted) {
      setState(() {
        _userSkinType = null;
        _userSensitivities = [];
      });
    }

    print("DEBUG: _checkAuthStatus tetiklendi. Giriş durumu: $_isLoggedIn");
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService().getProfile();
    if (!mounted) return;

    setState(() {
      _userSkinType = profile?.skinType;
      _userSensitivities = profile != null
          ? ProfileMappings.backendSensitivitiesToLabels(profile.sensitivities)
          : [];
    });
  }

  // Bir butona basıldığında çağrılan Auth Sheet
  Future<void> _showAuthSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Tüm ekranı kaplayan bulanıklık katmanı
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context, false), // İptal edilirse false döner
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: Container(
                    color: AppColors.ink.withOpacity(0.01),
                  ),
                ),
              ),
            ),
            // Orijinal BottomSheet içeriği
            const AuthBottomSheet(),
          ],
        );
      },
    );
    
    // BottomSheet kapandıktan sonra burası çalışır
    if (result == true) {
      await _checkAuthStatus(); 
    } else {
      print("DEBUG: Pencere kapatıldı ama giriş yapılmadı veya true dönmedi.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. ADIM: AnalysisCard yönlendirmesi
            // 1. ADIM: Duruma göre akıllı yönlendirme yapan AnalysisCard
            GestureDetector(
              onTap: () async {
                if (_isLoggedIn) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SkinTypeScreen(
                        initialSkinType: _userSkinType,
                        initialSensitivities: _userSensitivities,
                      ),
                    ),
                  );

                  if (result != null && mounted) {
                    await _loadProfile();
                  }
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SkinTypeScreen(),
                    ),
                  );
                }
              },
              child: const AnalysisCard(), // TODO: İleride _isLoggedIn durumuna göre içine 'isCompleted: true' paslanabilir
            ),
            const SizedBox(height: 40),
            
            // 2. ADIM: Sadeleştirilmiş Yeni Tarama Butonu
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ScanScreen()),
                );
              },
              child: _buildScanButton(),
            ),
            
            // HATA BURADAYDI: _buildQuickActions() fonksiyon çağrısı tamamen kaldırıldı!
            const SizedBox(height: 40),
            
            _buildRecentHeader(),
            const SizedBox(height: 16),
            const ProductCard(
              brand: "LUMINESCE",
              name: "Hydrating Silk Serum",
              score: "%94",
              scoreColor: AppColors.sage,
              imageUrl: "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=200",
            ),
            const ProductCard(
              brand: "CORE BOTANICS",
              name: "Reset Night Balm",
              score: "%82",
              scoreColor: AppColors.terracotta,
              imageUrl: "https://images.unsplash.com/photo-1601049541289-9b1b7bbbfe19?w=200",
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: false, // Otomatik geri butonunu engelle
      leading: null,
      centerTitle: false,
      title: Text('SKINLENS', style: AppTextStyles.logoStyle),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _isLoggedIn
                ? IconButton(
                    icon: const Icon(
                      Icons.person_outline,
                      color: AppColors.ink,
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/profile'),
                  )
                : InkWell(
                    onTap: () => _showAuthSheet(context),
                    child: Text(
                      'GİRİŞ YAP',
                      style: AppTextStyles.monoLabel.copyWith(
                        color: AppColors.ink,
                      ),
                    ),
                  ),
          ),
        ),
      ],
      shape: const Border(
        bottom: BorderSide(color: AppColors.sand, width: 0.5),
      ),
    );
  }

  Widget _buildScanButton() {
    return Column(
      children: [
        Container(
          width: 180, // Metin tam sığsın diye geniş tutuldu
          height: 180,
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.sand, width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.center_focus_weak,
                size: 54,
                color: AppColors.sage.withOpacity(0.8),
              ),
              const SizedBox(height: 14),
              Text('ÜRÜN İÇERİĞİNİ TARAT', style: AppTextStyles.monoLabel),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'YAPAY ZEKA DESTEKLİ OCR ANALİZİ',
          style: TextStyle(fontSize: 9, color: AppColors.textMuted, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildRecentHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Son Analizlerin', style: AppTextStyles.sectionTitle),
        Text(
          'TÜMÜNÜ GÖR',
          style: AppTextStyles.monoLabel.copyWith(
            color: AppColors.sage,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.background,
      selectedItemColor: AppColors.ink,
      unselectedItemColor: AppColors.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedLabelStyle: AppTextStyles.monoLabel.copyWith(fontSize: 8),
      unselectedLabelStyle: AppTextStyles.monoLabel.copyWith(fontSize: 8),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ANASAYFA'),
        BottomNavigationBarItem(
          icon: Icon(Icons.center_focus_weak),
          label: 'TARAMA',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          label: 'KAYITLI',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'PROFİL',
        ),
      ],
    );
  }
}