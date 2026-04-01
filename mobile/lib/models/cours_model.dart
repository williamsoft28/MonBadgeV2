class CoursModel {
  final int id;
  final String nom;
  final int enseignantId;
  final String salle;
  final double latitude;
  final double longitude;
  final int rayonMetres;
  final String heureDebut;
  final String heureFin;
  final String jour;
  final String enseignantNom;
  final String enseignantPrenom;

  CoursModel({
    required this.id,
    required this.nom,
    required this.enseignantId,
    required this.salle,
    required this.latitude,
    required this.longitude,
    required this.rayonMetres,
    required this.heureDebut,
    required this.heureFin,
    required this.jour,
    required this.enseignantNom,
    required this.enseignantPrenom,
  });

  factory CoursModel.fromJson(Map<String, dynamic> json) {
    return CoursModel(
      id: json['id'],
      nom: json['nom'],
      enseignantId: json['enseignant_id'],
      salle: json['salle'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      rayonMetres: json['rayon_metres'],
      heureDebut: json['heure_debut'],
      heureFin: json['heure_fin'],
      jour: json['jour'],
      enseignantNom: json['nom'] ?? '',
      enseignantPrenom: json['prenom'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'enseignant_id': enseignantId,
      'salle': salle,
      'latitude': latitude,
      'longitude': longitude,
      'rayon_metres': rayonMetres,
      'heure_debut': heureDebut,
      'heure_fin': heureFin,
      'jour': jour,
    };
  }
}