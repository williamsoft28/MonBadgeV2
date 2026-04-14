import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/presence_model.dart';
import 'api_service.dart';

class OfflineService {
  static Database? _db;

  static Future<Database> getDB() async {
    if (_db != null) return _db!;
    _db = await openDatabase(
      join(await getDatabasesPath(), 'monbadge.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE presences_offline (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            etudiant_id INTEGER,
            cours_id INTEGER,
            date TEXT,
            heure_pointage TEXT,
            latitude REAL,
            longitude REAL,
            biometrie_validee INTEGER,
            sync_serveur INTEGER DEFAULT 0
          )
        ''');
      },
      version: 1,
    );
    return _db!;
  }

  // Sauvegarder présence offline
  static Future<void> savePresence(PresenceModel presence) async {
    final db = await getDB();
    await db.insert('presences_offline', {
      'etudiant_id': presence.etudiantId,
      'cours_id': presence.coursId,
      'date': presence.date,
      'heure_pointage': presence.heurePointage,
      'latitude': presence.latitude,
      'longitude': presence.longitude,
      'biometrie_validee': presence.biometrieValidee ? 1 : 0,
      'sync_serveur': 0,
    });
  }

  // Synchroniser avec le serveur
  static Future<void> syncPresences() async {
    final db = await getDB();
    final List<Map<String, dynamic>> presences = await db.query(
      'presences_offline',
      where: 'sync_serveur = 0',
    );

    for (final p in presences) {
      final response = await ApiService.post('/presences/sync', {
        'presences': [p]
      });

      if (response != null) {
        await db.update(
          'presences_offline',
          {'sync_serveur': 1},
          where: 'id = ?',
          whereArgs: [p['id']],
        );
      }
    }
  }

  // Presences non synchronisées
  static Future<int> countPendingSync() async {
    final db = await getDB();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM presences_offline WHERE sync_serveur = 0'
    );
    return result.first['count'] as int;
  }
}