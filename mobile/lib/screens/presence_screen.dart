import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cours_model.dart';
import '../models/presence_model.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

class PresenceScreen extends StatefulWidget {
  final CoursModel cours;
  const PresenceScreen({super.key, required this.cours});

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
  final ImagePicker _picker = ImagePicker();

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
        _statusMessage = "Hors délai. Présence verrouillée.";
      });
      return;
    }

    final position = await LocationService.getCurrentPosition();
    if (mounted) {
      setState(() {
        _cachedPosition = position;
        _statusMessage = 'Prêt à badger';
      });
    }
  }

  bool _isLocked() {
    // La limite de temps a été retirée à la demande de l'utilisateur.
    // L'étudiant peut désormais badger à n'importe quel moment de la journée.
    return false;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pointer() async {
    if (_isLocked()) {
      _setStatus('locked', 'Le cours est verrouillé (hors délai).');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'loading';
      _statusMessage = 'Vérification de la position...';
    });

    // Étape 1 — Géolocalisation
    Position? position = _cachedPosition;
    if (position == null) {
      position = await LocationService.getCurrentPosition();
    }
    
    if (position == null) {
      _setStatus('error', 'Impossible d\'obtenir votre position GPS');
      return;
    }

    final dansLaSalle = LocationService.estDansLaSalle(
      position.latitude, position.longitude,
      widget.cours.latitude, widget.cours.longitude,
    );

    if (!dansLaSalle) {
      _setStatus('error', 'Vous n\'êtes pas dans la salle de classe');
      return;
    }

    setState(() => _statusMessage = 'Prenez un selfie pour valider...');

    // Étape 2 — Biométrie (Reconnaissance Faciale)
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (photo == null) {
      _setStatus('error', 'Vous devez prendre une photo pour valider la présence');
      return;
    }

    final bytes = await photo.readAsBytes();
    final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

    setState(() => _statusMessage = 'Enregistrement de la présence...');

    final user = await AuthService.getCurrentUser();
    final now = DateTime.now();
    final presence = PresenceModel(
      etudiantId: user!.id,
      coursId: widget.cours.id,
      date: now.toIso8601String().split('T')[0],
      heurePointage: now.toTimeString().split(' ')[0],
      latitude: position.latitude,
      longitude: position.longitude,
      biometrieValidee: true,
      deviceToken: null, // Plus utilisé
      faceImageBase64: base64Image, // Ajouté dans le modèle si nécessaire
    );

    // Étape 3 — Réseau ou mode hors ligne
    final connectivity = await Connectivity().checkConnectivity();
    final body = {
      'etudiant_id': user!.id,
      'cours_id': widget.cours.id,
      'date': presence.date,
      'heure_pointage': presence.heurePointage,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'biometrie_validee': true,
      'faceImageBase64': base64Image,
    };

    if (connectivity == ConnectivityResult.none) {
      await OfflineService.savePresence(presence);
      _setStatus('offline', 'Présence sauvegardée hors ligne (Photo incluse)');
      return;
    }

    final response = await ApiService.post('/presences/pointer', body);
    if (response != null && (response['success'] == true || response['offline'] == true)) {
      if (response['offline'] == true) {
        _setStatus('offline', 'Présence sauvegardée hors ligne (Photo incluse)');
      } else {
        _setStatus('success', 'Présence enregistrée avec succès !');
      }
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
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'success': return Colors.green[600]!;
      case 'error': return Colors.red;
      case 'offline': return Colors.orange;
      case 'locked': return Colors.grey;
      default: return Colors.green;
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'success': return Icons.check_circle_outline;
      case 'error': return Icons.error_outline;
      case 'offline': return Icons.cloud_off_outlined;
      case 'locked': return Icons.lock_outline;
      default: return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green[900], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Prendre présence',
          style: TextStyle(color: Colors.green[900], fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Info cours
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.book_outlined,
                          color: Colors.green, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.cours.nom,
                            style: TextStyle(
                              color: Colors.green[900],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${Helpers.formatHeure(widget.cours.heureDebut)} — ${Helpers.formatHeure(widget.cours.heureFin)}',
                            style: TextStyle(
                              color: Colors.green[800]?.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.cours.salle,
                            style: TextStyle(
                              color: Colors.green[800]?.withOpacity(0.6),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Bouton principal biométrie
              ScaleTransition(
                scale: _status == 'idle' ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                child: GestureDetector(
                  onTap: (_isLoading || _status == 'locked') ? null : _pointer,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor.withOpacity(0.1),
                      border: Border.all(
                        color: _statusColor.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
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
                    ? 'Appuyez sur le bouton pour badger'
                    : '',
                style: TextStyle(
                  color: Colors.green[800]?.withOpacity(0.4),
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              // Étapes de vérification
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildStep(Icons.location_on_outlined, 'Géolocalisation GPS', 1),
                    const SizedBox(height: 12),
                    _buildStep(Icons.fingerprint, 'Authentification biométrique', 2),
                    const SizedBox(height: 12),
                    _buildStep(Icons.cloud_done_outlined, 'Enregistrement présence', 3),
                  ],
                ),
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
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.green, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: Colors.green[800]?.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

extension on DateTime {
  String toTimeString() => '$hour:$minute:$second';
}