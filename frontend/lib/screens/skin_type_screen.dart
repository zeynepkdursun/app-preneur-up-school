import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/skin_type_option.dart';
import '../widgets/sensitivity_chip.dart';
import '../core/api_service.dart';

class SkinTypeScreen extends StatefulWidget {
  final String? initialSkinType;
  final List<String>? initialSensitivities;

  const SkinTypeScreen({
    super.key, 
    this.initialSkinType, 
    this.initialSensitivities,
  });

  @override
  State<SkinTypeScreen> createState() => _SkinTypeScreenState();
}

class _SkinTypeScreenState extends State<SkinTypeScreen> {
  final ApiService _apiService = ApiService();
  bool _isSaving = false;

  // Seçilen Türkçe etiket
  String selectedLabel = "";
  
  // Backend enums karşılıkları
  final Map<String, String> skinTypeMap = {
    "Yağlı": "yagli",
    "Kuru": "kuru",
    "Karma": "karma",
    "Normal": "normal",
    "Hassas": "hassas",
  };

  Map<String, bool> sensitivities = {
    "Alkol": false, 
    "Parfüm": false, 
    "Gluten / Diğer": false
  };

  @override
  void initState() {
    super.initState();
    
    // 1. ÖNCEDEN SEÇİLİ CİLT TİPİ VARSA BUL VE SET ET (UX EFFECTIVENESS)
    if (widget.initialSkinType != null) {
      try {
        // Backend string değerini arayüzdeki Türkçe etiket anahtarı (key) ile güvenli bir şekilde eşleştiriyoruz
        final matchingKey = skinTypeMap.entries
            .firstWhere((e) => e.value == widget.initialSkinType!.toLowerCase())
            .key;
        
        selectedLabel = matchingKey;
      } catch (_) {
        selectedLabel = "";
      }
    }

    // 2. ÖNCEDEN SEÇİLİ HASSASİYETLER VARSA AKTİF ET
    if (widget.initialSensitivities != null) {
      for (var element in widget.initialSensitivities!) {
        try {
          final matchingKey = sensitivities.keys.firstWhere(
            (k) => k.toLowerCase() == element.toLowerCase(),
          );
          sensitivities[matchingKey] = true;
        } catch (_) {
          // Eşleşme bulunamazsa sessizce devam et
        }
      }
    }
  }

  // Mod Kontrolü: Eğer initial veriler geldiyse bu bir Düzenleme akışıdır
  bool get _isEditing => widget.initialSkinType != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepBadge(),
            const SizedBox(height: 16),
            Text(
              _isEditing ? "Profilini Güncelle." : "Kişiselleştirilmiş Bakım Deneyimi.", 
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              _isEditing 
                  ? "Cilt yapınız zamanla değişebilir. Mevcut durumunuza göre ayarlarınızı buradan güncelleyebilirsiniz."
                  : "Cilt tipinizi ve hassasiyetlerinizi belirleyerek size en uygun ürün analizlerini sunmamıza yardımcı olun.", 
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 32),
            const Text("Hangi cilt tipine sahipsin?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...skinTypeMap.keys.map((label) => SkinTypeOption(
              label: label,
              isSelected: selectedLabel == label,
              onTap: () { 
                if (_isSaving) return; 
                setState(() => selectedLabel = label);  
              },
            )),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Divider(color: AppColors.sand, thickness: 0.5),
            ),
            const Text("Hassasiyetin var mı?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildSensitivitiesGrid(),
          ],
        ),
      ),
      bottomSheet: _buildSaveButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.background.withOpacity(0.95),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.ink), 
        onPressed: _isSaving ? null : () => Navigator.pop(context),
      ),
      title: Text(
        _isEditing ? "PROFİLİ GÜNCELLE" : "CİLT TİPİNİ SEÇ", 
        style: const TextStyle(color: AppColors.ink, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 24.0),
          child: Center(child: Text("SKINLENS", style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w300, fontSize: 20, letterSpacing: 1.5))),
        ),
      ],
    );
  }

  Widget _buildStepBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.terracotta.withOpacity(0.08),
        border: Border.all(color: AppColors.terracotta.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _isEditing ? "AYARLAR / GÜNCELLE" : "ADIM 01 / PROFIL", 
        style: const TextStyle(color: AppColors.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildSensitivitiesGrid() {
    return Wrap(
      spacing: 12, runSpacing: 12,
      children: sensitivities.keys.map((s) => SizedBox(
        width: s == "Gluten / Diğer" ? double.infinity : (MediaQuery.of(context).size.width - 60) / 2,
        child: SensitivityChip(
          label: s,
          isSelected: sensitivities[s]!,
          onChanged: (val) {
            if (_isSaving) return; 
            setState(() => sensitivities[s] = val!);
          },
        ),
      )).toList(),
    );
  }

  Widget _buildSaveButton() {
    bool isButtonEnabled = selectedLabel.isNotEmpty && !_isSaving;

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.background,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
        onPressed: isButtonEnabled ? _handleProfileSave : null,
        child: _isSaving 
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isEditing ? "DEĞİŞİKLİKLERİ KAYDET" : "PROFİLİ KAYDET", style: const TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Future<void> _handleProfileSave() async {
    setState(() => _isSaving = true);
    String formattedType = skinTypeMap[selectedLabel]!;

    try {
      final success = await _apiService.saveProfile(formattedType, sensitivities);

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          Navigator.pop(context, true); // Geriye başarılı sinyali uçuruyoruz
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profil güncellenemedi. Lütfen tekrar deneyin.")),
          );
        }
      }
    } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bağlantı Hatası: $e")),
          );
        }
    }
  }
}