class Constants {
  /// URL de l'API — à adapter selon votre environnement :
  ///
  /// | Contexte              | URL exemple                          |
  /// |-----------------------|--------------------------------------|
  /// | Émulateur Android     | http://10.0.2.2:3000/api             |
  /// | Téléphone (même WiFi) | http://192.168.1.XX:3000/api         |
  /// | Ngrok (téléphone 4G)  | https://XXXX.ngrok-free.app/api      |
  ///
  /// Ngrok : relancer `ngrok http 3000` et coller la nouvelle URL ici.
  /// Le backend doit tourner : `cd backend && npm start`
  static const String defaultBaseUrl = 'https://de3f-102-180-78-168.ngrok-free.app/api';

  /// Clé SharedPreferences pour surcharger l'URL sans recompiler.
  static const String apiBaseUrlKey = 'api_base_url';

  // Clés SharedPreferences
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Rayon géolocalisation en mètres
  static const double rayonMax = 50.0;

  // Durée token en jours
  static const int tokenDuree = 7;
}
