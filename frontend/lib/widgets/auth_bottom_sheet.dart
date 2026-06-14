import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/api_service.dart';

// Bottom sheet'in o anki modunu belirleyen enum
enum AuthMode { login, signUp }

class AuthBottomSheet extends StatefulWidget {
  const AuthBottomSheet({super.key});

  @override
  State<AuthBottomSheet> createState() => _AuthBottomSheetState();
}

class _AuthBottomSheetState extends State<AuthBottomSheet> {
  // Kontrolcüler (username kayıt modu için eklendi)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccessMessage = false;
  
  AuthMode _currentMode = AuthMode.login; // Varsayılan olarak giriş ekranı açılır
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Temizleme fonksiyonu (Modlar arası geçiş yaparken textfield'ları sıfırlar)
  void _toggleAuthMode() {
    setState(() {
      _usernameController.clear();
      _emailController.clear();
      _passwordController.clear();
      _currentMode = _currentMode == AuthMode.login ? AuthMode.signUp : AuthMode.login;
    });
  }

  // Giriş İşlemi Mantığı
  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLocalMessage('Lütfen tüm alanları doldurun');
      setState(() => _isLoading = false);
      return;
    }

    final success = await _apiService.login(email, password);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); 
      } else {
        _showLocalMessage('Hatalı e-posta veya şifre');
      }
    }
  }

  // Kayıt Olma İşlemi Mantığı (Yeni eklenen fonksiyon)
  Future<void> _handleSignUp() async {
    setState(() => _isLoading = true);

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showLocalMessage('Lütfen tüm alanları doldurun');
      setState(() => _isLoading = false);
      return;
    }

    if (password.length < 6) {
      _showLocalMessage('Şifre en az 6 karakter olmalıdır');
      setState(() => _isLoading = false);
      return;
    }

    final request = SignUpRequest(
      username: username,
      email: email,
      password: password,
    );

    final success = await _apiService.signUp(request);

    if (mounted) {
      if (success) {
        _showLocalMessage('Kayıt başarılı! Şimdi giriş yapabilirsiniz.', isSuccess: true);
        // Kayıt başarılı olunca otomatik olarak giriş moduna geçiriyoruz
        setState(() {
          _currentMode = AuthMode.login;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showLocalMessage('Kayıt başarısız. E-posta zaten kullanımda olabilir.');
      }
    }
  }

  void _showLocalMessage(String message, {bool isSuccess = false}) {
    setState(() {
      _errorMessage = message;
      _isSuccessMessage = isSuccess;
    });

    // 3 saniye sonra bildirimi otomatik olarak temizleyelim
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _currentMode == AuthMode.login;

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
      child: SingleChildScrollView( // Klavye açıldığında kaydırma güvenliği
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, 
              height: 4, 
              decoration: BoxDecoration(
                color: AppColors.sand, 
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            
            // Dinamik Başlık
            Text(
              isLogin ? "SkinLens'e Katıl" : "Hesap Oluştur", 
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 16), // Boşluğu biraz daralttık
            // --- YENİ BİLDİRİM ALANI ---
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _errorMessage != null
                  ? Container(
                      key: ValueKey<String>(_errorMessage!),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: _isSuccessMessage 
                            ? AppColors.ink.withOpacity(0.08)
                            : Colors.redAccent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isSuccessMessage ? AppColors.ink : Colors.redAccent,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: AppTextStyles.monoLabel.copyWith(
                          color: _isSuccessMessage ? AppColors.ink : Colors.redAccent,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // Eğer Kayıt modundaysak Kullanıcı Adı alanını göster
            if (!isLogin) ...[
              TextField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: "Kullanıcı Adı",
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
            ],

            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
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
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Şifre",
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 24),

            // Dinamik Yüklenme ve Aksiyon Butonu
            _isLoading 
              ? const CircularProgressIndicator(color: AppColors.sand)
              : _buildActionButton(
                  label: isLogin ? "GİRİŞ YAP" : "KAYDOL",
                  backgroundColor: AppColors.sand,
                  textColor: Colors.white,
                  onPressed: isLogin ? _handleLogin : _handleSignUp,
                ),
            const SizedBox(height: 16),

            // Alt Kısım - Mod Değiştirme Tetikleyicisi
            TextButton(
              onPressed: _toggleAuthMode,
              child: Text(
                isLogin 
                    ? "Hesabın yok mu? Kaydol" 
                    : "Zaten bir hesabın var mı? Giriş Yap",
                style: AppTextStyles.monoLabel.copyWith(
                  color: AppColors.ink.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

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