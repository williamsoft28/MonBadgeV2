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
    List<PresenceModel> combinedList = [];

    // 1. Récupérer l'historique en ligne (API)
    final response = await ApiService.get('/presences/historique');
    if (response != null && response is List) {
      combinedList.addAll(response.map((p) => PresenceModel.fromJson(p)).toList());
    }

    // 2. Toujours récupérer la file d'attente hors-ligne (SQLite)
    final pending = await OfflineService.getDB().getPendingPresences();
    if (pending.isNotEmpty) {
      final offlinePresences = pending.map(
        (p) => PresenceModel(
          id: p.id,
          etudiantId: p.etudiantId,
          coursId: p.coursId,
          date: p.date,
          heurePointage: p.heurePointage,
          statut: 'EN ATTENTE DE SYNCHRONISATION ⏳',
          latitude: p.latitude,
          longitude: p.longitude,
          biometrieValidee: p.biometrieValidee,
          syncServeur: false,
        ),
      ).toList();
      
      // Ajouter au début de la liste
      combinedList.insertAll(0, offlinePresences);
    }

    setState(() {
      _presences = combinedList;
      _isLoading = false;
    });
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
                final isPending = !p.syncServeur;
                final statusColor = isPending ? Colors.orange : Colors.green;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(isPending ? 0.5 : 0.2), width: isPending ? 2 : 1),
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
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isPending ? Icons.hourglass_top : Icons.check_circle_outline,
                          color: statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.coursNom ?? 'Cours (Hors-ligne)',
                              style: TextStyle(
                                color: isPending ? Colors.orange[900] : Colors.green[900],
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${Helpers.formatDate(p.date)} · ${Helpers.formatHeure(p.heurePointage)}',
                              style: TextStyle(
                                color: (isPending ? Colors.orange[800] : Colors.green[800])?.withOpacity(0.6),
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
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.statut.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
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
