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
  final String dateCours;
  final bool estArchive;
  final String enseignantNom;
  final String enseignantPrenom;
  final String? filiere;
  final String? niveau;

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
    required this.dateCours,
    this.estArchive = false,
    required this.enseignantNom,
    required this.enseignantPrenom,
    this.filiere,
    this.niveau,
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
      dateCours: json['date_cours'].toString().split('T')[0], // format YYYY-MM-DD
      estArchive: json['est_archive'] == 1 || json['est_archive'] == true,
      enseignantNom: json['enseignant_nom'] ?? '',
      enseignantPrenom: json['enseignant_prenom'] ?? '',
      filiere: json['filiere'],
      niveau: json['niveau'],
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
      'date_cours': dateCours,
      'est_archive': estArchive ? 1 : 0,
      'filiere': filiere,
      'niveau': niveau,
    };
  }
}