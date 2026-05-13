// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CoursTableTable extends CoursTable
    with TableInfo<$CoursTableTable, CoursEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nomMeta = const VerificationMeta('nom');
  @override
  late final GeneratedColumn<String> nom = GeneratedColumn<String>(
    'nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enseignantIdMeta = const VerificationMeta(
    'enseignantId',
  );
  @override
  late final GeneratedColumn<int> enseignantId = GeneratedColumn<int>(
    'enseignant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salleMeta = const VerificationMeta('salle');
  @override
  late final GeneratedColumn<String> salle = GeneratedColumn<String>(
    'salle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rayonMetresMeta = const VerificationMeta(
    'rayonMetres',
  );
  @override
  late final GeneratedColumn<int> rayonMetres = GeneratedColumn<int>(
    'rayon_metres',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heureDebutMeta = const VerificationMeta(
    'heureDebut',
  );
  @override
  late final GeneratedColumn<String> heureDebut = GeneratedColumn<String>(
    'heure_debut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heureFinMeta = const VerificationMeta(
    'heureFin',
  );
  @override
  late final GeneratedColumn<String> heureFin = GeneratedColumn<String>(
    'heure_fin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateCoursMeta = const VerificationMeta(
    'dateCours',
  );
  @override
  late final GeneratedColumn<String> dateCours = GeneratedColumn<String>(
    'date_cours',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estArchiveMeta = const VerificationMeta(
    'estArchive',
  );
  @override
  late final GeneratedColumn<bool> estArchive = GeneratedColumn<bool>(
    'est_archive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("est_archive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _enseignantNomMeta = const VerificationMeta(
    'enseignantNom',
  );
  @override
  late final GeneratedColumn<String> enseignantNom = GeneratedColumn<String>(
    'enseignant_nom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enseignantPrenomMeta = const VerificationMeta(
    'enseignantPrenom',
  );
  @override
  late final GeneratedColumn<String> enseignantPrenom = GeneratedColumn<String>(
    'enseignant_prenom',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filiereMeta = const VerificationMeta(
    'filiere',
  );
  @override
  late final GeneratedColumn<String> filiere = GeneratedColumn<String>(
    'filiere',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _niveauMeta = const VerificationMeta('niveau');
  @override
  late final GeneratedColumn<String> niveau = GeneratedColumn<String>(
    'niveau',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nom,
    enseignantId,
    salle,
    latitude,
    longitude,
    rayonMetres,
    heureDebut,
    heureFin,
    dateCours,
    estArchive,
    enseignantNom,
    enseignantPrenom,
    filiere,
    niveau,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cours_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoursEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nom')) {
      context.handle(
        _nomMeta,
        nom.isAcceptableOrUnknown(data['nom']!, _nomMeta),
      );
    } else if (isInserting) {
      context.missing(_nomMeta);
    }
    if (data.containsKey('enseignant_id')) {
      context.handle(
        _enseignantIdMeta,
        enseignantId.isAcceptableOrUnknown(
          data['enseignant_id']!,
          _enseignantIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enseignantIdMeta);
    }
    if (data.containsKey('salle')) {
      context.handle(
        _salleMeta,
        salle.isAcceptableOrUnknown(data['salle']!, _salleMeta),
      );
    } else if (isInserting) {
      context.missing(_salleMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('rayon_metres')) {
      context.handle(
        _rayonMetresMeta,
        rayonMetres.isAcceptableOrUnknown(
          data['rayon_metres']!,
          _rayonMetresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rayonMetresMeta);
    }
    if (data.containsKey('heure_debut')) {
      context.handle(
        _heureDebutMeta,
        heureDebut.isAcceptableOrUnknown(data['heure_debut']!, _heureDebutMeta),
      );
    } else if (isInserting) {
      context.missing(_heureDebutMeta);
    }
    if (data.containsKey('heure_fin')) {
      context.handle(
        _heureFinMeta,
        heureFin.isAcceptableOrUnknown(data['heure_fin']!, _heureFinMeta),
      );
    } else if (isInserting) {
      context.missing(_heureFinMeta);
    }
    if (data.containsKey('date_cours')) {
      context.handle(
        _dateCoursMeta,
        dateCours.isAcceptableOrUnknown(data['date_cours']!, _dateCoursMeta),
      );
    } else if (isInserting) {
      context.missing(_dateCoursMeta);
    }
    if (data.containsKey('est_archive')) {
      context.handle(
        _estArchiveMeta,
        estArchive.isAcceptableOrUnknown(data['est_archive']!, _estArchiveMeta),
      );
    }
    if (data.containsKey('enseignant_nom')) {
      context.handle(
        _enseignantNomMeta,
        enseignantNom.isAcceptableOrUnknown(
          data['enseignant_nom']!,
          _enseignantNomMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enseignantNomMeta);
    }
    if (data.containsKey('enseignant_prenom')) {
      context.handle(
        _enseignantPrenomMeta,
        enseignantPrenom.isAcceptableOrUnknown(
          data['enseignant_prenom']!,
          _enseignantPrenomMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enseignantPrenomMeta);
    }
    if (data.containsKey('filiere')) {
      context.handle(
        _filiereMeta,
        filiere.isAcceptableOrUnknown(data['filiere']!, _filiereMeta),
      );
    }
    if (data.containsKey('niveau')) {
      context.handle(
        _niveauMeta,
        niveau.isAcceptableOrUnknown(data['niveau']!, _niveauMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CoursEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoursEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nom'],
      )!,
      enseignantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}enseignant_id'],
      )!,
      salle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}salle'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      rayonMetres: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rayon_metres'],
      )!,
      heureDebut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heure_debut'],
      )!,
      heureFin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heure_fin'],
      )!,
      dateCours: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_cours'],
      )!,
      estArchive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}est_archive'],
      )!,
      enseignantNom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enseignant_nom'],
      )!,
      enseignantPrenom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enseignant_prenom'],
      )!,
      filiere: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filiere'],
      ),
      niveau: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}niveau'],
      ),
    );
  }

  @override
  $CoursTableTable createAlias(String alias) {
    return $CoursTableTable(attachedDatabase, alias);
  }
}

