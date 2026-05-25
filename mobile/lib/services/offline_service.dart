import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/presence_model.dart';
import 'api_service.dart';
import '../database/database.dart';
import 'package:drift/drift.dart';

class OfflineService {
  static AppDatabase? _db;

  static AppDatabase getDB() {
    _db ??= AppDatabase();
    return _db!;
  }

  // Sauvegarder présence offline
  static Future<void> savePresence(PresenceModel presence) async {
    final db = getDB();
    await db.insertPresence(PresencesOfflineTableCompanion.insert(
      etudiantId: presence.etudiantId,
      coursId: presence.coursId,
      date: presence.date,
      heurePointage: presence.heurePointage,
      latitude: presence.latitude ?? 0.0,
      longitude: presence.longitude ?? 0.0,
      biometrieValidee: Value(presence.biometrieValidee),
      deviceToken: Value(presence.deviceToken),
      faceImageBase64: Value(presence.faceImageBase64),
    ));
  }

  // Synchroniser avec le serveur
  static Future<void> syncPresences() async {
    final db = getDB();
    final pending = await db.getPendingPresences();

    if (pending.isEmpty) return;

    List<Map<String, dynamic>> presencesToSync = pending.map((p) => {
      'etudiant_id': p.etudiantId,
      'cours_id': p.coursId,
      'date': p.date,
      'heure_pointage': p.heurePointage,
      'latitude': p.latitude,
      'longitude': p.longitude,
      'biometrie_validee': p.biometrieValidee ? 1 : 0,
      'deviceToken': p.deviceToken,
      'faceImageBase64': p.faceImageBase64,
    }).toList();

    final response = await ApiService.post('/presences/sync', {
      'presences': presencesToSync
    });

    if (response != null) {
      await db.clearPresences(); // Supprime après sync réussie
    }
  }

  // Presences non synchronisées
  static Future<int> countPendingSync() async {
    final db = getDB();
    final pending = await db.getPendingPresences();
    return pending.length;
  }

  // Synchroniser la liste des utilisateurs pour le mode hors-ligne
  static Future<void> syncOfflineUsers() async {
    final response = await ApiService.get('/auth/offline-users');
    if (response != null && response is List) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('offline_users', jsonEncode(response));
    }
  }

  // Récupérer un utilisateur depuis le cache hors-ligne via son matricule
  static Future<Map<String, dynamic>?> getOfflineUser(String matricule) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('offline_users');
    if (data != null) {
      final List<dynamic> users = jsonDecode(data);
      for (var u in users) {
        if (u['matricule'] == matricule) {
          return u as Map<String, dynamic>;
        }
      }
    }
    return null;
  }
}