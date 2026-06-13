// lib/screens/scan_screen.dart
import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/analysis_model.dart';
import 'analysis_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _ingredientsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Çoklu Seçim: Seçili Uygulama Bölgeleri (Backend Enum string karşılıkları)
  final List<String> _selectedAreas = [];

  // Tekli Seçim: Seçili Ürün Kategorisi
  String? _selectedProductType;

  // UI'da gösterilecek Türkçe etiketler ve backend enum karşılıkları haritası
  final Map<String, String> _areaLabels = {
    'yuz': '👩 Yüz',
    'el': '🖐️ El',
    'vucut': '🧴 Vücut',
    'sac': '💆 Saç',
  };

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  // Seçili bölgelere göre dinamik kategori listesi döndüren fonksiyon
  List<Map<String, String>> _getFilteredCategories() {
    // backend/app/models/enums.py içerisindeki ProductType enum değerleri
    final allCategories = [
      {'value': 'yuz_nemlendiricisi', 'label': 'Yüz Nemlendiricisi', 'areas': 'yuz'},
      {'value': 'gunes_kremi', 'label': 'Güneş Kremi', 'areas': 'yuz,vucut,el'},
      {'value': 'tonik', 'label': 'Tonik', 'areas': 'yuz'},
      {'value': 'yuz_temizleme_jeli', 'label': 'Yüz Temizleme Jeli', 'areas': 'yuz'},
      {'value': 'el_kremi', 'label': 'El Kremi', 'areas': 'el'},
      {'value': 'vucut_losyonu', 'label': 'Vücut Losyonu', 'areas': 'vucut'},
      {'value': 'sampuan', 'label': 'Şampuan', 'areas': 'sac'},
    ];

    if (_selectedAreas.isEmpty) {
      return [];
    }

    // Seçili bölgelerden en az biriyle ilişkili olan kategorileri filtrele
    return allCategories.where((category) {
      final categoryAreas = category['areas']!.split(',');
      return _selectedAreas.any((area) => categoryAreas.contains(area));
    }).toList();
  }

  void _submitAnalysis() {
    if (_formKey.currentState!.validate()) {
      if (_selectedAreas.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen en az bir uygulama bölgesi seçin.')),
        );
        return;
      }

      if (_selectedProductType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen ürün kategorisini seçin.')),
        );
        return;
      }

      final String inputIngredients = _ingredientsController.text.trim();

      // Çoklu bölge listemizi, seçilen dinamik kategori ve mock kullanıcı verilerini paketliyoruz
      final requestPayload = IngredientAnalysisRequest(
        ocrText: inputIngredients,
        applicationArea: _selectedAreas, // Artık List<String> gidiyor!
        productType: _selectedProductType!,
        skinType: "yagli", // İleride profilden çekilecek
        sensitivities: ["parfum"], // İleride profilden çekilecek
        goals: ["yag_dengeleme"], // İleride profilden çekilecek
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisResultScreen(analysisRequest: requestPayload),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _getFilteredCategories();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "MANUEL İÇERİK ANALİZİ",
          style: TextStyle(
            color: AppColors.primary,
            letterSpacing: 1.5,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. UYGULAMA BÖLGESİ SEÇİMİ (Çoklu Seçim - FilterChip)
              const Text(
                "Uygulama Bölgesi Seçin (Çoklu Seçim)",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _areaLabels.entries.map((entry) {
                  final isSelected = _selectedAreas.contains(entry.key);
                  return FilterChip(
                    label: Text(entry.value),
                    selected: isSelected,
                    selectedColor: AppColors.ink.withOpacity(0.15),
                    checkmarkColor: AppColors.ink,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.ink : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                    backgroundColor: AppColors.surfaceContainerLow,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: isSelected ? AppColors.ink : AppColors.outlineVariant.withOpacity(0.5),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedAreas.add(entry.key);
                        } else {
                          _selectedAreas.remove(entry.key);
                        }
                        // Bölgeler değiştiğinde seçili kategori geçersiz kalabilir, sıfırlıyoruz
                        _selectedProductType = null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // 2. ÜRÜN KATEGORİSİ SEÇİMİ (Dinamik Dropdown)
              const Text(
                "Ürün Kategorisi",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedProductType,
                hint: Text(
                  _selectedAreas.isEmpty 
                      ? "Önce yukarıdan bölge seçin" 
                      : "Kategori seçiniz",
                  style: TextStyle(color: AppColors.secondary.withOpacity(0.5), fontSize: 14),
                ),
                disabledHint: const Text("Önce yukarıdan bölge seçin"),
                style: const TextStyle(color: AppColors.primary, fontSize: 15),
                dropdownColor: AppColors.background,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
                // Eğer bölge seçilmediyse dropdown'ı kilitliyoruz
                items: _selectedAreas.isEmpty
                    ? null
                    : filteredCategories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat['value'],
                          child: Text(cat['label']!),
                        );
                      }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProductType = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Lütfen bir ürün kategorisi seçin.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              const Divider(color: AppColors.outlineVariant, height: 32),

              // 3. İÇERİK LİSTESİ METİN ALANI
              const Text(
                "İçerik Listesini Girin",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Kozmetik ürününüzün arkasında yer alan içerikleri (INCI listesini) aralarına virgül koyarak yazın veya yapıştırın.",
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _ingredientsController,
                maxLines: 6,
                style: const TextStyle(color: AppColors.primary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: "Örn: Aqua, Glycerin, Sodium Laureth Sulfate, Parfum, Zinc PCA...",
                  hintStyle: TextStyle(color: AppColors.secondary.withOpacity(0.5)),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.2)),
                  ),
                  errorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Lütfen analiz için içerik listesi girin.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Analiz Tetikleyici Buton
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: const RoundedRectangleBorder(),
                ),
                onPressed: _submitAnalysis,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    Text(
                      "İÇERİKLERİ ANALİZ ET",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}