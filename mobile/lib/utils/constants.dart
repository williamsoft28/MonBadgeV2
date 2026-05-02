class Constants {
  // URL de base de l'API (Assurez-vous que l'URL ngrok est à jour ou utilisez votre IP locale)
  // Pour l'émulateur Android en local : 'http://10.0.2.2:3000/api'
  static const String baseUrl = 'https://2d40-102-180-78-168.ngrok-free.app/api';

  // Clés SharedPreferences
  static const String tokenKey = 'token';
  static const String userKey = 'user';

  // Rayon géolocalisation en mètres
  static const double rayonMax = 15.0;

  // Durée token en jours
  static const int tokenDuree = 7;
}
