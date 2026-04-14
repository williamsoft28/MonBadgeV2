import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/cours_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _user = await AuthService.getCurrentUser();
    await _loadCours();
    _pendingSync = await OfflineService.countPendingSync();
    setState(() => _isLoading = false);
  }

  Future<void> _loadCours() async {
    final response = await ApiService.get('/cours/jour');
    if (response != null && response is List) {
      setState(() {
        _cours = response.map((c) => CoursModel.fromJson(c)).toList();
      });
    }
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
      backgroundColor: const Color(0xFF0A0A0F),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF6C63FF),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
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
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_user?.prenom} ${_user?.nom}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6C63FF).withOpacity(0.3),
                ),
              ),
              child: Text(
                _user?.role.toUpperCase() ?? '',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _logout,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.logout,
                  color: Colors.white.withOpacity(0.5),
                  size: 18,
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
        _buildStatCard('24', 'Présences', const Color(0xFF6C63FF)),
        const SizedBox(width: 12),
        _buildStatCard('3', 'Absences', const Color(0xFFE53935)),
        const SizedBox(width: 12),
        _buildStatCard('89%', 'Taux', const Color(0xFF00D4AA)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
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
            const Text(
              'Cours du jour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_cours.length} cours',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _cours.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Aucun cours aujourd\'hui',
                    style: TextStyle(color: Colors.white.withOpacity(0.4)),
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

  Widget _buildCoursCard(CoursModel cours) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PresenceScreen(cours: cours),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.book_outlined,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cours.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${Helpers.formatHeure(cours.heureDebut)} — ${Helpers.formatHeure(cours.heureFin)} · ${cours.salle}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.2),
              size: 14,
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
        const Text(
          'Actions rapides',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildActionBtn(
              icon: Icons.history,
              label: 'Historique',
              color: const Color(0xFF6C63FF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoriqueScreen()),
              ),
            ),
            const SizedBox(width: 12),
            _buildActionBtn(
              icon: Icons.sync,
              label: 'Synchroniser',
              color: const Color(0xFF00D4AA),
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
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}