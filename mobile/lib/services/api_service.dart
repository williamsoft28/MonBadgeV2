import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'offline_service.dart';
import '../models/presence_model.dart';

class ApiService {
  static bool offlineMode = false;
  static const String _offlineModeKey = 'offline_mode';
  static String _baseUrl = Constants.defaultBaseUrl;

  static String get baseUrl => _baseUrl;

  static Future<void> initOfflineMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Force la désactivation du mode hors ligne pour débloquer
    offlineMode = false;
    await prefs.setBool(_offlineModeKey, false);
    
    // Force l'utilisation de l'URL de constants.dart pour écraser les erreurs en cache
    _baseUrl = Constants.defaultBaseUrl;
    await prefs.setString(Constants.apiBaseUrlKey, Constants.defaultBaseUrl);
  }

  static Future<void> setBaseUrl(String url) async {
    final normalized = url.endsWith('/api')
        ? url
        : url.endsWith('/')
            ? '${url}api'
            : '$url/api';
    _baseUrl = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Constants.apiBaseUrlKey, normalized);
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

  static Future<Map<String, String>> getHeaders({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Requis pour ngrok gratuit (sinon page HTML au lieu du JSON)
      'ngrok-skip-browser-warning': 'true',
    };
    if (withAuth) {
      final token = await getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  static Map<String, dynamic> _connectionError(Object e) {
    if (e is SocketException) {
      return {
        'error':
            'Serveur injoignable. Vérifiez que le backend tourne (port 3000) et l\'URL dans constants.dart : $_baseUrl',
        '_connectionFailed': true,
      };
    }
    if (e is HandshakeException) {
      return {
        'error': 'Erreur SSL/certificat. Vérifiez l\'URL HTTPS (ngrok à jour ?).',
        '_connectionFailed': true,
      };
    }
    if (e is http.ClientException) {
      return {
        'error': 'Connexion refusée : ${e.message}',
        '_connectionFailed': true,
      };
    }
    return {
      'error': 'Erreur réseau : $e',
      '_connectionFailed': true,
    };
  }

  static dynamic _parseResponse(http.Response response) {
    final body = response.body.trim();
    if (body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true};
      }
      return {
        'error': 'Réponse vide du serveur (HTTP ${response.statusCode})',
      };
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (response.statusCode >= 400 && !decoded.containsKey('error')) {
          decoded['error'] =
              decoded['message'] ?? 'Erreur HTTP ${response.statusCode}';
        }
        return decoded;
      }
      return decoded;
    } catch (_) {
      // Souvent une page HTML ngrok expirée
      if (body.contains('<!DOCTYPE') || body.contains('<html')) {
        return {
          'error':
              'Le serveur a renvoyé du HTML (URL ngrok expirée ?). Mettez à jour Constants.defaultBaseUrl ou relancez ngrok.',
          '_connectionFailed': true,
        };
      }
      return {
        'error': 'Réponse invalide du serveur (HTTP ${response.statusCode})',
      };
    }
  }

  static Future<dynamic> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    final headers = await getHeaders(withAuth: withAuth);

    try {
      late http.Response response;
      switch (method) {
        case 'GET':
          response = await http
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 60));
          break;
        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: jsonEncode(body ?? {}))
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http
              .delete(uri, headers: headers)
              .timeout(const Duration(seconds: 30));
          break;
        default:
          return {'error': 'Méthode HTTP inconnue'};
      }
      return _parseResponse(response);
    } catch (e) {
      return _connectionError(e);
    }
  }

  static Future<dynamic> get(String endpoint) async {
    if (offlineMode) {
      return _offlineGet(endpoint);
    }
    return _request('GET', endpoint);
  }

  static Future<String?> getRaw(String endpoint) async {
    try {
      final headers = await getHeaders();
      final response = await http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    if (offlineMode) {
      return _offlinePost(endpoint, body);
    }
    return _request('POST', endpoint, body: body, withAuth: withAuth);
  }

  static Future<dynamic> delete(String endpoint) async {
    if (offlineMode) return null;
    return _request('DELETE', endpoint);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    if (offlineMode) return null;
    return _request('PUT', endpoint, body: body);
  }

  /// Test rapide de connectivité (appel GET /)
  static Future<Map<String, dynamic>> pingServer() async {
    final root = _baseUrl.replaceAll(RegExp(r'/api$'), '');
    try {
      final response = await http
          .get(
            Uri.parse(root),
            headers: {
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': 'true',
            },
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return {'ok': true, 'url': root};
      }
      return {
        'ok': false,
        'error': 'HTTP ${response.statusCode}',
        'url': root,
      };
    } catch (e) {
      return {'ok': false, 'error': e.toString(), 'url': root};
    }
  }

  static Future<dynamic> _offlineGet(String endpoint) async {
    final db = OfflineService.getDB();
    if (endpoint.contains('/cours')) {
      final cours = await db.getAllCours();
      return cours
          .map(
            (c) => {
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
            },
          )
          .toList();
    }
    if (endpoint.contains('/presences/stats')) {
      final pending = await db.getPendingPresences();
      return {
        'presences': pending.length,
        'absences': 0,
        'taux': pending.isEmpty ? '0%' : '100%',
      };
    }
    if (endpoint.contains('/presences/historique')) {
      final pending = await db.getPendingPresences();
      return pending
          .map(
            (p) => PresenceModel(
              id: p.id,
              etudiantId: p.etudiantId,
              coursId: p.coursId,
              date: p.date,
              heurePointage: p.heurePointage,
              latitude: p.latitude,
              longitude: p.longitude,
              biometrieValidee: p.biometrieValidee,
              syncServeur: false,
            ).toJson(),
          )
          .toList();
    }
    return null;
  }

  static Future<dynamic> _offlinePost(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    if (endpoint.contains('/presences')) {
      final presence = PresenceModel(
        etudiantId: body['etudiant_id'] ?? body['etudiantId'] ?? 0,
        coursId: body['cours_id'] ?? body['coursId'] ?? 0,
        date: body['date'] ?? '',
        heurePointage: body['heure_pointage'] ?? body['heurePointage'] ?? '',
        latitude: body['latitude'] != null
            ? double.parse(body['latitude'].toString())
            : null,
        longitude: body['longitude'] != null
            ? double.parse(body['longitude'].toString())
            : null,
        biometrieValidee:
            body['biometrie_validee'] == 1 || body['biometrie_validee'] == true,
        deviceToken: body['deviceToken'],
        faceImageBase64: body['faceImageBase64'],
      );
      await OfflineService.savePresence(presence);
      return {'success': true, 'offline': true};
    }
    return null;
  }
}
