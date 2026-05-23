import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'dashboard_screen.dart';
import 'admin_dashboard_screen.dart';
import 'enroll_face_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _matriculeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    final creds = await AuthService.getSavedCredentials();
    final savedMatricule = creds['matricule'];
    final deviceToken = creds['deviceToken'];

    if (savedMatricule != null && deviceToken != null && mounted) {
      final LocalAuthentication auth = LocalAuthentication();
      try {
        final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
        final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
        
        if (canAuthenticate) {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Connexion rapide avec la biométrie',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            setState(() => _isLoading = true);
            final result = await AuthService.loginBiometric(savedMatricule, deviceToken);
            setState(() => _isLoading = false);

            if (result['success'] && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            }
          }
        }
      } catch (e) {
        // Fallback to manual login
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _matriculeController.dispose();
    _passwordController.dispose();
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
    );

    setState(() => _isLoading = false);

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
              MaterialPageRoute(builder: (_) => EnrollFaceScreen(matricule: matricule)),
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
      backgroundColor: const Color(0xFFF8FAF9),
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
                    Colors.green.withOpacity(0.12),
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
                    Colors.lightGreen.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
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
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                                border: Border.all(color: Colors.green.withOpacity(0.08)),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  width: 50,
                                  height: 50,
                                  errorBuilder: (context, error, stackTrace) => 
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green[400]!, Colors.green[800]!],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16)
                                      ),
                                      width: 50, height: 50,
                                      child: const Icon(Icons.fingerprint, color: Colors.white, size: 30),
                                    ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'MonBadge',
                              style: GoogleFonts.outfit(
                                color: Colors.green[900],
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
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
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.06),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Connexion',
                              style: GoogleFonts.outfit(
                                color: Colors.green[900],
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entrez vos identifiants pour continuer',
                              style: TextStyle(
                                color: Colors.green[800]?.withOpacity(0.6),
                                fontSize: 14,
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
                            // Champs Administrateur (Mot de passe)
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
                                  shadowColor: Colors.transparent,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.green[400]!, Colors.green[700]!],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
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
                                        : Text(
                                            'Se connecter',
                                            style: GoogleFonts.inter(
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
                            color: Colors.green[800]?.withOpacity(0.4),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: TextStyle(color: Colors.green[900], fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.green[800]?.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: Colors.green[600], size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.green.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
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