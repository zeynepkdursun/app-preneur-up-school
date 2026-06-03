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

  @override
  void dispose() {
    _ingredientsController.dispose();
    super.dispose();
  }

  void _submitAnalysis() {
    // Formun boş olup olmadığını kontrol ediyoruz
    if (_formKey.currentState!.validate()) {
      
      // 1. Kullanıcının elle girdiği veya yapıştırdığı metni alıyoruz
      final String inputIngredients = _ingredientsController.text.trim();

      // 2. FastAPI backend'inin beklediği şemaya uygun DTO'yu (Request nesnesini) oluşturuyoruz
      // NOT: Cilt tipi, hedefler ve hassasiyetler ileride Auth/User profilinden dinamik çekilecek.
      // Şimdilik test için PRD'ye uygun mock sabitler veriyoruz.
      final requestPayload = IngredientAnalysisRequest(
        ocrText: inputIngredients,
        applicationArea: "yuz",
        productType: "yuz_nemlendiricisi",
        skinType: "yagli",
        sensitivities: ["parfum"],
        goals: ["yag_dengeleme"],
      );

      // 3. Oluşturulan payload'u Result ekranına paslayarak sayfayı açıyoruz
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
          key: _formKey, // Form validasyonu için key bağlantısı
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "İçerik Listesini Girin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Kozmetik ürününüzün arkasında yer alan içerikleri (INCI listesini) aralarına virgül koyarak yazın veya yapıştırın.",
                style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              
              // Metin Giriş Alanı
              TextFormField(
                controller: _ingredientsController,
                maxLines: 8,
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
                onPressed: _submitAnalysis, // Tıklandığında yukarıdaki metot çalışır
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