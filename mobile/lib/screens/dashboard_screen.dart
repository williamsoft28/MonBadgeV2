import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_model.dart';
import '../models/cours_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../database/database.dart';
import '../utils/helpers.dart';
import 'login_screen.dart';
import 'presence_screen.dart';
import 'historique_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  UserModel? _user;
  List<CoursModel> _cours = [];
  bool _isLoading = true;
  int _pendingSync = 0;
  int _presencesStats = 0;
  int _absencesStats = 0;
  String _tauxStats = '0%';
  bool _offlineEnabled = ApiService.offlineMode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _user = await AuthService.getCurrentUser();
    _offlineEnabled = ApiService.offlineMode;
    await _loadCours();
    await _loadStats();
    _pendingSync = await OfflineService.countPendingSync();
    setState(() => _isLoading = false);
  }

  Future<void> _toggleOfflineMode(bool enabled) async {
    await ApiService.setOfflineMode(enabled);
    if (mounted) {
      setState(() => _offlineEnabled = enabled);
      Helpers.showSuccess(context, enabled ? 'Mode hors-ligne activé' : 'Mode en ligne activé');
    }
  }

  Future<void> _loadStats() async {
    final response = await ApiService.get('/presences/stats');
    if (response != null && response['presences'] != null) {
      setState(() {
        _presencesStats = response['presences'];
        _absencesStats = response['absences'];
        _tauxStats = response['taux'].toString();
      });
    }
  }

  Future<void> _loadCours() async {
    try {
      final response = await ApiService.get('/cours/jour');
      if (response != null && response is List) {
        final List<CoursModel> fetchedCours = response.map((c) => CoursModel.fromJson(c)).toList();
        setState(() {
          _cours = fetchedCours;
        });
        
        // Save to Drift for offline use
        final db = OfflineService.getDB();
        await db.clearCours();
        final entities = fetchedCours.map((c) => CoursEntity(
          id: c.id,
          nom: c.nom,
          enseignantId: c.enseignantId,
          salle: c.salle,
          latitude: c.latitude,
          longitude: c.longitude,
          rayonMetres: c.rayonMetres,
          heureDebut: c.heureDebut,
          heureFin: c.heureFin,
          dateCours: c.dateCours,
          estArchive: c.estArchive,
          enseignantNom: c.enseignantNom,
          enseignantPrenom: c.enseignantPrenom,
          filiere: c.filiere,
          niveau: c.niveau,
        )).toList();
        await db.insertCours(entities);
      } else {
        await _loadCoursOffline();
      }
    } catch (e) {
      await _loadCoursOffline();
    }
  }

  Future<void> _loadCoursOffline() async {
    final db = OfflineService.getDB();
    final entities = await db.getAllCours();
    setState(() {
      _cours = entities.map((e) => CoursModel(
        id: e.id,
        nom: e.nom,
        enseignantId: e.enseignantId,
        salle: e.salle,
        latitude: e.latitude,
        longitude: e.longitude,
        rayonMetres: e.rayonMetres,
        heureDebut: e.heureDebut,
        heureFin: e.heureFin,
        dateCours: e.dateCours,
        estArchive: e.estArchive,
        enseignantNom: e.enseignantNom,
        enseignantPrenom: e.enseignantPrenom,
        filiere: e.filiere,
        niveau: e.niveau,
      )).toList();
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: Colors.green,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildOfflineToggle(),
                      const SizedBox(height: 24),
                      if (_pendingSync > 0) _buildSyncBanner(),
                      const SizedBox(height: 24),
                      _buildStatsRow(),
                      const SizedBox(height: 28),
                      _buildCoursSection(),
                      const SizedBox(height: 24),
                      _buildActions(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour 👋',
              style: TextStyle(
                color: Colors.green[800]?.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_user?.prenom} ${_user?.nom}',
              style: GoogleFonts.outfit(
                color: Colors.green[900],
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withOpacity(0.15),
                ),
              ),
              child: Text(
                _user?.role.toUpperCase() ?? '',
                style: GoogleFonts.inter(
                  color: Colors.green[700],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _logout,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.red.withOpacity(0.15)),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.red[400],
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSyncBanner() {
    return GestureDetector(
      onTap: () async {
        await OfflineService.syncPresences();
        setState(() => _pendingSync = 0);
        if (mounted) Helpers.showSuccess(context, 'Synchronisation réussie !');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFF9800).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.sync, color: Color(0xFFFF9800), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_pendingSync présence(s) en attente de synchronisation. Appuyez pour synchroniser.',
                style: const TextStyle(color: Color(0xFFFF9800), fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('$_presencesStats', 'Présences', Colors.green),
        const SizedBox(width: 12),
        _buildStatCard('$_absencesStats', 'Absences', Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(_tauxStats, 'Taux', Colors.teal),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.outfit(
                color: color[700],
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.green[900]?.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tous mes cours',
              style: GoogleFonts.outfit(
                color: Colors.green[900],
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${_cours.length} cours',
              style: GoogleFonts.inter(
                color: Colors.green[800]?.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _cours.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.green.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    'Aucun cours aujourd\'hui',
                    style: GoogleFonts.inter(color: Colors.green.withOpacity(0.6)),
                  ),
                ),
              )
            : Column(
                children: _cours
                    .map((cours) => _buildCoursCard(cours))
                    .toList(),
              ),
      ],
    );
  }

  void _showTeacherOptions(CoursModel cours) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              cours.nom,
              style: GoogleFonts.outfit(
                color: Colors.green[900],
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_outlined, color: Colors.green),
              title: Text('Générer le rapport de présence (CSV)', style: GoogleFonts.inter()),
              onTap: () async {
                Navigator.pop(context);
                final response = await ApiService.getRaw('/cours/${cours.id}/report');
                if (response != null) {
                  if (mounted) Helpers.showSuccess(context, 'Rapport CSV généré et téléchargé (simulation)');
                } else {
                  if (mounted) Helpers.showError(context, 'Erreur lors de la génération du rapport');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursCard(CoursModel cours) {
    return GestureDetector(
      onTap: () async {
        if (_user?.role == 'enseignant') {
          _showTeacherOptions(cours);
        } else {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PresenceScreen(cours: cours),
            ),
          );
          // Recharger les données (stats) au retour
          _loadData();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.green.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.book_outlined, color: Colors.green, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    cours.nom,
                    style: GoogleFonts.outfit(
                      color: Colors.green[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.role == 'enseignant'
                        ? '${Helpers.formatHeure(cours.heureDebut)} — ${Helpers.formatHeure(cours.heureFin)} · ${cours.salle}'
                        : '${Helpers.formatHeure(cours.heureDebut)} — ${Helpers.formatHeure(cours.heureFin)} · ${cours.salle}\nProf: ${cours.enseignantPrenom} ${cours.enseignantNom}',
                    maxLines: _user?.role == 'enseignant' ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    textAlign: TextAlign.start,
                    style: GoogleFonts.inter(
                      color: Colors.green[800]?.withOpacity(0.6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 24,
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.green.withOpacity(0.3),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions rapides',
          style: GoogleFonts.outfit(
            color: Colors.green[900],
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionBtn(
              icon: Icons.history,
              label: 'Historique',
              color: Colors.green[600]!,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _buildActionBtn(
              icon: Icons.sync,
              label: 'Synchroniser',
              color: Colors.green[800]!,
              onTap: () async {
                await OfflineService.syncPresences();
                if (mounted) {
                  Helpers.showSuccess(context, 'Synchronisation réussie !');
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOfflineToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.offline_bolt, color: Colors.orange, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode hors-ligne',
                  style: TextStyle(
                    color: Colors.green[900],
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _offlineEnabled
                      ? 'Utilisation du cache local pour les données.'
                      : 'Utilisation du serveur pour toutes les actions.',
                  style: TextStyle(
                    color: Colors.green[800]?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _offlineEnabled,
            activeColor: Colors.green,
            onChanged: _toggleOfflineMode,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}