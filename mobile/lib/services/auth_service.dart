import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Connexion
  static Future<Map<String, dynamic>> login(
      String matricule, String motDePasse) async {
    final response = await ApiService.post('/auth/login', {
      'matricule': matricule,
      'mot_de_passe': motDePasse,
    });

    if (response != null && response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(Constants.tokenKey, response['token']);
      await prefs.setString(
          Constants.userKey, jsonEncode(response['user']));
      return {'success': true, 'user': response['user']};
    }

    return {'success': false, 'message': response?['error'] ?? 'Erreur connexion'};
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(Constants.tokenKey);
    await prefs.remove(Constants.userKey);
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
}