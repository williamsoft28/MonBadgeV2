import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';

class BiometricSetupScreen extends StatefulWidget {
  final String matricule;
  
  const BiometricSetupScreen({super.key, required this.matricule});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isAuthenticating = false;

  Future<void> _enableBiometrics() async {
    setState(() => _isAuthenticating = true);
    
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo == null) {
        setState(() => _isAuthenticating = false);
        return; // L'utilisateur a annulé
      }

      final bytes = await photo.readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Mettre à jour sur le serveur
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        final res = await ApiService.post('/auth/enable-biometrics', {
          'userId': user.id,
          'faceImageBase64': base64Image,
        });

        if (res != null && res['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Visage enregistré avec succès !')),
            );
            _goToDashboard();
          }
        } else {
          throw Exception(res?['error'] ?? 'Erreur lors de l\'enregistrement');
        }
      }
    } catch (e) {
      setState(() => _isAuthenticating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _goToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  size: 64,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Reconnaissance Faciale',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green[900],
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Prenez un selfie pour enregistrer votre visage. Cela servira à valider vos présences en classe sans utiliser l\'empreinte du téléphone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.green[800]?.withOpacity(0.6),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isAuthenticating ? null : _enableBiometrics,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    elevation: 8,
                    shadowColor: Colors.green.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isAuthenticating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Prendre mon selfie',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _goToDashboard,
                child: Text(
                  'Plus tard',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
