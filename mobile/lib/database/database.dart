import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DataClassName('CoursEntity')
class CoursTable extends Table {
  IntColumn get id => integer()();
  TextColumn get nom => text()();
  IntColumn get enseignantId => integer()();
  TextColumn get salle => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  IntColumn get rayonMetres => integer()();
  TextColumn get heureDebut => text()();
  TextColumn get heureFin => text()();
  TextColumn get dateCours => text()();
  BoolColumn get estArchive => boolean().withDefault(const Constant(false))();
  TextColumn get enseignantNom => text()();
  TextColumn get enseignantPrenom => text()();
  TextColumn get filiere => text().nullable()();
  TextColumn get niveau => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PresenceOfflineEntity')
class PresencesOfflineTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get etudiantId => integer()();
  IntColumn get coursId => integer()();
  TextColumn get date => text()();
  TextColumn get heurePointage => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  BoolColumn get biometrieValidee => boolean().withDefault(const Constant(false))();
  TextColumn get deviceToken => text().nullable()();
  TextColumn get faceImageBase64 => text().nullable()();
}

@DriftDatabase(tables: [CoursTable, PresencesOfflineTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.deleteTable(coursTable.actualTableName);
          await m.createTable(coursTable);
        }
      },
    );
  }

  // Cours Operations
  Future<List<CoursEntity>> getAllCours() => select(coursTable).get();
  Future<void> insertCours(List<CoursEntity> cours) async {
    await batch((batch) {
      batch.insertAll(coursTable, cours, mode: InsertMode.replace);
    });
  }
  Future<void> clearCours() => delete(coursTable).go();

  // Presences Offline Operations
  Future<List<PresenceOfflineEntity>> getPendingPresences() => select(presencesOfflineTable).get();
  Future<int> insertPresence(PresencesOfflineTableCompanion presence) => into(presencesOfflineTable).insert(presence);
  Future<void> clearPresences() => delete(presencesOfflineTable).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
