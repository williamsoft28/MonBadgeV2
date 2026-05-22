import 'package:flutter/material.dart';
import '../models/presence_model.dart';
import '../services/api_service.dart';
import '../services/offline_service.dart';
import '../utils/helpers.dart';

class HistoriqueScreen extends StatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  State<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  List<PresenceModel> _presences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    final response = await ApiService.get('/presences/historique');
    if (response != null && response is List) {
      setState(() {
        _presences = response.map((p) => PresenceModel.fromJson(p)).toList();
      });
    } else {
      final pending = await OfflineService.getDB().getPendingPresences();
      setState(() {
        _presences = pending
            .map(
              (p) => PresenceModel(
                id: p.id,
                etudiantId: p.etudiantId,
                coursId: p.coursId,
                date: p.date,
                heurePointage: p.heurePointage,
                statut: 'EN ATTENTE',
                latitude: p.latitude,
                longitude: p.longitude,
                biometrieValidee: p.biometrieValidee,
                syncServeur: false,
              ),
            )
            .toList();
      });
    }
    setState(() => _isLoading = false);
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
          'Historique',
          style: TextStyle(
            color: Colors.green[900],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _presences.isEmpty
          ? Center(
              child: Text(
                'Aucune présence enregistrée',
                style: TextStyle(color: Colors.green.withOpacity(0.6)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _presences.length,
              itemBuilder: (context, index) {
                final p = _presences[index];
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.coursNom ?? 'Cours',
                              style: TextStyle(
                                color: Colors.green[900],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${Helpers.formatDate(p.date)} · ${Helpers.formatHeure(p.heurePointage)}',
                              style: TextStyle(
                                color: Colors.green[800]?.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.statut.toUpperCase(),
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
