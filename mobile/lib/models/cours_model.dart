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

  bool get estActif {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      if (dateCours != todayStr) return false;

      final heureNow = now.hour * 60 + now.minute;
      final startParts = heureDebut.split(':');
      final endParts = heureFin.split(':');
      
      final startMin = int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return heureNow >= startMin && heureNow <= endMin;
    } catch (_) {
      return false;
    }
  }

  bool get estTermine {
    try {
      final now = DateTime.now();
      final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      if (dateCours.compareTo(todayStr) < 0) return true;
      if (dateCours.compareTo(todayStr) > 0) return false;

      final heureNow = now.hour * 60 + now.minute;
      final endParts = heureFin.split(':');
      final endMin = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

      return heureNow > endMin;
    } catch (_) {
      return false;
    }
  }
}