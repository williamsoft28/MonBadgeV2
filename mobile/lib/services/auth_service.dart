import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Connexion
  static Future<Map<String, dynamic>> login(
    String matricule,
    String motDePasse,
  ) async {
    final body = {'matricule': matricule, 'mot_de_passe': motDePasse};

    final response = await ApiService.post(
      '/auth/login',
      body,
      withAuth: false,
    );

    if (response == null) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }

    if (response['_connectionFailed'] == true) {
      return {
        'success': false,
        'message': response['error'] ?? 'Erreur de connexion au serveur',
      };
    }

    if (response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, response['token']);
      await prefs.setString(Constants.userKey, jsonEncode(response['user']));
      return {'success': true, 'user': response['user']};
    }

    return {
      'success': false,
      'message': response['error'] ?? 'Erreur connexion',
    };
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
    await prefs.remove('saved_matricule');
    await prefs.remove('device_token');
  }

  // Récupérer utilisateur connecté
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(Constants.userKey);
    if (userStr == null) return null;
    return UserModel.fromJson(jsonDecode(userStr));
  }

  // Vérifier si connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey) != null;
  }

  /// Met à jour le flag biométrie en local après enregistrement du visage.
  static Future<void> updateBiometrieStatus(bool enrolled) async {
    final user = await getCurrentUser();
    if (user == null) return;
    final prefs = await SharedPreferences.getInstance();
    final updated = user.toJson();
    updated['biometrie_active'] = enrolled;
    await prefs.setString(Constants.userKey, jsonEncode(updated));
  }

  // --- Fonctions pour la biométrie ---
  static Future<void> saveCredentials(
    String matricule,
    String deviceToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_matricule', matricule);
    await prefs.setString('device_token', deviceToken);
  }

  static Future<Map<String, String?>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'matricule': prefs.getString('saved_matricule'),
      'deviceToken': prefs.getString('device_token'),
    };
  }

  static Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_matricule');
    await prefs.remove('device_token');
  }

  // Connexion Biométrique
  static Future<Map<String, dynamic>> loginBiometric(
    String matricule,
    String deviceToken,
  ) async {
    final body = {'matricule': matricule, 'deviceToken': deviceToken};

    final response = await ApiService.post(
      '/auth/login-biometric',
      body,
      withAuth: false,
    );

    if (response == null) {
      return {'success': false, 'message': 'Erreur de connexion au serveur'};
    }

    if (response['_connectionFailed'] == true) {
      return {
        'success': false,
        'message': response['error'] ?? 'Erreur de connexion au serveur',
      };
    }

    if (response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, response['token']);
      await prefs.setString(Constants.userKey, jsonEncode(response['user']));
      return {'success': true, 'user': response['user']};
    }

    return {
      'success': false,
      'message': response['error'] ?? 'Erreur connexion',
    };
  }
}
