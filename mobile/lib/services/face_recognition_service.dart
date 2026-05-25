import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'api_service.dart';
import 'auth_service.dart';

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

  /// Vérifie le visage au pointage (seuil 80 % côté serveur).
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

    if (response != null && response['verified'] == true) {
      return FaceRecognitionResult(
        success: true,
        message: response['message'] ?? 'Visage reconnu',
        similarityPercent: (response['similarity'] as num?)?.toDouble(),
        features: features,
      );
    }

    return FaceRecognitionResult(
      success: false,
      message: response?['error'] ??
          'Visage non reconnu ou non identique à l\'enregistrement.',
      similarityPercent: (response?['similarity'] as num?)?.toDouble(),
      features: features,
    );
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
