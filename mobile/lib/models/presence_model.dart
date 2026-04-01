class PresenceModel {
  final int? id;
  final int etudiantId;
  final int coursId;
  final String date;
  final String heurePointage;
  final String statut;
  final double? latitude;
  final double? longitude;
  final bool biometrieValidee;
  final bool syncServeur;
  final String? coursNom;
  final String? salle;

  PresenceModel({
    this.id,
    required this.etudiantId,
    required this.coursId,
    required this.date,
    required this.heurePointage,
    this.statut = 'present',
    this.latitude,
    this.longitude,
    this.biometrieValidee = false,
    this.syncServeur = false,
    this.coursNom,
    this.salle,
  });

  factory PresenceModel.fromJson(Map<String, dynamic> json) {
    return PresenceModel(
      id: json['id'],
      etudiantId: json['etudiant_id'],
      coursId: json['cours_id'],
      date: json['date'],
      heurePointage: json['heure_pointage'],
      statut: json['statut'] ?? 'present',
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      biometrieValidee: json['biometrie_validee'] == 1,
      syncServeur: json['sync_serveur'] == 1,
      coursNom: json['cours_nom'],
      salle: json['salle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'etudiant_id': etudiantId,
      'cours_id': coursId,
      'date': date,
      'heure_pointage': heurePointage,
      'statut': statut,
      'latitude': latitude,
      'longitude': longitude,
      'biometrie_validee': biometrieValidee,
      'sync_serveur': syncServeur,
    };
  }
}