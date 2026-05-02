import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class AdminPresencesScreen extends StatefulWidget {
  const AdminPresencesScreen({super.key});

  @override
  State<AdminPresencesScreen> createState() => _AdminPresencesScreenState();
}

class _AdminPresencesScreenState extends State<AdminPresencesScreen> {
  List<dynamic> _rapport = [];
  List<dynamic> _absences = [];
  bool _isLoading = true;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final rapportResponse = await ApiService.get('/admin/rapport/cours');
    if (rapportResponse != null && rapportResponse is List) {
      setState(() => _rapport = rapportResponse);
    }

    final absencesResponse = await ApiService.get('/admin/rapport/absences');
    if (absencesResponse != null && absencesResponse is List) {
      setState(() => _absences = absencesResponse);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.green[800], size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gestion des présences',
          style: TextStyle(
              color: Colors.green[800],
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                // Tabs
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      _buildTab('Par cours', 0),
                      const SizedBox(width: 12),
                      _buildTab('Par étudiant', 1),
                    ],
                  ),
                ),

                // Contenu
                Expanded(
                  child: _selectedTab == 0
                      ? _buildRapportCours()
                      : _buildRapportEtudiants(),
                ),
              ],
            ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? null : Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.green[800],
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildRapportCours() {
    if (_rapport.isEmpty) {
      return Center(
        child: Text(
          'Aucune présence enregistrée',
          style: TextStyle(color: Colors.green.withOpacity(0.6)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _rapport.length,
      itemBuilder: (context, index) {
        final item = _rapport[index];
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['cours'] ?? '',
                style: TextStyle(
                  color: Colors.green[900],
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildInfoChip(
                    '${item['etudiants_presents']} présents',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    item['date'] != null
                        ? Helpers.formatDate(item['date'])
                        : '',
                    Colors.green[700]!,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRapportEtudiants() {
    if (_absences.isEmpty) {
      return Center(
        child: Text(
          'Aucune donnée',
          style: TextStyle(color: Colors.green.withOpacity(0.6)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _absences.length,
      itemBuilder: (context, index) {
        final item = _absences[index];
        final taux = double.tryParse(item['taux'].toString()) ?? 0;
        final color = taux >= 75
            ? Colors.green
            : taux >= 50
                ? Colors.orange
                : Colors.red;
        return Container(
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    '${taux.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['prenom']} ${item['nom']}',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['matricule'] ?? '',
                      style: TextStyle(
                        color: Colors.green[800]?.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${item['total_presences']}/${item['total_cours']}',
                style: TextStyle(
                  color: Colors.green[800]?.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}