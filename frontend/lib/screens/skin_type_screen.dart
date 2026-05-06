import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../widgets/skin_type_option.dart';
import '../widgets/sensitivity_chip.dart';

class SkinTypeScreen extends StatefulWidget {
  const SkinTypeScreen({super.key});

  @override
  State<SkinTypeScreen> createState() => _SkinTypeScreenState();
}

class _SkinTypeScreenState extends State<SkinTypeScreen> {
  String selectedType = "";
  Map<String, bool> sensitivities = {"Alkol": false, "Parfüm": false, "Gluten / Diğer": false};

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
            const Text("Kişiselleştirilmiş Bakım Deneyimi.", 
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500, height: 1.2)),
            const SizedBox(height: 12),
            const Text("Cilt tipinizi ve hassasiyetlerinizi belirleyerek size en uygun ürün analizlerini sunmamıza yardımcı olun.", 
              style: TextStyle(color: AppColors.inkSoft, fontSize: 15, height: 1.4)),
            const SizedBox(height: 32),
            const Text("Hangi cilt tipine sahipsin?", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...["Kuru", "Karma / Yağlı", "Normal", "Hassas"].map((type) => SkinTypeOption(
              label: type,
              isSelected: selectedType == type,
              onTap: () => setState(() => selectedType = type),
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
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.ink), onPressed: () => Navigator.pop(context)),
      title: const Text("CİLT TİPİNİ SEÇ", style: TextStyle(color: AppColors.ink, fontSize: 12, letterSpacing: 2, fontWeight: FontWeight.w700)),
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
      child: const Text("ADIM 01 / PROFIL", style: TextStyle(color: AppColors.terracotta, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
          onChanged: (val) => setState(() => sensitivities[s] = val!),
        ),
      )).toList(),
    );
  }

  Widget _buildSaveButton() {
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
        onPressed: () {
          // Burada seçimleri kaydedip home'a dönebilirsin
          Navigator.pop(context);
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("PROFİLİ KAYDET", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward, size: 18),
          ],
        ),
      ),
    );
  }
}