class CoursEntity extends DataClass implements Insertable<CoursEntity> {
  final int id;
  final String nom;
  final int enseignantId;
  final String salle;
  final double latitude;
  final double longitude;
  final int rayonMetres;
  final String heureDebut;
  final String heureFin;
  final String dateCours;
  final bool estArchive;
  final String enseignantNom;
  final String enseignantPrenom;
  final String? filiere;
  final String? niveau;
  const CoursEntity({
    required this.id,
    required this.nom,
    required this.enseignantId,
    required this.salle,
    required this.latitude,
    required this.longitude,
    required this.rayonMetres,
    required this.heureDebut,
    required this.heureFin,
    required this.dateCours,
    required this.estArchive,
    required this.enseignantNom,
    required this.enseignantPrenom,
    this.filiere,
    this.niveau,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nom'] = Variable<String>(nom);
    map['enseignant_id'] = Variable<int>(enseignantId);
    map['salle'] = Variable<String>(salle);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['rayon_metres'] = Variable<int>(rayonMetres);
    map['heure_debut'] = Variable<String>(heureDebut);
    map['heure_fin'] = Variable<String>(heureFin);
    map['date_cours'] = Variable<String>(dateCours);
    map['est_archive'] = Variable<bool>(estArchive);
    map['enseignant_nom'] = Variable<String>(enseignantNom);
    map['enseignant_prenom'] = Variable<String>(enseignantPrenom);
    if (!nullToAbsent || filiere != null) {
      map['filiere'] = Variable<String>(filiere);
    }
    if (!nullToAbsent || niveau != null) {
      map['niveau'] = Variable<String>(niveau);
    }
    return map;
  }

  CoursTableCompanion toCompanion(bool nullToAbsent) {
    return CoursTableCompanion(
      id: Value(id),
      nom: Value(nom),
      enseignantId: Value(enseignantId),
      salle: Value(salle),
      latitude: Value(latitude),
      longitude: Value(longitude),
      rayonMetres: Value(rayonMetres),
      heureDebut: Value(heureDebut),
      heureFin: Value(heureFin),
      dateCours: Value(dateCours),
      estArchive: Value(estArchive),
      enseignantNom: Value(enseignantNom),
      enseignantPrenom: Value(enseignantPrenom),
      filiere: filiere == null && nullToAbsent
          ? const Value.absent()
          : Value(filiere),
      niveau: niveau == null && nullToAbsent
          ? const Value.absent()
          : Value(niveau),
    );
  }

  factory CoursEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoursEntity(
      id: serializer.fromJson<int>(json['id']),
      nom: serializer.fromJson<String>(json['nom']),
      enseignantId: serializer.fromJson<int>(json['enseignantId']),
      salle: serializer.fromJson<String>(json['salle']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      rayonMetres: serializer.fromJson<int>(json['rayonMetres']),
      heureDebut: serializer.fromJson<String>(json['heureDebut']),
      heureFin: serializer.fromJson<String>(json['heureFin']),
      dateCours: serializer.fromJson<String>(json['dateCours']),
      estArchive: serializer.fromJson<bool>(json['estArchive']),
      enseignantNom: serializer.fromJson<String>(json['enseignantNom']),
      enseignantPrenom: serializer.fromJson<String>(json['enseignantPrenom']),
      filiere: serializer.fromJson<String?>(json['filiere']),
      niveau: serializer.fromJson<String?>(json['niveau']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nom': serializer.toJson<String>(nom),
      'enseignantId': serializer.toJson<int>(enseignantId),
      'salle': serializer.toJson<String>(salle),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'rayonMetres': serializer.toJson<int>(rayonMetres),
      'heureDebut': serializer.toJson<String>(heureDebut),
      'heureFin': serializer.toJson<String>(heureFin),
      'dateCours': serializer.toJson<String>(dateCours),
      'estArchive': serializer.toJson<bool>(estArchive),
      'enseignantNom': serializer.toJson<String>(enseignantNom),
      'enseignantPrenom': serializer.toJson<String>(enseignantPrenom),
      'filiere': serializer.toJson<String?>(filiere),
      'niveau': serializer.toJson<String?>(niveau),
    };
  }

  CoursEntity copyWith({
    int? id,
    String? nom,
    int? enseignantId,
    String? salle,
    double? latitude,
    double? longitude,
    int? rayonMetres,
    String? heureDebut,
    String? heureFin,
    String? dateCours,
    bool? estArchive,
    String? enseignantNom,
    String? enseignantPrenom,
    Value<String?> filiere = const Value.absent(),
    Value<String?> niveau = const Value.absent(),
  }) => CoursEntity(
    id: id ?? this.id,
    nom: nom ?? this.nom,
    enseignantId: enseignantId ?? this.enseignantId,
    salle: salle ?? this.salle,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    rayonMetres: rayonMetres ?? this.rayonMetres,
    heureDebut: heureDebut ?? this.heureDebut,
    heureFin: heureFin ?? this.heureFin,
    dateCours: dateCours ?? this.dateCours,
    estArchive: estArchive ?? this.estArchive,
    enseignantNom: enseignantNom ?? this.enseignantNom,
    enseignantPrenom: enseignantPrenom ?? this.enseignantPrenom,
    filiere: filiere.present ? filiere.value : this.filiere,
    niveau: niveau.present ? niveau.value : this.niveau,
  );
  CoursEntity copyWithCompanion(CoursTableCompanion data) {
    return CoursEntity(
      id: data.id.present ? data.id.value : this.id,
      nom: data.nom.present ? data.nom.value : this.nom,
      enseignantId: data.enseignantId.present
          ? data.enseignantId.value
          : this.enseignantId,
      salle: data.salle.present ? data.salle.value : this.salle,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      rayonMetres: data.rayonMetres.present
          ? data.rayonMetres.value
          : this.rayonMetres,
      heureDebut: data.heureDebut.present
          ? data.heureDebut.value
          : this.heureDebut,
      heureFin: data.heureFin.present ? data.heureFin.value : this.heureFin,
      dateCours: data.dateCours.present ? data.dateCours.value : this.dateCours,
      estArchive: data.estArchive.present
          ? data.estArchive.value
          : this.estArchive,
      enseignantNom: data.enseignantNom.present
          ? data.enseignantNom.value
          : this.enseignantNom,
      enseignantPrenom: data.enseignantPrenom.present
          ? data.enseignantPrenom.value
          : this.enseignantPrenom,
      filiere: data.filiere.present ? data.filiere.value : this.filiere,
      niveau: data.niveau.present ? data.niveau.value : this.niveau,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoursEntity(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('enseignantId: $enseignantId, ')
          ..write('salle: $salle, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rayonMetres: $rayonMetres, ')
          ..write('heureDebut: $heureDebut, ')
          ..write('heureFin: $heureFin, ')
          ..write('dateCours: $dateCours, ')
          ..write('estArchive: $estArchive, ')
          ..write('enseignantNom: $enseignantNom, ')
          ..write('enseignantPrenom: $enseignantPrenom, ')
          ..write('filiere: $filiere, ')
          ..write('niveau: $niveau')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nom,
    enseignantId,
    salle,
    latitude,
    longitude,
    rayonMetres,
    heureDebut,
    heureFin,
    dateCours,
    estArchive,
    enseignantNom,
    enseignantPrenom,
    filiere,
    niveau,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoursEntity &&
          other.id == this.id &&
          other.nom == this.nom &&
          other.enseignantId == this.enseignantId &&
          other.salle == this.salle &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.rayonMetres == this.rayonMetres &&
          other.heureDebut == this.heureDebut &&
          other.heureFin == this.heureFin &&
          other.dateCours == this.dateCours &&
          other.estArchive == this.estArchive &&
          other.enseignantNom == this.enseignantNom &&
          other.enseignantPrenom == this.enseignantPrenom &&
          other.filiere == this.filiere &&
          other.niveau == this.niveau);
}

class CoursTableCompanion extends UpdateCompanion<CoursEntity> {
  final Value<int> id;
  final Value<String> nom;
  final Value<int> enseignantId;
  final Value<String> salle;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int> rayonMetres;
  final Value<String> heureDebut;
  final Value<String> heureFin;
  final Value<String> dateCours;
  final Value<bool> estArchive;
  final Value<String> enseignantNom;
  final Value<String> enseignantPrenom;
  final Value<String?> filiere;
  final Value<String?> niveau;
  const CoursTableCompanion({
    this.id = const Value.absent(),
    this.nom = const Value.absent(),
    this.enseignantId = const Value.absent(),
    this.salle = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.rayonMetres = const Value.absent(),
    this.heureDebut = const Value.absent(),
    this.heureFin = const Value.absent(),
    this.dateCours = const Value.absent(),
    this.estArchive = const Value.absent(),
    this.enseignantNom = const Value.absent(),
    this.enseignantPrenom = const Value.absent(),
    this.filiere = const Value.absent(),
    this.niveau = const Value.absent(),
  });
  CoursTableCompanion.insert({
    this.id = const Value.absent(),
    required String nom,
    required int enseignantId,
    required String salle,
    required double latitude,
    required double longitude,
    required int rayonMetres,
    required String heureDebut,
    required String heureFin,
    required String dateCours,
    this.estArchive = const Value.absent(),
    required String enseignantNom,
    required String enseignantPrenom,
    this.filiere = const Value.absent(),
    this.niveau = const Value.absent(),
  }) : nom = Value(nom),
       enseignantId = Value(enseignantId),
       salle = Value(salle),
       latitude = Value(latitude),
       longitude = Value(longitude),
       rayonMetres = Value(rayonMetres),
       heureDebut = Value(heureDebut),
       heureFin = Value(heureFin),
       dateCours = Value(dateCours),
       enseignantNom = Value(enseignantNom),
       enseignantPrenom = Value(enseignantPrenom);
  static Insertable<CoursEntity> custom({
    Expression<int>? id,
    Expression<String>? nom,
    Expression<int>? enseignantId,
    Expression<String>? salle,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? rayonMetres,
    Expression<String>? heureDebut,
    Expression<String>? heureFin,
    Expression<String>? dateCours,
    Expression<bool>? estArchive,
    Expression<String>? enseignantNom,
    Expression<String>? enseignantPrenom,
    Expression<String>? filiere,
    Expression<String>? niveau,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nom != null) 'nom': nom,
      if (enseignantId != null) 'enseignant_id': enseignantId,
      if (salle != null) 'salle': salle,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (rayonMetres != null) 'rayon_metres': rayonMetres,
      if (heureDebut != null) 'heure_debut': heureDebut,
      if (heureFin != null) 'heure_fin': heureFin,
      if (dateCours != null) 'date_cours': dateCours,
      if (estArchive != null) 'est_archive': estArchive,
      if (enseignantNom != null) 'enseignant_nom': enseignantNom,
      if (enseignantPrenom != null) 'enseignant_prenom': enseignantPrenom,
      if (filiere != null) 'filiere': filiere,
      if (niveau != null) 'niveau': niveau,
    });
  }

  CoursTableCompanion copyWith({
    Value<int>? id,
    Value<String>? nom,
    Value<int>? enseignantId,
    Value<String>? salle,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int>? rayonMetres,
    Value<String>? heureDebut,
    Value<String>? heureFin,
    Value<String>? dateCours,
    Value<bool>? estArchive,
    Value<String>? enseignantNom,
    Value<String>? enseignantPrenom,
    Value<String?>? filiere,
    Value<String?>? niveau,
  }) {
    return CoursTableCompanion(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      enseignantId: enseignantId ?? this.enseignantId,
      salle: salle ?? this.salle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rayonMetres: rayonMetres ?? this.rayonMetres,
      heureDebut: heureDebut ?? this.heureDebut,
      heureFin: heureFin ?? this.heureFin,
      dateCours: dateCours ?? this.dateCours,
      estArchive: estArchive ?? this.estArchive,
      enseignantNom: enseignantNom ?? this.enseignantNom,
      enseignantPrenom: enseignantPrenom ?? this.enseignantPrenom,
      filiere: filiere ?? this.filiere,
      niveau: niveau ?? this.niveau,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nom.present) {
      map['nom'] = Variable<String>(nom.value);
    }
    if (enseignantId.present) {
      map['enseignant_id'] = Variable<int>(enseignantId.value);
    }
    if (salle.present) {
      map['salle'] = Variable<String>(salle.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (rayonMetres.present) {
      map['rayon_metres'] = Variable<int>(rayonMetres.value);
    }
    if (heureDebut.present) {
      map['heure_debut'] = Variable<String>(heureDebut.value);
    }
    if (heureFin.present) {
      map['heure_fin'] = Variable<String>(heureFin.value);
    }
    if (dateCours.present) {
      map['date_cours'] = Variable<String>(dateCours.value);
    }
    if (estArchive.present) {
      map['est_archive'] = Variable<bool>(estArchive.value);
    }
    if (enseignantNom.present) {
      map['enseignant_nom'] = Variable<String>(enseignantNom.value);
    }
    if (enseignantPrenom.present) {
      map['enseignant_prenom'] = Variable<String>(enseignantPrenom.value);
    }
    if (filiere.present) {
      map['filiere'] = Variable<String>(filiere.value);
    }
    if (niveau.present) {
      map['niveau'] = Variable<String>(niveau.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursTableCompanion(')
          ..write('id: $id, ')
          ..write('nom: $nom, ')
          ..write('enseignantId: $enseignantId, ')
          ..write('salle: $salle, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('rayonMetres: $rayonMetres, ')
          ..write('heureDebut: $heureDebut, ')
          ..write('heureFin: $heureFin, ')
          ..write('dateCours: $dateCours, ')
          ..write('estArchive: $estArchive, ')
          ..write('enseignantNom: $enseignantNom, ')
          ..write('enseignantPrenom: $enseignantPrenom, ')
          ..write('filiere: $filiere, ')
          ..write('niveau: $niveau')
          ..write(')'))
        .toString();
  }
}

class $PresencesOfflineTableTable extends PresencesOfflineTable
    with TableInfo<$PresencesOfflineTableTable, PresenceOfflineEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PresencesOfflineTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _etudiantIdMeta = const VerificationMeta(
    'etudiantId',
  );
  @override
  late final GeneratedColumn<int> etudiantId = GeneratedColumn<int>(
    'etudiant_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coursIdMeta = const VerificationMeta(
    'coursId',
  );
  @override
  late final GeneratedColumn<int> coursId = GeneratedColumn<int>(
    'cours_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heurePointageMeta = const VerificationMeta(
    'heurePointage',
  );
  @override
  late final GeneratedColumn<String> heurePointage = GeneratedColumn<String>(
    'heure_pointage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _biometrieValideeMeta = const VerificationMeta(
    'biometrieValidee',
  );
  @override
  late final GeneratedColumn<bool> biometrieValidee = GeneratedColumn<bool>(
    'biometrie_validee',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("biometrie_validee" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deviceTokenMeta = const VerificationMeta(
    'deviceToken',
  );
  @override
  late final GeneratedColumn<String> deviceToken = GeneratedColumn<String>(
    'device_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _faceImageBase64Meta = const VerificationMeta(
    'faceImageBase64',
  );
  @override
  late final GeneratedColumn<String> faceImageBase64 = GeneratedColumn<String>(
    'face_image_base64',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    etudiantId,
    coursId,
    date,
    heurePointage,
    latitude,
    longitude,
    biometrieValidee,
    deviceToken,
    faceImageBase64,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'presences_offline_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PresenceOfflineEntity> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('etudiant_id')) {
      context.handle(
        _etudiantIdMeta,
        etudiantId.isAcceptableOrUnknown(data['etudiant_id']!, _etudiantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_etudiantIdMeta);
    }
    if (data.containsKey('cours_id')) {
      context.handle(
        _coursIdMeta,
        coursId.isAcceptableOrUnknown(data['cours_id']!, _coursIdMeta),
      );
    } else if (isInserting) {
      context.missing(_coursIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('heure_pointage')) {
      context.handle(
        _heurePointageMeta,
        heurePointage.isAcceptableOrUnknown(
          data['heure_pointage']!,
          _heurePointageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heurePointageMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('biometrie_validee')) {
      context.handle(
        _biometrieValideeMeta,
        biometrieValidee.isAcceptableOrUnknown(
          data['biometrie_validee']!,
          _biometrieValideeMeta,
        ),
      );
    }
    if (data.containsKey('device_token')) {
      context.handle(
        _deviceTokenMeta,
        deviceToken.isAcceptableOrUnknown(
          data['device_token']!,
          _deviceTokenMeta,
        ),
      );
    }
    if (data.containsKey('face_image_base64')) {
      context.handle(
        _faceImageBase64Meta,
        faceImageBase64.isAcceptableOrUnknown(
          data['face_image_base64']!,
          _faceImageBase64Meta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PresenceOfflineEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PresenceOfflineEntity(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      etudiantId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}etudiant_id'],
      )!,
      coursId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cours_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      heurePointage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}heure_pointage'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      biometrieValidee: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}biometrie_validee'],
      )!,
      deviceToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_token'],
      ),
      faceImageBase64: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}face_image_base64'],
      ),
    );
  }

  @override
  $PresencesOfflineTableTable createAlias(String alias) {
    return $PresencesOfflineTableTable(attachedDatabase, alias);
  }
}

class PresenceOfflineEntity extends DataClass
    implements Insertable<PresenceOfflineEntity> {
  final int id;
  final int etudiantId;
  final int coursId;
  final String date;
  final String heurePointage;
  final double latitude;
  final double longitude;
  final bool biometrieValidee;
  final String? deviceToken;
  final String? faceImageBase64;
  const PresenceOfflineEntity({
    required this.id,
    required this.etudiantId,
    required this.coursId,
    required this.date,
    required this.heurePointage,
    required this.latitude,
    required this.longitude,
    required this.biometrieValidee,
    this.deviceToken,
    this.faceImageBase64,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['etudiant_id'] = Variable<int>(etudiantId);
    map['cours_id'] = Variable<int>(coursId);
    map['date'] = Variable<String>(date);
    map['heure_pointage'] = Variable<String>(heurePointage);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['biometrie_validee'] = Variable<bool>(biometrieValidee);
    if (!nullToAbsent || deviceToken != null) {
      map['device_token'] = Variable<String>(deviceToken);
    }
    if (!nullToAbsent || faceImageBase64 != null) {
      map['face_image_base64'] = Variable<String>(faceImageBase64);
    }
    return map;
  }

  PresencesOfflineTableCompanion toCompanion(bool nullToAbsent) {
    return PresencesOfflineTableCompanion(
      id: Value(id),
      etudiantId: Value(etudiantId),
      coursId: Value(coursId),
      date: Value(date),
      heurePointage: Value(heurePointage),
      latitude: Value(latitude),
      longitude: Value(longitude),
      biometrieValidee: Value(biometrieValidee),
      deviceToken: deviceToken == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceToken),
      faceImageBase64: faceImageBase64 == null && nullToAbsent
          ? const Value.absent()
          : Value(faceImageBase64),
    );
  }

  factory PresenceOfflineEntity.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PresenceOfflineEntity(
      id: serializer.fromJson<int>(json['id']),
      etudiantId: serializer.fromJson<int>(json['etudiantId']),
      coursId: serializer.fromJson<int>(json['coursId']),
      date: serializer.fromJson<String>(json['date']),
      heurePointage: serializer.fromJson<String>(json['heurePointage']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      biometrieValidee: serializer.fromJson<bool>(json['biometrieValidee']),
      deviceToken: serializer.fromJson<String?>(json['deviceToken']),
      faceImageBase64: serializer.fromJson<String?>(json['faceImageBase64']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'etudiantId': serializer.toJson<int>(etudiantId),
      'coursId': serializer.toJson<int>(coursId),
      'date': serializer.toJson<String>(date),
      'heurePointage': serializer.toJson<String>(heurePointage),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'biometrieValidee': serializer.toJson<bool>(biometrieValidee),
      'deviceToken': serializer.toJson<String?>(deviceToken),
      'faceImageBase64': serializer.toJson<String?>(faceImageBase64),
    };
  }

  PresenceOfflineEntity copyWith({
    int? id,
    int? etudiantId,
    int? coursId,
    String? date,
    String? heurePointage,
    double? latitude,
    double? longitude,
    bool? biometrieValidee,
    Value<String?> deviceToken = const Value.absent(),
    Value<String?> faceImageBase64 = const Value.absent(),
  }) => PresenceOfflineEntity(
    id: id ?? this.id,
    etudiantId: etudiantId ?? this.etudiantId,
    coursId: coursId ?? this.coursId,
    date: date ?? this.date,
    heurePointage: heurePointage ?? this.heurePointage,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    biometrieValidee: biometrieValidee ?? this.biometrieValidee,
    deviceToken: deviceToken.present ? deviceToken.value : this.deviceToken,
    faceImageBase64: faceImageBase64.present
        ? faceImageBase64.value
        : this.faceImageBase64,
  );
  PresenceOfflineEntity copyWithCompanion(PresencesOfflineTableCompanion data) {
    return PresenceOfflineEntity(
      id: data.id.present ? data.id.value : this.id,
      etudiantId: data.etudiantId.present
          ? data.etudiantId.value
          : this.etudiantId,
      coursId: data.coursId.present ? data.coursId.value : this.coursId,
      date: data.date.present ? data.date.value : this.date,
      heurePointage: data.heurePointage.present
          ? data.heurePointage.value
          : this.heurePointage,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      biometrieValidee: data.biometrieValidee.present
          ? data.biometrieValidee.value
          : this.biometrieValidee,
      deviceToken: data.deviceToken.present
          ? data.deviceToken.value
          : this.deviceToken,
      faceImageBase64: data.faceImageBase64.present
          ? data.faceImageBase64.value
          : this.faceImageBase64,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PresenceOfflineEntity(')
          ..write('id: $id, ')
          ..write('etudiantId: $etudiantId, ')
          ..write('coursId: $coursId, ')
          ..write('date: $date, ')
          ..write('heurePointage: $heurePointage, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('biometrieValidee: $biometrieValidee, ')
          ..write('deviceToken: $deviceToken, ')
          ..write('faceImageBase64: $faceImageBase64')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    etudiantId,
    coursId,
    date,
    heurePointage,
    latitude,
    longitude,
    biometrieValidee,
    deviceToken,
    faceImageBase64,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PresenceOfflineEntity &&
          other.id == this.id &&
          other.etudiantId == this.etudiantId &&
          other.coursId == this.coursId &&
          other.date == this.date &&
          other.heurePointage == this.heurePointage &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.biometrieValidee == this.biometrieValidee &&
          other.deviceToken == this.deviceToken &&
          other.faceImageBase64 == this.faceImageBase64);
}

class PresencesOfflineTableCompanion
    extends UpdateCompanion<PresenceOfflineEntity> {
  final Value<int> id;
  final Value<int> etudiantId;
  final Value<int> coursId;
  final Value<String> date;
  final Value<String> heurePointage;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<bool> biometrieValidee;
  final Value<String?> deviceToken;
  final Value<String?> faceImageBase64;
  const PresencesOfflineTableCompanion({
    this.id = const Value.absent(),
    this.etudiantId = const Value.absent(),
    this.coursId = const Value.absent(),
    this.date = const Value.absent(),
    this.heurePointage = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.biometrieValidee = const Value.absent(),
    this.deviceToken = const Value.absent(),
    this.faceImageBase64 = const Value.absent(),
  });
  PresencesOfflineTableCompanion.insert({
    this.id = const Value.absent(),
    required int etudiantId,
    required int coursId,
    required String date,
    required String heurePointage,
    required double latitude,
    required double longitude,
    this.biometrieValidee = const Value.absent(),
    this.deviceToken = const Value.absent(),
    this.faceImageBase64 = const Value.absent(),
  }) : etudiantId = Value(etudiantId),
       coursId = Value(coursId),
       date = Value(date),
       heurePointage = Value(heurePointage),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<PresenceOfflineEntity> custom({
    Expression<int>? id,
    Expression<int>? etudiantId,
    Expression<int>? coursId,
    Expression<String>? date,
    Expression<String>? heurePointage,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<bool>? biometrieValidee,
    Expression<String>? deviceToken,
    Expression<String>? faceImageBase64,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (etudiantId != null) 'etudiant_id': etudiantId,
      if (coursId != null) 'cours_id': coursId,
      if (date != null) 'date': date,
      if (heurePointage != null) 'heure_pointage': heurePointage,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (biometrieValidee != null) 'biometrie_validee': biometrieValidee,
      if (deviceToken != null) 'device_token': deviceToken,
      if (faceImageBase64 != null) 'face_image_base64': faceImageBase64,
    });
  }

  PresencesOfflineTableCompanion copyWith({
    Value<int>? id,
    Value<int>? etudiantId,
    Value<int>? coursId,
    Value<String>? date,
    Value<String>? heurePointage,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<bool>? biometrieValidee,
    Value<String?>? deviceToken,
    Value<String?>? faceImageBase64,
  }) {
    return PresencesOfflineTableCompanion(
      id: id ?? this.id,
      etudiantId: etudiantId ?? this.etudiantId,
      coursId: coursId ?? this.coursId,
      date: date ?? this.date,
      heurePointage: heurePointage ?? this.heurePointage,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      biometrieValidee: biometrieValidee ?? this.biometrieValidee,
      deviceToken: deviceToken ?? this.deviceToken,
      faceImageBase64: faceImageBase64 ?? this.faceImageBase64,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (etudiantId.present) {
      map['etudiant_id'] = Variable<int>(etudiantId.value);
    }
    if (coursId.present) {
      map['cours_id'] = Variable<int>(coursId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (heurePointage.present) {
      map['heure_pointage'] = Variable<String>(heurePointage.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (biometrieValidee.present) {
      map['biometrie_validee'] = Variable<bool>(biometrieValidee.value);
    }
    if (deviceToken.present) {
      map['device_token'] = Variable<String>(deviceToken.value);
    }
    if (faceImageBase64.present) {
      map['face_image_base64'] = Variable<String>(faceImageBase64.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PresencesOfflineTableCompanion(')
          ..write('id: $id, ')
          ..write('etudiantId: $etudiantId, ')
          ..write('coursId: $coursId, ')
          ..write('date: $date, ')
          ..write('heurePointage: $heurePointage, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('biometrieValidee: $biometrieValidee, ')
          ..write('deviceToken: $deviceToken, ')
          ..write('faceImageBase64: $faceImageBase64')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursTableTable coursTable = $CoursTableTable(this);
  late final $PresencesOfflineTableTable presencesOfflineTable =
      $PresencesOfflineTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    coursTable,
    presencesOfflineTable,
  ];
}

typedef $$CoursTableTableCreateCompanionBuilder =
    CoursTableCompanion Function({
      Value<int> id,
      required String nom,
      required int enseignantId,
      required String salle,
      required double latitude,
      required double longitude,
      required int rayonMetres,
      required String heureDebut,
      required String heureFin,
      required String dateCours,
      Value<bool> estArchive,
      required String enseignantNom,
      required String enseignantPrenom,
      Value<String?> filiere,
      Value<String?> niveau,
    });
typedef $$CoursTableTableUpdateCompanionBuilder =
    CoursTableCompanion Function({
      Value<int> id,
      Value<String> nom,
      Value<int> enseignantId,
      Value<String> salle,
      Value<double> latitude,
      Value<double> longitude,
      Value<int> rayonMetres,
      Value<String> heureDebut,
      Value<String> heureFin,
      Value<String> dateCours,
      Value<bool> estArchive,
      Value<String> enseignantNom,
      Value<String> enseignantPrenom,
      Value<String?> filiere,
      Value<String?> niveau,
    });

class $$CoursTableTableFilterComposer
    extends Composer<_$AppDatabase, $CoursTableTable> {
  $$CoursTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enseignantId => $composableBuilder(
    column: $table.enseignantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salle => $composableBuilder(
    column: $table.salle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rayonMetres => $composableBuilder(
    column: $table.rayonMetres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heureDebut => $composableBuilder(
    column: $table.heureDebut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heureFin => $composableBuilder(
    column: $table.heureFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateCours => $composableBuilder(
    column: $table.dateCours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get estArchive => $composableBuilder(
    column: $table.estArchive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enseignantNom => $composableBuilder(
    column: $table.enseignantNom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enseignantPrenom => $composableBuilder(
    column: $table.enseignantPrenom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filiere => $composableBuilder(
    column: $table.filiere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CoursTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CoursTableTable> {
  $$CoursTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nom => $composableBuilder(
    column: $table.nom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enseignantId => $composableBuilder(
    column: $table.enseignantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salle => $composableBuilder(
    column: $table.salle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rayonMetres => $composableBuilder(
    column: $table.rayonMetres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heureDebut => $composableBuilder(
    column: $table.heureDebut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heureFin => $composableBuilder(
    column: $table.heureFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateCours => $composableBuilder(
    column: $table.dateCours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get estArchive => $composableBuilder(
    column: $table.estArchive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enseignantNom => $composableBuilder(
    column: $table.enseignantNom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enseignantPrenom => $composableBuilder(
    column: $table.enseignantPrenom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filiere => $composableBuilder(
    column: $table.filiere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get niveau => $composableBuilder(
    column: $table.niveau,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CoursTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoursTableTable> {
  $$CoursTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nom =>
      $composableBuilder(column: $table.nom, builder: (column) => column);

  GeneratedColumn<int> get enseignantId => $composableBuilder(
    column: $table.enseignantId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salle =>
      $composableBuilder(column: $table.salle, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get rayonMetres => $composableBuilder(
    column: $table.rayonMetres,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heureDebut => $composableBuilder(
    column: $table.heureDebut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get heureFin =>
      $composableBuilder(column: $table.heureFin, builder: (column) => column);

  GeneratedColumn<String> get dateCours =>
      $composableBuilder(column: $table.dateCours, builder: (column) => column);

  GeneratedColumn<bool> get estArchive => $composableBuilder(
    column: $table.estArchive,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enseignantNom => $composableBuilder(
    column: $table.enseignantNom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get enseignantPrenom => $composableBuilder(
    column: $table.enseignantPrenom,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filiere =>
      $composableBuilder(column: $table.filiere, builder: (column) => column);

  GeneratedColumn<String> get niveau =>
      $composableBuilder(column: $table.niveau, builder: (column) => column);
}

class $$CoursTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoursTableTable,
          CoursEntity,
          $$CoursTableTableFilterComposer,
          $$CoursTableTableOrderingComposer,
          $$CoursTableTableAnnotationComposer,
          $$CoursTableTableCreateCompanionBuilder,
          $$CoursTableTableUpdateCompanionBuilder,
          (
            CoursEntity,
            BaseReferences<_$AppDatabase, $CoursTableTable, CoursEntity>,
          ),
          CoursEntity,
          PrefetchHooks Function()
        > {
  $$CoursTableTableTableManager(_$AppDatabase db, $CoursTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoursTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoursTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoursTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nom = const Value.absent(),
                Value<int> enseignantId = const Value.absent(),
                Value<String> salle = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int> rayonMetres = const Value.absent(),
                Value<String> heureDebut = const Value.absent(),
                Value<String> heureFin = const Value.absent(),
                Value<String> dateCours = const Value.absent(),
                Value<bool> estArchive = const Value.absent(),
                Value<String> enseignantNom = const Value.absent(),
                Value<String> enseignantPrenom = const Value.absent(),
                Value<String?> filiere = const Value.absent(),
                Value<String?> niveau = const Value.absent(),
              }) => CoursTableCompanion(
                id: id,
                nom: nom,
                enseignantId: enseignantId,
                salle: salle,
                latitude: latitude,
                longitude: longitude,
                rayonMetres: rayonMetres,
                heureDebut: heureDebut,
                heureFin: heureFin,
                dateCours: dateCours,
                estArchive: estArchive,
                enseignantNom: enseignantNom,
                enseignantPrenom: enseignantPrenom,
                filiere: filiere,
                niveau: niveau,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nom,
                required int enseignantId,
                required String salle,
                required double latitude,
                required double longitude,
                required int rayonMetres,
                required String heureDebut,
                required String heureFin,
                required String dateCours,
                Value<bool> estArchive = const Value.absent(),
                required String enseignantNom,
                required String enseignantPrenom,
                Value<String?> filiere = const Value.absent(),
                Value<String?> niveau = const Value.absent(),
              }) => CoursTableCompanion.insert(
                id: id,
                nom: nom,
                enseignantId: enseignantId,
                salle: salle,
                latitude: latitude,
                longitude: longitude,
                rayonMetres: rayonMetres,
                heureDebut: heureDebut,
                heureFin: heureFin,
                dateCours: dateCours,
                estArchive: estArchive,
                enseignantNom: enseignantNom,
                enseignantPrenom: enseignantPrenom,
                filiere: filiere,
                niveau: niveau,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CoursTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoursTableTable,
      CoursEntity,
      $$CoursTableTableFilterComposer,
      $$CoursTableTableOrderingComposer,
      $$CoursTableTableAnnotationComposer,
      $$CoursTableTableCreateCompanionBuilder,
      $$CoursTableTableUpdateCompanionBuilder,
      (
        CoursEntity,
        BaseReferences<_$AppDatabase, $CoursTableTable, CoursEntity>,
      ),
      CoursEntity,
      PrefetchHooks Function()
    >;
typedef $$PresencesOfflineTableTableCreateCompanionBuilder =
    PresencesOfflineTableCompanion Function({
      Value<int> id,
      required int etudiantId,
      required int coursId,
      required String date,
      required String heurePointage,
      required double latitude,
      required double longitude,
      Value<bool> biometrieValidee,
      Value<String?> deviceToken,
      Value<String?> faceImageBase64,
    });
typedef $$PresencesOfflineTableTableUpdateCompanionBuilder =
    PresencesOfflineTableCompanion Function({
      Value<int> id,
      Value<int> etudiantId,
      Value<int> coursId,
      Value<String> date,
      Value<String> heurePointage,
      Value<double> latitude,
      Value<double> longitude,
      Value<bool> biometrieValidee,
      Value<String?> deviceToken,
      Value<String?> faceImageBase64,
    });

class $$PresencesOfflineTableTableFilterComposer
    extends Composer<_$AppDatabase, $PresencesOfflineTableTable> {
  $$PresencesOfflineTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get etudiantId => $composableBuilder(
    column: $table.etudiantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coursId => $composableBuilder(
    column: $table.coursId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heurePointage => $composableBuilder(
    column: $table.heurePointage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get biometrieValidee => $composableBuilder(
    column: $table.biometrieValidee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceToken => $composableBuilder(
    column: $table.deviceToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faceImageBase64 => $composableBuilder(
    column: $table.faceImageBase64,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PresencesOfflineTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PresencesOfflineTableTable> {
  $$PresencesOfflineTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get etudiantId => $composableBuilder(
    column: $table.etudiantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coursId => $composableBuilder(
    column: $table.coursId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heurePointage => $composableBuilder(
    column: $table.heurePointage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get biometrieValidee => $composableBuilder(
    column: $table.biometrieValidee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceToken => $composableBuilder(
    column: $table.deviceToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faceImageBase64 => $composableBuilder(
    column: $table.faceImageBase64,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PresencesOfflineTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PresencesOfflineTableTable> {
  $$PresencesOfflineTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get etudiantId => $composableBuilder(
    column: $table.etudiantId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coursId =>
      $composableBuilder(column: $table.coursId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get heurePointage => $composableBuilder(
    column: $table.heurePointage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<bool> get biometrieValidee => $composableBuilder(
    column: $table.biometrieValidee,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceToken => $composableBuilder(
    column: $table.deviceToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get faceImageBase64 => $composableBuilder(
    column: $table.faceImageBase64,
    builder: (column) => column,
  );
}

class $$PresencesOfflineTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PresencesOfflineTableTable,
          PresenceOfflineEntity,
          $$PresencesOfflineTableTableFilterComposer,
          $$PresencesOfflineTableTableOrderingComposer,
          $$PresencesOfflineTableTableAnnotationComposer,
          $$PresencesOfflineTableTableCreateCompanionBuilder,
          $$PresencesOfflineTableTableUpdateCompanionBuilder,
          (
            PresenceOfflineEntity,
            BaseReferences<
              _$AppDatabase,
              $PresencesOfflineTableTable,
              PresenceOfflineEntity
            >,
          ),
          PresenceOfflineEntity,
          PrefetchHooks Function()
        > {
  $$PresencesOfflineTableTableTableManager(
    _$AppDatabase db,
    $PresencesOfflineTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PresencesOfflineTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PresencesOfflineTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PresencesOfflineTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> etudiantId = const Value.absent(),
                Value<int> coursId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> heurePointage = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<bool> biometrieValidee = const Value.absent(),
                Value<String?> deviceToken = const Value.absent(),
                Value<String?> faceImageBase64 = const Value.absent(),
              }) => PresencesOfflineTableCompanion(
                id: id,
                etudiantId: etudiantId,
                coursId: coursId,
                date: date,
                heurePointage: heurePointage,
                latitude: latitude,
                longitude: longitude,
                biometrieValidee: biometrieValidee,
                deviceToken: deviceToken,
                faceImageBase64: faceImageBase64,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int etudiantId,
                required int coursId,
                required String date,
                required String heurePointage,
                required double latitude,
                required double longitude,
                Value<bool> biometrieValidee = const Value.absent(),
                Value<String?> deviceToken = const Value.absent(),
                Value<String?> faceImageBase64 = const Value.absent(),
              }) => PresencesOfflineTableCompanion.insert(
                id: id,
                etudiantId: etudiantId,
                coursId: coursId,
                date: date,
                heurePointage: heurePointage,
                latitude: latitude,
                longitude: longitude,
                biometrieValidee: biometrieValidee,
                deviceToken: deviceToken,
                faceImageBase64: faceImageBase64,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PresencesOfflineTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PresencesOfflineTableTable,
      PresenceOfflineEntity,
      $$PresencesOfflineTableTableFilterComposer,
      $$PresencesOfflineTableTableOrderingComposer,
      $$PresencesOfflineTableTableAnnotationComposer,
      $$PresencesOfflineTableTableCreateCompanionBuilder,
      $$PresencesOfflineTableTableUpdateCompanionBuilder,
      (
        PresenceOfflineEntity,
        BaseReferences<
          _$AppDatabase,
          $PresencesOfflineTableTable,
          PresenceOfflineEntity
        >,
      ),
      PresenceOfflineEntity,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursTableTableTableManager get coursTable =>
      $$CoursTableTableTableManager(_db, _db.coursTable);
  $$PresencesOfflineTableTableTableManager get presencesOfflineTable =>
      $$PresencesOfflineTableTableTableManager(_db, _db.presencesOfflineTable);
}
