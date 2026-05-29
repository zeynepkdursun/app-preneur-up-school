

import 'package:flutter/material.dart';
// Doğru kullanım: package:PROJE_ADI/KLASÖR/DOSYA.dart
import 'package:skinlens_app/core/constants.dart'; 
import 'package:skinlens_app/screens/home_screen.dart';
import 'package:skinlens_app/screens/skin_type_screen.dart';

import 'package:skinlens_app/screens/scan_screen.dart';

void main() {
  // Buradaki const kalabilir
  runApp(const SkinLensApp());
}

class SkinLensApp extends StatelessWidget {
  const SkinLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    // BURAYA DİKKAT: MaterialApp başında 'const' VARSA SİL!
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkinLens',
      theme: ThemeData(
        // Bu satırlar artık yukarıdaki import sayesinde çalışacak
        scaffoldBackgroundColor: AppColors.background, 
        primaryColor: AppColors.ink,
      ),
      home: const HomeScreen(), // HomeScreen sabit olabilir, bu kalsın.
      // Başlangıç rotası
      initialRoute: '/home', 
      routes: {
        '/skin-type': (context) => const SkinTypeScreen(),
        '/home': (context) => const HomeScreen(), // Hatanın çözümü burası
        '/profile': (context) => const ScanScreen(), // İŞTE EKSİK OLAN ADRES BURASI!
      },
    );
  }
}