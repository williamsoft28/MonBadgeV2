import 'package:flutter/material.dart';
import '../models/cours_model.dart';
import '../models/presence_model.dart';
import '../services/biometric_service.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../services/auth_service.dart';
import '../utils/helpers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  String _statusMessage = 'Prêt à badger';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pointer() async {
    setState(() {
      _isLoading = true;
      _status = 'loading';
      _statusMessage = 'Vérification de la position...';
    });

    // Étape 1 — Géolocalisation
    final position = await LocationService.getCurrentPosition();
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

    setState(() => _statusMessage = 'Authentification biométrique...');

    // Étape 2 — Biométrie
    final bioOk = await BiometricService.authenticate();
    if (!bioOk) {
      _setStatus('error', 'Authentification biométrique échouée');
      return;
    }

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
    );

    // Étape 3 — Réseau ou offline
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      await OfflineService.savePresence(presence);
      _setStatus('offline', 'Présence sauvegardée hors ligne');
    } else {
      final response = await ApiService.post('/presences/pointer', {
        'cours_id': widget.cours.id,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'biometrie_validee': true,
      });

      if (response != null && response['message'] != null) {
        _setStatus('success', 'Présence enregistrée avec succès !');
      } else {
        _setStatus('error', response?['error'] ?? 'Erreur inconnue');
      }
    }
  }

  void _setStatus(String status, String message) {
    setState(() {
      _isLoading = false;
      _status = status;
      _statusMessage = message;
    });
  }

  Color get _statusColor {
    switch (_status) {
      case 'success': return const Color(0xFF00D4AA);
      case 'error': return const Color(0xFFE53935);
      case 'offline': return const Color(0xFFFF9800);
      default: return const Color(0xFF6C63FF);
    }
  }

  IconData get _statusIcon {
    switch (_status) {
      case 'success': return Icons.check_circle_outline;
      case 'error': return Icons.error_outline;
      case 'offline': return Icons.cloud_off_outlined;
      default: return Icons.fingerprint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Prendre présence',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
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
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.book_outlined,
                          color: Colors.white, size: 24),
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
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            widget.cours.salle,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
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
                  onTap: _isLoading ? null : _pointer,
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
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              // Étapes de vérification
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
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
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
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