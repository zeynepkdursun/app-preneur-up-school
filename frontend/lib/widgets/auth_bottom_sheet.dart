import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/api_service.dart';

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final success = await _apiService.login(email, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); // Geriye 'true' döndür
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hatalı e-posta veya şifre')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24, 
        right: 24, 
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.ink.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.sand, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          
          Text("SkinLens'e Katıl", style: AppTextStyles.sectionTitle.copyWith(fontSize: 28)),
          const SizedBox(height: 24),

          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "E-posta",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Şifre",
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),

          _isLoading 
            ? const CircularProgressIndicator(color: AppColors.sand)
            : _buildActionButton(
                label: "GİRİŞ YAP",
                backgroundColor: AppColors.sand,
                textColor: Colors.white,
                onPressed: _handleLogin,
              ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // EKSİK OLAN METOD BURADA OLMALI:
  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    IconData? icon,
    bool isOutlined = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: isOutlined ? BorderSide(color: AppColors.ink.withOpacity(0.3)) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.monoLabel.copyWith(color: textColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}