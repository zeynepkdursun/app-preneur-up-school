import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants.dart';
import '../core/api_service.dart';
import '../core/profile_mappings.dart';
import '../models/analysis_model.dart';
import 'analysis_result_screen.dart';

class ScanScreen extends StatefulWidget {
  final String? skinType;
  final List<String>? sensitivities;

  const ScanScreen({super.key, this.skinType, this.sensitivities});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final TextEditingController _manualController = TextEditingController();

  final List<String> _selectedAreas = [];
  String? _selectedProductType;

  final Map<String, String> _areaLabels = {
    'yuz': '👩 Yüz',
    'el': '🖐️ El',
    'vucut': '🧴 Vücut',
    'sac': '💆 Saç',
  };

  XFile? _selectedImage;
  String _extractedText = '';
  bool _isProcessingOcr = false;
  bool _useOcr = true;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _getFilteredCategories() {
    final allCategories = [
      {'value': 'yuz_nemlendiricisi', 'label': 'Yüz Nemlendiricisi', 'areas': 'yuz'},
      {'value': 'gunes_kremi', 'label': 'Güneş Kremi', 'areas': 'yuz,vucut,el'},
      {'value': 'tonik', 'label': 'Tonik', 'areas': 'yuz'},
      {'value': 'yuz_temizleme_jeli', 'label': 'Yüz Temizleme Jeli', 'areas': 'yuz'},
      {'value': 'el_kremi', 'label': 'El Kremi', 'areas': 'el'},
      {'value': 'vucut_losyonu', 'label': 'Vücut Losyonu', 'areas': 'vucut'},
      {'value': 'sampuan', 'label': 'Şampuan', 'areas': 'sac'},
    ];

    if (_selectedAreas.isEmpty) return [];

    return allCategories.where((category) {
      final categoryAreas = category['areas']!.split(',');
      return _selectedAreas.any((area) => categoryAreas.contains(area));
    }).toList();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _extractedText = '';
      });
    }
  }

  Future<void> _runOcr() async {
    if (_selectedImage == null) return;

    setState(() => _isProcessingOcr = true);

    try {
      final text = await ApiService().extractOcr(_selectedImage!.path);

      setState(() {
        _extractedText = text;
        _isProcessingOcr = false;
      });
    } catch (e) {
      if (kDebugMode) print("OCR hatası: $e");
      setState(() => _isProcessingOcr = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OCR işlenemedi: $e")),
        );
      }
    }
  }

  String get _analysisText {
    if (_useOcr && _extractedText.isNotEmpty) return _extractedText;
    return _manualController.text.trim();
  }

  void _submitAnalysis() {
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

    final text = _analysisText;
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir fotoğraf yükleyip OCR çalıştırın veya içerikleri manuel girin.')),
      );
      return;
    }

    final resolvedSensitivities = widget.sensitivities != null
        ? widget.sensitivities!
            .map((s) => ProfileMappings.sensitivityLabelsToBackend[s] ?? s.toLowerCase())
            .toList()
        : ["parfum"];

    final requestPayload = IngredientAnalysisRequest(
      ocrText: text,
      applicationArea: _selectedAreas,
      productType: _selectedProductType!,
      skinType: widget.skinType ?? "yagli",
      sensitivities: resolvedSensitivities,
      goals: ["yag_dengeleme"],
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisResultScreen(analysisRequest: requestPayload),
      ),
    );
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
          "OCR İÇERİK ANALİZİ",
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. UYGULAMA BÖLGESİ SEÇİMİ
            const Text(
              "Uygulama Bölgesi Seçin (Çoklu Seçim)",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
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
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedAreas.add(entry.key);
                      } else {
                        _selectedAreas.remove(entry.key);
                      }
                      _selectedProductType = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 2. ÜRÜN KATEGORİSİ
            const Text(
              "Ürün Kategorisi",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedProductType,
              hint: Text(
                _selectedAreas.isEmpty ? "Önce yukarıdan bölge seçin" : "Kategori seçiniz",
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
              items: _selectedAreas.isEmpty
                  ? null
                  : filteredCategories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['value'],
                        child: Text(cat['label']!),
                      );
                    }).toList(),
              onChanged: (value) => setState(() => _selectedProductType = value),
              validator: (value) => value == null ? "Lütfen bir ürün kategorisi seçin." : null,
            ),
            const SizedBox(height: 24),

            const Divider(color: AppColors.outlineVariant, height: 32),

            // 3. GİRİŞ YÖNTEMİ SEÇİMİ
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text("OCR ile Tara"), icon: Icon(Icons.camera_alt)),
                ButtonSegment(value: false, label: Text("Manuel Giriş"), icon: Icon(Icons.edit)),
              ],
              selected: {_useOcr},
              onSelectionChanged: (v) => setState(() => _useOcr = v.first),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return AppColors.ink;
                  return AppColors.surfaceContainerLow;
                }),
                foregroundColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) return Colors.white;
                  return AppColors.textMuted;
                }),
              ),
            ),
            const SizedBox(height: 20),

            if (_useOcr) _buildOcrSection() else _buildManualSection(),

            const SizedBox(height: 24),

            // 5. ANALİZ BUTONU
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
                    style: TextStyle(color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOcrSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fotoğraf Yükle",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          "Ürünün içerik listesinin fotoğrafını yükleyin, OCR otomatik olarak metni çıkaracaktır.",
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),

        // Upload area
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: _selectedImage != null ? 220 : 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              border: Border.all(
                color: AppColors.secondary.withOpacity(0.3),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _selectedImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedImage = null;
                            _extractedText = '';
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.secondary.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        "Fotoğraf Seçmek için Dokun",
                        style: TextStyle(color: AppColors.secondary.withOpacity(0.7), fontSize: 14),
                      ),
                    ],
                  ),
          ),
        ),

        if (_selectedImage != null && _extractedText.isEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessingOcr ? null : _runOcr,
              icon: _isProcessingOcr
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.text_snippet, color: Colors.white),
              label: Text(_isProcessingOcr ? "OCR İşleniyor..." : "OCR'ı Çalıştır"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],

        if (_extractedText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.sage, size: 18),
              const SizedBox(width: 8),
              Text(
                "OCR Tamamlandı — ${_extractedText.split(RegExp(r'[,;]\s*')).length} içerik bulundu",
                style: const TextStyle(fontSize: 13, color: AppColors.sage, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.secondary.withOpacity(0.15)),
            ),
            child: Text(
              _extractedText,
              style: const TextStyle(fontSize: 14, color: AppColors.primary, height: 1.5),
            ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () {
              _manualController.text = _extractedText;
              setState(() => _useOcr = false);
            },
            icon: const Icon(Icons.edit, size: 16),
            label: const Text("Metni düzenle", style: TextStyle(fontSize: 13)),
          ),
        ],
      ],
    );
  }

  Widget _buildManualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "İçerik Listesini Girin",
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        const Text(
          "Kozmetik ürününüzün arkasında yer alan içerikleri (INCI listesini) aralarına virgül koyarak yazın veya yapıştırın.",
          style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _manualController,
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
          ),
        ),
      ],
    );
  }
}
