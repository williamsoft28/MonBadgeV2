import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'biometric_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _matriculeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeAdminController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureCode = true;
  bool _showAdminFields = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    
    // Écouter les changements dans le champ matricule
    _matriculeController.addListener(() {
      final text = _matriculeController.text.trim().toLowerCase();
      if (text == 'admin' && !_showAdminFields) {
        setState(() => _showAdminFields = true);
      } else if (text != 'admin' && _showAdminFields) {
        setState(() => _showAdminFields = false);
      }
    });

    _checkBiometricAutoLogin();
  }

  Future<void> _checkBiometricAutoLogin() async {
    final savedMatricule = await AuthService.getSavedCredentials();
    if (savedMatricule != null && savedMatricule.isNotEmpty) {
      final LocalAuthentication auth = LocalAuthentication();
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      if (canAuthenticateWithBiometrics || await auth.isDeviceSupported()) {
        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Authentifiez-vous pour accéder à votre espace',
            biometricOnly: true,
          );
          if (didAuthenticate) {
            setState(() {
              _matriculeController.text = savedMatricule;
            });
            await _login();
          }
        } catch (e) {
          debugPrint('Erreur biométrique: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _matriculeController.dispose();
    _passwordController.dispose();
    _codeAdminController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final matricule = _matriculeController.text.trim();
    if (matricule.isEmpty) {
      Helpers.showError(context, 'Veuillez entrer votre matricule');
      return;
    }

    final password = _showAdminFields ? _passwordController.text : matricule;

    if (_showAdminFields && password.isEmpty) {
      Helpers.showError(context, 'Veuillez entrer le mot de passe admin');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      matricule,
      password,
      codeAdmin: _showAdminFields ? _codeAdminController.text : null,
    );

    setState(() => _isLoading = false);

    // Si admin mais code non fourni
    if (result['needAdminCode'] == true) {
      Helpers.showError(context, 'Entrez votre code administrateur');
      return;
    }

    if (result['success']) {
      final user = await AuthService.getCurrentUser();
      if (mounted) {
        if (user?.role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          // Si étudiant, on vérifie la biométrie (ou on va au setup)
          if (!user!.biometrieEnregistree) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BiometricSetupScreen(matricule: matricule)),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          }
        }
      }
    } else {
      if (mounted) Helpers.showError(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Animated Background Circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.green.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.lightGreen.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Background Logo
          Center(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/logo.png',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.school,
                    size: 300,
                    color: Colors.green.withOpacity(0.5),
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(color: Colors.green.withOpacity(0.1)),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 60,
                                  height: 60,
                                  errorBuilder: (context, error, stackTrace) => 
                                    const Icon(Icons.school, color: Colors.green, size: 42),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'MonBadge',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Badgez en un geste, partout et toujours',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.08),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.green.withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connexion',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entrez vos identifiants pour continuer',
                              style: TextStyle(
                                color: Colors.green[800]?.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 28),
                            _buildLabel('Numéro matricule'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _matriculeController,
                              hint: 'ETU-2024-001',
                              icon: Icons.badge_outlined,
                            ),
                            const SizedBox(height: 20),
                            // Champs Administrateur (Mot de passe + Code Admin)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: _showAdminFields ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildLabel('Mot de passe administrateur'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _passwordController,
                                    hint: '••••••••',
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.admin_panel_settings,
                                            color: Colors.orange, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Code administrateur requis',
                                          style: TextStyle(
                                            color: Colors.orange[800],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildLabel('Code administrateur'),
                                  const SizedBox(height: 8),
                                  _buildTextField(
                                    controller: _codeAdminController,
                                    hint: '••••••••••••',
                                    icon: Icons.vpn_key_outlined,
                                    isPassword: true,
                                    isAdminCode: true,
                                  ),
                                ],
                              ) : const SizedBox.shrink(),
                            ),

                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.green.withOpacity(0.3),
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Se connecter',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Text(
                          'MonBadge v1.0 — Université',
                          style: TextStyle(
                            color: Colors.green[800]?.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.green[900],
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isAdminCode = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAdminCode
              ? Colors.orange.withOpacity(0.4)
              : Colors.green.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (isAdminCode ? _obscureCode : _obscurePassword)
            : false,
        style: TextStyle(color: Colors.green[900], fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.green[800]?.withOpacity(0.4)),
          prefixIcon: Icon(icon,
              color: isAdminCode
                  ? Colors.orange
                  : Colors.green,
              size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isAdminCode ? _obscureCode : _obscurePassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.green.withOpacity(0.5),
                    size: 20,
                  ),
                  onPressed: () => setState(() {
                    if (isAdminCode) {
                      _obscureCode = !_obscureCode;
                    } else {
                      _obscurePassword = !_obscurePassword;
                    }
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}