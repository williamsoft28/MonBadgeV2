import 'package:flutter/material.dart';
import '../models/cours_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class AdminCoursScreen extends StatefulWidget {
  const AdminCoursScreen({super.key});

  @override
  State<AdminCoursScreen> createState() => _AdminCoursScreenState();
}

class _AdminCoursScreenState extends State<AdminCoursScreen> {
  List<CoursModel> _cours = [];
  List<UserModel> _enseignants = [];
  bool _isLoading = true;

  final _nomController = TextEditingController();
  final _salleController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  String _jour = 'Lundi';
  int? _enseignantId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _salleController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final coursResponse = await ApiService.get('/cours');
    if (coursResponse != null && coursResponse is List) {
      setState(() {
        _cours = coursResponse.map((c) => CoursModel.fromJson(c)).toList();
      });
    }

    final usersResponse = await ApiService.get('/admin/users');
    if (usersResponse != null && usersResponse is List) {
      setState(() {
        _enseignants = usersResponse
            .map((u) => UserModel.fromJson(u))
            .where((u) => u.role == 'enseignant')
            .toList();
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _createCours() async {
    if (_nomController.text.isEmpty ||
        _salleController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty ||
        _heureDebutController.text.isEmpty ||
        _heureFinController.text.isEmpty ||
        _enseignantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs requis.')),
      );
      return;
    }

    final coursData = {
      'nom': _nomController.text,
      'salle': _salleController.text,
      'latitude': double.tryParse(_latitudeController.text),
      'longitude': double.tryParse(_longitudeController.text),
      'heureDebut': _heureDebutController.text,
      'heureFin': _heureFinController.text,
      'jour': _jour,
      'enseignantId': _enseignantId,
    };

    final response = await ApiService.post('/api/cours', coursData);
    if (response != null && response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cours créé avec succès.')),
      );
      _loadData(); // Recharger la liste des cours
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la création du cours.')),
      );
    }
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Créer un cours',
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: Colors.green[800]?.withOpacity(0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildModalLabel('Nom du cours'),
                const SizedBox(height: 8),
                _buildModalTextField(_nomController, 'Algorithmique', Icons.book_outlined),
                const SizedBox(height: 16),
                
                _buildModalLabel('Enseignant'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _enseignantId,
                      hint: Text(
                        'Sélectionner un enseignant',
                        style: TextStyle(color: Colors.green.withOpacity(0.4)),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.green[800]),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                      items: _enseignants
                          .map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text('${e.prenom} ${e.nom}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _enseignantId = value);
                        setModalState(() => _enseignantId = value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Row: Salle & Jour
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Salle'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_salleController, 'A04', Icons.room_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Jour'),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _jour,
                                dropdownColor: Colors.white,
                                style: TextStyle(color: Colors.green[800]),
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                                items: ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
                                    .map((j) => DropdownMenuItem(value: j, child: Text(j)))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _jour = value!);
                                  setModalState(() => _jour = value!);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row: Heure Debut & Fin
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Début'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_heureDebutController, '08:00', Icons.access_time),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Fin'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_heureFinController, '10:00', Icons.access_time),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Row: Latitude & Longitude
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Lat GPS'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_latitudeController, '12.365', Icons.location_on_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Lng GPS'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_longitudeController, '-1.533', Icons.location_on_outlined),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _createCours,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Créer le cours',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.green[800],
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildModalTextField(
      TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.green[900], fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.green.withOpacity(0.4)),
          prefixIcon:
              Icon(icon, color: Colors.green, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
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
          'Gestion des cours',
          style: TextStyle(
              color: Colors.green[800],
              fontSize: 18,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _showCreateModal,
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.green))
          : _cours.isEmpty
              ? Center(
                  child: Text(
                    'Aucun cours',
                    style: TextStyle(color: Colors.green.withOpacity(0.6)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _cours.length,
                  itemBuilder: (context, index) {
                    final cours = _cours[index];
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.book_outlined,
                                color: Colors.green, size: 22),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cours.nom,
                                  style: TextStyle(
                                    color: Colors.green[900],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${cours.jour} · ${Helpers.formatHeure(cours.heureDebut)} - ${Helpers.formatHeure(cours.heureFin)}',
                                  style: TextStyle(
                                    color: Colors.green[800]?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  cours.salle,
                                  style: TextStyle(
                                    color: Colors.green[800]?.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
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