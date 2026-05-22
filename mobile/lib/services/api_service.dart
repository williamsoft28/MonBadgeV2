import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'offline_service.dart';
import '../models/presence_model.dart';

class ApiService {
  // When true, API calls will use local/offline handlers where possible.
  static bool offlineMode = false;
  static const String _offlineModeKey = 'offline_mode';

  static Future<void> initOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    offlineMode = prefs.getBool(_offlineModeKey) ?? false;
  }

  static Future<void> setOfflineMode(bool enabled) async {
    offlineMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, enabled);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Constants.tokenKey);
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET
  static Future<dynamic> get(String endpoint) async {
    try {
      if (offlineMode) {
        // Provide local fallbacks for some endpoints
        final db = OfflineService.getDB();
        if (endpoint.contains('/cours')) {
          final cours = await db.getAllCours();
          return cours.map((c) => {
                'id': c.id,
                'nom': c.nom,
                'enseignant_id': c.enseignantId,
                'salle': c.salle,
                'latitude': c.latitude,
                'longitude': c.longitude,
                'rayon_metres': c.rayonMetres,
                'heure_debut': c.heureDebut,
                'heure_fin': c.heureFin,
                'date_cours': c.dateCours,
                'est_archive': c.estArchive ? 1 : 0,
                'enseignant_nom': c.enseignantNom,
                'enseignant_prenom': c.enseignantPrenom,
                'filiere': c.filiere,
                'niveau': c.niveau,
              }).toList();
        }

        if (endpoint.contains('/presences/stats')) {
          final pending = await db.getPendingPresences();
          final presences = pending.length;
          final absences = 0;
          final taux = presences == 0 ? '0%' : '100%';
          return {'presences': presences, 'absences': absences, 'taux': taux};
        }

        if (endpoint.contains('/presences/historique')) {
          final pending = await db.getPendingPresences();
          return pending
              .map((p) => PresenceModel(
                    id: p.id,
                    etudiantId: p.etudiantId,
                    coursId: p.coursId,
                    date: p.date,
                    heurePointage: p.heurePointage,
                    latitude: p.latitude,
                    longitude: p.longitude,
                    biometrieValidee: p.biometrieValidee,
                    syncServeur: false,
                  ).toJson())
              .toList();
        }
        return null;
      }

      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // GET RAW (for text/csv)
  static Future<String?> getRaw(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // POST
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      if (offlineMode) {
        // Save presence locally when posting to presences endpoints
        if (endpoint.contains('/presences')) {
          // Expecting body containing etudiant_id, cours_id, date, heure_pointage etc.
          final presence = PresenceModel(
            etudiantId: body['etudiant_id'] ?? body['etudiantId'] ?? 0,
            coursId: body['cours_id'] ?? body['coursId'] ?? 0,
            date: body['date'] ?? '',
            heurePointage: body['heure_pointage'] ?? body['heurePointage'] ?? '',
            latitude: body['latitude'] != null ? double.parse(body['latitude'].toString()) : null,
            longitude: body['longitude'] != null ? double.parse(body['longitude'].toString()) : null,
            biometrieValidee: body['biometrie_validee'] == 1 || body['biometrie_validee'] == true,
            deviceToken: body['deviceToken'],
            faceImageBase64: body['faceImageBase64'],
          );
          await OfflineService.savePresence(presence);
          return {'success': true, 'offline': true};
        }
        return null;
      }

      final headers = await getHeaders();
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // DELETE
  static Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  // PUT
  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('${Constants.baseUrl}$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }
}