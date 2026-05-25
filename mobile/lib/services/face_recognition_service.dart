import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'offline_service.dart';

class FaceRecognitionResult {
  final bool success;
  final String message;
  final double? similarityPercent;
  final List<double>? features;

  const FaceRecognitionResult({
    required this.success,
    required this.message,
    this.similarityPercent,
    this.features,
  });
}

/// Détection ML Kit offline + envoi des features au serveur pour comparaison.
class FaceRecognitionService {
  static final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: false,
      enableClassification: true,
      performanceMode: FaceDetectorMode.accurate,
      minFaceSize: 0.15,
    ),
  );

  CameraController? _controller;
  List<CameraDescription>? _cameras;

  CameraController? get controller => _controller;

  Future<void> initCamera() async {
    _cameras ??= await availableCameras();
    final front = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );

    if (_controller != null) {
      await _controller!.dispose();
    }

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
  }

  /// Extrait un vecteur de features normalisées depuis un visage ML Kit.
  static List<double> extractFeatures(Face face) {
    final box = face.boundingBox;
    final centerX = box.left + box.width / 2;
    final centerY = box.top + box.height / 2;
    final w = box.width > 0 ? box.width : 1.0;
    final h = box.height > 0 ? box.height : 1.0;

    final features = <double>[
      w / h,
      (face.headEulerAngleX ?? 0) / 90.0,
      (face.headEulerAngleY ?? 0) / 90.0,
      (face.headEulerAngleZ ?? 0) / 90.0,
      if (face.leftEyeOpenProbability != null) face.leftEyeOpenProbability!,
      if (face.rightEyeOpenProbability != null) face.rightEyeOpenProbability!,
      if (face.smilingProbability != null) face.smilingProbability!,
    ];

    final landmarkOrder = [
      FaceLandmarkType.leftEye,
      FaceLandmarkType.rightEye,
      FaceLandmarkType.noseBase,
      FaceLandmarkType.leftMouth,
      FaceLandmarkType.rightMouth,
      FaceLandmarkType.bottomMouth,
      FaceLandmarkType.leftCheek,
      FaceLandmarkType.rightCheek,
    ];

    for (final type in landmarkOrder) {
      final landmark = face.landmarks[type];
      if (landmark != null) {
        features.add((landmark.position.x - centerX) / w);
        features.add((landmark.position.y - centerY) / h);
      } else {
        features.add(0);
        features.add(0);
      }
    }

    return features;
  }

  /// Capture une photo et retourne les features et l'image base64.
  Future<Map<String, dynamic>?> captureAndExtractFeatures() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      await initCamera();
    }

    final file = await _controller!.takePicture();
    final inputImage = InputImage.fromFilePath(file.path);
    final faces = await _detector.processImage(inputImage);

    if (faces.isEmpty) {
      try {
        await File(file.path).delete();
      } catch (_) {}
      return null;
    }

    // Prendre le plus grand visage (le plus proche de la caméra)
    faces.sort(
      (a, b) => (b.boundingBox.width * b.boundingBox.height)
          .compareTo(a.boundingBox.width * a.boundingBox.height),
    );
    
    final features = extractFeatures(faces.first);
    final bytes = await File(file.path).readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    try {
      await File(file.path).delete();
    } catch (_) {}

    return {
      'features': features,
      'base64Image': base64Image,
    };
  }

  /// Enregistre le visage à la première connexion.
  Future<FaceRecognitionResult> enrollFace() async {
    final result = await captureAndExtractFeatures();
    if (result == null || (result['features'] as List).length < 10) {
      return const FaceRecognitionResult(
        success: false,
        message: 'Aucun visage détecté. Centrez votre visage dans le cadre.',
      );
    }

    final features = result['features'] as List<double>;
    final base64Image = result['base64Image'] as String;

    final response = await ApiService.post('/auth/enroll-face', {
      'faceFeatures': features,
      'faceImageBase64': base64Image,
    });

    if (response != null && response['success'] == true) {
      await _updateLocalBiometrie(true);
      return FaceRecognitionResult(
        success: true,
        message: response['message'] ?? 'Visage enregistré avec succès',
        features: features,
      );
    }

    return FaceRecognitionResult(
      success: false,
      message: response?['error'] ?? 'Erreur lors de l\'enregistrement du visage',
      features: features,
    );
  }

  /// Vérifie le visage au pointage (seuil 80 % côté serveur ou local).
  Future<FaceRecognitionResult> verifyFace() async {
    final result = await captureAndExtractFeatures();
    if (result == null || (result['features'] as List).length < 10) {
      return const FaceRecognitionResult(
        success: false,
        message: 'Aucun visage détecté. Réessayez en regardant la caméra.',
      );
    }

    final features = result['features'] as List<double>;
    final base64Image = result['base64Image'] as String;

    final response = await ApiService.post('/auth/verify-face', {
      'faceFeatures': features,
      'faceImageBase64': base64Image,
    });

    if (response == null || response['_connectionFailed'] == true) {
      // Offline fallback: verification locale
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser != null) {
        final offlineUser = await OfflineService.getOfflineUser(currentUser.matricule);
        if (offlineUser != null && offlineUser['face_features'] != null) {
          try {
            final String featuresStr = offlineUser['face_features'];
            final List<dynamic> parsed = jsonDecode(featuresStr);
            final List<double> savedFeatures = parsed.map((e) => (e as num).toDouble()).toList();
            
            final similarity = _compareFeaturesLocal(savedFeatures, features);
            final similarityPercent = (similarity * 100).roundToDouble();

            if (similarity >= 0.85) {
              return FaceRecognitionResult(
                success: true,
                message: 'Validation locale ($similarityPercent%)',
                similarityPercent: similarityPercent,
                features: features,
              );
            } else {
              return FaceRecognitionResult(
                success: false,
                message: 'Visage non reconnu (Local: $similarityPercent% - min 85%)',
                similarityPercent: similarityPercent,
                features: features,
              );
            }
          } catch (e) {
            return FaceRecognitionResult(
              success: false,
              message: 'Erreur lors de la lecture du visage sauvegardé localement.',
              features: features,
            );
          }
        }
      }

      // Si aucune donnée locale n'est disponible, on accepte temporairement pour que le serveur vérifie plus tard
      // comme demandé pour l'offline "aveugle"
      return FaceRecognitionResult(
        success: true,
        message: 'Présence capturée. Vérification en attente de connexion.',
        features: features,
      );
    }

    if (response['verified'] == true) {
      return FaceRecognitionResult(
        success: true,
        message: response['message'] ?? 'Visage reconnu',
        similarityPercent: (response['similarity'] as num?)?.toDouble(),
        features: features,
      );
    }

    return FaceRecognitionResult(
      success: false,
      message: response['error'] ??
          'Visage non reconnu ou non identique à l\'enregistrement.',
      similarityPercent: (response['similarity'] as num?)?.toDouble(),
      features: features,
    );
  }

  /// Comparaison locale des traits du visage (similaire au faceFeatureService.js du serveur)
  double _compareFeaturesLocal(List<double> savedFeatures, List<double> currentFeatures) {
    if (savedFeatures.isEmpty || savedFeatures.length != currentFeatures.length) {
      return 0.0;
    }

    double dot = 0.0;
    double normA = 0.0;
    double normB = 0.0;
    double sumSq = 0.0;

    for (int i = 0; i < savedFeatures.length; i++) {
      final a = savedFeatures[i];
      final b = currentFeatures[i];
      if (a.isNaN || b.isNaN) continue;
      
      dot += a * b;
      normA += a * a;
      normB += b * b;
      final d = a - b;
      sumSq += d * d;
    }

    final cosine = (normA > 0 && normB > 0) ? dot / (sqrt(normA) * sqrt(normB)) : 0.0;
    final distance = sqrt(sumSq);
    final euclideanSim = max(0.0, 1.0 - distance / 1.5);

    final similarity = max(0.0, min(1.0, cosine * 0.4 + euclideanSim * 0.6));
    return similarity;
  }

  Future<void> _updateLocalBiometrie(bool value) async {
    await AuthService.updateBiometrieStatus(value);
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  static Future<void> disposeDetector() async {
    await _detector.close();
  }
}
