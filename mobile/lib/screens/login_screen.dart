import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'dashboard_screen.dart';

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
  bool _showCodeAdmin = false;
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
    if (_matriculeController.text.isEmpty || _passwordController.text.isEmpty) {
      Helpers.showError(context, 'Veuillez remplir tous les champs');
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.login(
      _matriculeController.text.trim(),
      _passwordController.text,
      codeAdmin: _showCodeAdmin ? _codeAdminController.text : null,
    );

    setState(() => _isLoading = false);

    // Si admin mais code non fourni
    if (result['needAdminCode'] == true) {
      setState(() => _showCodeAdmin = true);
      Helpers.showError(context, 'Entrez votre code administrateur');
      return;
    }

    if (result['success']) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } else {
      if (mounted) Helpers.showError(context, result['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
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
                    const Color(0xFF6C63FF).withOpacity(0.3),
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
                    const Color(0xFF00D4AA).withOpacity(0.2),
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
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6C63FF),
                                    Color(0xFF00D4AA),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'MonBadge',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Badgez en un geste, partout et toujours',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A2E),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Connexion',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entrez vos identifiants pour continuer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
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
                            _buildLabel('Mot de passe'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _passwordController,
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            // Champ code admin (visible seulement si admin)
                            if (_showCodeAdmin) ...[
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.admin_panel_settings,
                                        color: Color(0xFF6C63FF), size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Code administrateur requis',
                                      style: TextStyle(
                                        color: const Color(0xFF6C63FF).withOpacity(0.8),
                                        fontSize: 12,
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

                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.zero,
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF00D4AA),
                                      ],
                                    ),
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
                                              fontWeight: FontWeight.w600,
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
                            color: Colors.white.withOpacity(0.2),
                            fontSize: 12,
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
        color: Colors.white.withOpacity(0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
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
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAdminCode
              ? const Color(0xFF6C63FF).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword
            ? (isAdminCode ? _obscureCode : _obscurePassword)
            : false,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
          prefixIcon: Icon(icon,
              color: isAdminCode
                  ? const Color(0xFF6C63FF).withOpacity(0.6)
                  : Colors.white.withOpacity(0.3),
              size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (isAdminCode ? _obscureCode : _obscurePassword)
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white.withOpacity(0.3),
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