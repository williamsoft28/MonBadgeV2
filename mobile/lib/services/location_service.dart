import 'package:geolocator/geolocator.dart';
import '../utils/constants.dart';

class LocationService {
  // Demander permission et obtenir position
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }

    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // Vérifier si dans le rayon de la salle
  static bool estDansLaSalle(
    double userLat, double userLon,
    double salleLat, double salleLon,
  ) {
    final distance = Geolocator.distanceBetween(
      userLat, userLon,
      salleLat, salleLon,
    );
    return distance <= Constants.rayonMax;
  }
}