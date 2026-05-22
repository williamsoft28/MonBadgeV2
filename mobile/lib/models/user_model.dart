class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String matricule;
  final String email;
  final String role;
  final bool biometrieEnregistree;
  final String? filiere;
  final String? niveau;
  final String? matiere;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.email,
    required this.role,
    required this.biometrieEnregistree,
    this.filiere,
    this.niveau,
    this.matiere,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      matricule: json['matricule'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'etudiant',
      biometrieEnregistree: json['biometrie_active'] == 1 ||
                            json['biometrie_active'] == true,
      filiere: json['filiere'],
      niveau: json['niveau'],
      matiere: json['matiere'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'matricule': matricule,
      'email': email,
      'role': role,
      'biometrie_active': biometrieEnregistree,
      'filiere': filiere,
      'niveau': niveau,
      'matiere': matiere,
    };
  }
}