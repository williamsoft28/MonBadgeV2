import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/cours_model.dart';
import '../models/presence_model.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../services/auth_service.dart';
import '../services/face_recognition_service.dart';
import '../utils/helpers.dart';
import '../utils/app_theme.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class PresenceScreen extends StatefulWidget {
  final CoursModel cours;
  final bool isOfflineQR;
  
  const PresenceScreen({
    super.key, 
    required this.cours,
    this.isOfflineQR = false,
  });

  @override
  State<PresenceScreen> createState() => _PresenceScreenState();
}

class _PresenceScreenState extends State<PresenceScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  String _status = 'idle';
  String _statusMessage = 'Acquisition GPS en arrière-plan...';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  Position? _cachedPosition;
  final FaceRecognitionService _faceService = FaceRecognitionService();
  bool _cameraReady = false;
  bool _showCamera = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _prefetchLocation();
  }

  Future<void> _prefetchLocation() async {
    if (_isLocked()) {
      setState(() {
        _status = 'locked';
        _statusMessage = 'Hors délai. Présence verrouillée.';
      });
      return;
    }

    final position = await LocationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _cachedPosition = position;
        _statusMessage = widget.isOfflineQR 
            ? 'Prêt pour la reconnaissance (GPS ignoré)'
            : 'Prêt à badger';
      });
    }
  }

  bool _isLocked() => false;

  @override
  void dispose() {
    _pulseController.dispose();
    _faceService.dispose();
    super.dispose();
  }

  Future<void> _prepareCamera() async {
    try {
      await _faceService.initCamera();
      if (mounted) {
        setState(() {
          _cameraReady = true;
          _showCamera = true;
        });
      }
    } catch (e) {
      _setStatus('error', 'Impossible d\'ouvrir la caméra : $e');
    }
  }

  Future<void> _pointer() async {
    if (_isLocked()) {
      _setStatus('locked', 'Le cours est verrouillé (hors délai).');
      return;
    }

    // Étape GPS (si pas encore fait ou déjà fait)
    if (_status == 'idle') {
      if (widget.isOfflineQR) {
        _cachedPosition = Position(
          longitude: widget.cours.longitude ?? 0,
          latitude: widget.cours.latitude ?? 0,
          timestamp: DateTime.now(),
          accuracy: 10,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
        setState(() {
          _status = 'face_capture';
          _statusMessage = 'Regardez la caméra et validez votre visage';
        });
        await _prepareCamera();
        return;
      }

      Position? position = _cachedPosition;
      
      if (position == null) {
        setState(() {
          _isLoading = true;
          _status = 'loading';
          _statusMessage = 'Vérification de la position...';
        });

        position = await LocationService.getCurrentPosition();
        if (position == null) {
          _setStatus('error', 'Impossible d\'obtenir votre position GPS');
          return;
        }
        _cachedPosition = position;
      }

      final dansLaSalle = LocationService.estDansLaSalle(
        position.latitude,
        position.longitude,
        widget.cours.latitude,
        widget.cours.longitude,
      );

      if (!dansLaSalle) {
        _setStatus('error', 'Vous n\'êtes pas dans la salle de classe');
        return;
      }

      setState(() {
        _isLoading = false;
        _status = 'face_capture';
        _statusMessage = 'Regardez la caméra et validez votre visage';
      });
      await _prepareCamera();
      return;
    }

    // Étape capture + vérification faciale
    if (_status == 'face_capture') {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Analyse du visage (DeepFace)...';
      });

      final verifyResult = await _faceService.verifyFace();
      if (!verifyResult.success) {
        _setStatus(
          'error',
          verifyResult.message,
        );
        return;
      }

      setState(() => _statusMessage = 'Enregistrement de la présence...');
      await _submitPresence(verifyResult.features!);
      return;
    }
  }

  Future<void> _submitPresence(List<double> faceFeatures) async {
    final position = _cachedPosition!;
    final user = await AuthService.getCurrentUser();
    final now = DateTime.now();
    final presence = PresenceModel(
      etudiantId: user!.id,
      coursId: widget.cours.id,
      date: now.toIso8601String().split('T')[0],
      heurePointage:
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
      latitude: position.latitude,
      longitude: position.longitude,
      biometrieValidee: true,
      deviceToken: null,
      faceImageBase64: null,
    );

    final connectivity = await Connectivity().checkConnectivity();
    final body = {
      'etudiant_id': user.id,
      'cours_id': widget.cours.id,
      'date': presence.date,
      'heure_pointage': presence.heurePointage,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'biometrie_validee': true,
      'faceFeatures': faceFeatures,
    };

    if (connectivity.contains(ConnectivityResult.none)) {
      await OfflineService.savePresence(presence);
      _setStatus('offline', 'Présence sauvegardée hors ligne');
      return;
    }

    final response = await ApiService.post('/presences/pointer', body);
    if (response != null &&
        (response['message'] != null || response['success'] == true)) {
      _setStatus('success', 'Présence enregistrée avec succès !');
    } else if (response != null && response['offline'] == true) {
      _setStatus('offline', 'Présence sauvegardée hors ligne');
    } else {
      _setStatus('error', response?['error'] ?? 'Erreur inconnue');
    }
  }

  void _setStatus(String status, String message) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _status = status;
      _statusMessage = message;
      if (status != 'face_capture') {
        _showCamera = false;
      }
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'success':
        return AppTheme.accentGreen;
      case 'error':
        return Colors.redAccent;
      case 'offline':
        return Colors.orange;
      case 'locked':
        return Colors.grey;
      case 'face_capture':
        return AppTheme.accentPurple;
      default:
        return AppTheme.accentGreen;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'error':
        return Icons.error_outline;
      case 'offline':
        return Icons.cloud_off_outlined;
      case 'locked':
        return Icons.lock_outline;
      case 'face_capture':
        return Icons.face_retouching_natural;
      default:
        return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _faceService.controller;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prendre présence',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentPurple.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.book_outlined,
                        color: AppTheme.accentPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cours.nom,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Helpers.formatHeure(widget.cours.heureDebut)} — ${Helpers.formatHeure(widget.cours.heureFin)}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.cours.salle,
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: ScaleTransition(
                    scale: _status == 'idle' || _status == 'face_capture'
                        ? _pulseAnim
                        : const AlwaysStoppedAnimation(1.0),
                    child: GestureDetector(
                      onTap: (_isLoading || _status == 'locked') ? null : _pointer,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: _showCamera && _cameraReady && preview != null
                                  ? CameraPreview(preview)
                                  : Container(
                                      color: _statusColor.withOpacity(0.12),
                                      child: Center(
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                color: _statusColor,
                                                strokeWidth: 3,
                                              )
                                            : Icon(
                                                _statusIcon,
                                                color: _statusColor,
                                                size: 80,
                                              ),
                                      ),
                                    ),
                            ),
                            if (_showCamera && _cameraReady && preview != null)
                              CustomPaint(
                                painter: _FaceOvalPainter(),
                                child: const SizedBox.expand(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _status == 'idle'
                    ? 'Appuyez pour vérifier GPS puis votre visage'
                    : _status == 'face_capture'
                        ? 'Appuyez pour capturer et valider (≥ 80 %)'
                        : '',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String label, int step) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.accentGreen, size: 18),
        ),
        const SizedBox(width: 14),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
      ],
    );
  }
}

class _FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.55,
      height: size.height * 0.65,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
