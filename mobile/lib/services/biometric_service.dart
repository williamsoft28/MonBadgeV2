import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Vérifier si biométrie disponible
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Authentifier
  static Future<bool> authenticate() async {
    try {
      final available = await isAvailable();
      if (!available) return false;

      return await _auth.authenticate(
        localizedReason: 'Validez votre présence avec votre biométrie',
        biometricOnly: true,
      );
    } catch (e) {
      return false;
    }
  }
}
