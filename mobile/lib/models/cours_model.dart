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
C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git pull
error: Pulling is not possible because you have unmerged files.
hint: Fix them up in the work tree, and then use 'git add/rm <file>'
hint: as appropriate to mark resolution and make a commit.
fatal: Exiting because of an unresolved conflict.

C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git status
On branch main
Your branch and 'origin/main' have diverged,
and have 1 and 3 different commits each, respectively.
  (use "git pull" if you want to integrate the remote branch with yours)

You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Changes to be committed:
        deleted:    mobile/.dart_tool/dartpad/web_plugin_registrant.dart
        deleted:    mobile/.dart_tool/extension_discovery/vs_code.json
        deleted:    mobile/.dart_tool/package_config.json
        deleted:    mobile/.dart_tool/package_graph.json
        deleted:    mobile/.dart_tool/version
        modified:   mobile/lib/main.dart
        modified:   mobile/lib/screens/dashboard_screen.dart
        modified:   mobile/lib/screens/historique_screen.dart
        modified:   mobile/lib/screens/login_screen.dart
        modified:   mobile/lib/screens/presence_screen.dart
        modified:   mobile/lib/services/api_service.dart
        modified:   mobile/lib/services/auth_service.dart
        modified:   mobile/lib/services/biometric_service.dart
        modified:   mobile/lib/services/location_service.dart
        modified:   mobile/lib/services/offline_service.dart
        modified:   mobile/lib/utils/helpers.dart

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   .gitignore

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
        modified:   mobile/lib/models/cours_model.dart
        modified:   mobile/lib/utils/constants.dart

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        distant
        du
        "d\303\251p\303\264t"


C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git add .

C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git commit -m "Résolution conflit + mise à jour projet"
[main d21ab41] Résolution conflit + mise à jour projet

C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git pull
Auto-merging mobile/lib/utils/constants.dart
CONFLICT (content): Merge conflict in mobile/lib/utils/constants.dart
Automatic merge failed; fix conflicts and then commit the result.

C:\Users\user\Desktop\projet _tutore\MonBadgeV2>git pull
error: Pulling is not possible because you have unmerged files.
hint: Fix them up in the work tree, and then use 'git add/rm <file>'
hint: as appropriate to mark resolution and make a commit.
fatal: Exiting because of an unresolved conflict.

C:\Users\user\Desktop\projet _tutore\MonBadgeV2>