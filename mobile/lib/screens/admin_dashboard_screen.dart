import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';
import 'login_screen.dart';
import 'admin_users_screen.dart';
import 'admin_cours_screen.dart';
import 'admin_presences_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  UserModel? _user;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _offlineEnabled = ApiService.offlineMode;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _user = await AuthService.getCurrentUser();
    _offlineEnabled = ApiService.offlineMode;
    final response = await ApiService.get('/admin/stats');
    if (response != null) {
      setState(() => _stats = response);
    }
    setState(() => _isLoading = false);
  }

  Future<void> _toggleOfflineMode(bool enabled) async {
    await ApiService.setOfflineMode(enabled);
    if (mounted) {
      setState(() => _offlineEnabled = enabled);
      Helpers.showSuccess(context, enabled ? 'Mode hors-ligne activé' : 'Mode en ligne activé');
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
                      const SizedBox(height: 28),
                      _buildStatsWidget(),
                      const SizedBox(height: 24),
                      _buildOfflineToggle(),
                      const SizedBox(height: 28),
                      _buildMenuSection(),
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
              'Panel Admin 🛡️',
              style: TextStyle(
                color: Colors.green[800]?.withOpacity(0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_user?.prenom} ${_user?.nom}',
              style: TextStyle(
                color: Colors.green[900],
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _logout,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.2)),
            ),
            child: Icon(
              Icons.logout,
              color: Colors.green[800],
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsWidget() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats.isEmpty) {
      return const Center(child: Text('Aucune statistique disponible.'));
    }

    return Column(
      children: [
        Text('Utilisateurs : ${_stats['users'] ?? 0}', style: Theme.of(context).textTheme.titleLarge),
        Text('Cours : ${_stats['cours'] ?? 0}', style: Theme.of(context).textTheme.titleLarge),
        Text('Présences : ${_stats['presences'] ?? 0}', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vue d\'ensemble',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              '${_stats['total_etudiants'] ?? 0}',
              'Étudiants',
              Icons.school_outlined,
              Colors.green[600]!,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              '${_stats['total_cours'] ?? 0}',
              'Cours',
              Icons.book_outlined,
              Colors.green[700]!,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(
              '${_stats['presences_aujourdhui'] ?? 0}',
              'Présences aujourd\'hui',
              Icons.check_circle_outline,
              Colors.green[800]!,
            ),
            const SizedBox(width: 12),
            _buildStatCard(
              '${_stats['taux_presence_aujourdhui'] ?? 0}%',
              'Taux présence',
              Icons.pie_chart_outline,
              Colors.orange[700]!,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.green[800]?.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.offline_bolt, color: Colors.orange, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mode hors-ligne',
                  style: TextStyle(
                    color: Colors.green[900],
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _offlineEnabled
                      ? 'Les données sont servies depuis le cache local.'
                      : 'Toutes les actions utilisent le serveur.',
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

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gestion',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.people_outline,
          title: 'Gestion des utilisateurs',
          subtitle: 'Créer et gérer étudiants, enseignants',
          color: Colors.green[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
          ),
        ),
        _buildMenuItem(
          icon: Icons.book_outlined,
          title: 'Gestion des cours',
          subtitle: 'Créer cours et attribuer aux enseignants',
          color: Colors.green[700]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminCoursScreen()),
          ),
        ),
        _buildMenuItem(
          icon: Icons.fact_check_outlined,
          title: 'Gestion des présences',
          subtitle: 'Voir et gérer les présences',
          color: Colors.green[800]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminPresencesScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.green[900],
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.green[800]?.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.green.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}