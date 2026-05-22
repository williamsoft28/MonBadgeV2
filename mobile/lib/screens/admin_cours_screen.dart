import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
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
  final _dateCoursController = TextEditingController();
  String? _filiere;
  String? _niveau;
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
    _dateCoursController.dispose();
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
        _heureDebutController.text.isEmpty ||
        _heureFinController.text.isEmpty ||
        _enseignantId == null) {
      Helpers.showError(context, 'Veuillez remplir tous les champs requis.');
      return;
    }

    final lat = _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text.replaceAll(',', '.'));
    final lng = _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text.replaceAll(',', '.'));

    if ((_latitudeController.text.isNotEmpty && lat == null) || 
        (_longitudeController.text.isNotEmpty && lng == null)) {
      Helpers.showError(context, 'Les coordonnées GPS doivent être des nombres valides.');
      return;
    }

    final coursData = {
      'nom': _nomController.text,
      'salle': _salleController.text,
      'latitude': lat,
      'longitude': lng,
      'heure_debut': _heureDebutController.text,
      'heure_fin': _heureFinController.text,
      'date_cours': _dateCoursController.text,
      'enseignant_id': _enseignantId,
      'filiere': _filiere,
      'niveau': _niveau,
    };

    final response = await ApiService.post('/cours', coursData);
    if (response != null && response['success'] == true) {
      Helpers.showSuccess(context, 'Cours créé avec succès.');
      _loadData(); // Recharger la liste des cours
      Navigator.pop(context); // Fermer le modal
    } else {
      Helpers.showError(context, response?['error'] ?? 'Échec de la création du cours.');
    }
  }

  Future<void> _updateCours(int id) async {
    if (_nomController.text.isEmpty ||
        _salleController.text.isEmpty ||
        _heureDebutController.text.isEmpty ||
        _heureFinController.text.isEmpty ||
        _enseignantId == null) {
      Helpers.showError(context, 'Veuillez remplir tous les champs requis.');
      return;
    }

    final lat = _latitudeController.text.isEmpty ? null : double.tryParse(_latitudeController.text.replaceAll(',', '.'));
    final lng = _longitudeController.text.isEmpty ? null : double.tryParse(_longitudeController.text.replaceAll(',', '.'));

    if ((_latitudeController.text.isNotEmpty && lat == null) || 
        (_longitudeController.text.isNotEmpty && lng == null)) {
      Helpers.showError(context, 'Les coordonnées GPS doivent être des nombres valides.');
      return;
    }

    final coursData = {
      'nom': _nomController.text,
      'salle': _salleController.text,
      'latitude': lat,
      'longitude': lng,
      'heure_debut': _heureDebutController.text,
      'heure_fin': _heureFinController.text,
      'date_cours': _dateCoursController.text,
      'enseignant_id': _enseignantId,
      'filiere': _filiere,
      'niveau': _niveau,
    };

    final response = await ApiService.put('/cours/$id', coursData);
    if (response != null && response['success'] == true) {
      Helpers.showSuccess(context, 'Cours modifié avec succès.');
      _loadData(); // Recharger la liste des cours
      Navigator.pop(context); // Fermer le modal
    } else {
      Helpers.showError(context, response?['error'] ?? 'Échec de la modification du cours.');
    }
  }

  Future<void> _deleteCours(int id) async {
    final response = await ApiService.delete('/cours/$id');
    if (response != null && response['success'] == true) {
      Helpers.showSuccess(context, 'Cours supprimé avec succès.');
      _loadData();
    } else {
      Helpers.showError(context, response?['error'] ?? 'Échec de la suppression du cours.');
    }
  }

  void _clearForm() {
    _nomController.clear();
    _salleController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _heureDebutController.clear();
    _heureFinController.clear();
    _dateCoursController.clear();
    _filiere = null;
    setState(() {
      _enseignantId = null;
      _niveau = null;
    });
  }

  void _showCreateModal({CoursModel? coursToEdit}) {
    if (coursToEdit == null) _clearForm();
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
                      coursToEdit == null ? 'Créer un cours' : 'Modifier le cours',
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
                
                _buildModalLabel('Nom du cours (Matière)'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _nomController.text.isEmpty ? null : _nomController.text,
                      hint: Text(
                        'Sélectionner une matière',
                        style: TextStyle(color: Colors.green.withOpacity(0.4)),
                      ),
                      dropdownColor: Colors.white,
                      style: TextStyle(color: Colors.green[800]),
                      isExpanded: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                      items: [
                        if (_nomController.text.isNotEmpty &&
                            !_enseignants.any((e) => e.matiere == _nomController.text))
                          _nomController.text,
                        ..._enseignants
                            .map((e) => e.matiere)
                            .where((m) => m != null && m.isNotEmpty)
                            .cast<String>()
                      ]
                          .toSet()
                          .map((m) => DropdownMenuItem<String>(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _nomController.text = value ?? '');
                        setModalState(() => _nomController.text = value ?? '');
                      },
                    ),
                  ),
                ),
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
                        setModalState(() {
                          _enseignantId = value;
                          // Auto-select matiere if teacher has one
                          final teacher = _enseignants.firstWhere((e) => e.id == value);
                          if (teacher.matiere != null && teacher.matiere!.isNotEmpty) {
                            _nomController.text = teacher.matiere!;
                          }
                        });
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
                          _buildModalLabel('Date'),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: Colors.green,
                                        onPrimary: Colors.white,
                                        onSurface: Colors.green[900]!,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() {
                                  _dateCoursController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                            child: AbsorbPointer(
                              child: _buildModalTextField(_dateCoursController, 'YYYY-MM-DD', Icons.calendar_today_outlined),
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

                // Row: Filière & Niveau
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Filière (Optionnel)'),
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
                                value: _filiere,
                                hint: Text('Tous', style: TextStyle(color: Colors.green.withOpacity(0.4), fontSize: 13)),
                                dropdownColor: Colors.white,
                                style: TextStyle(color: Colors.green[800]),
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                                items: [null, 'Droit', 'Banque', 'Finance']
                                    .map((f) => DropdownMenuItem(value: f, child: Text(f ?? 'Tous')))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _filiere = value);
                                  setModalState(() => _filiere = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Niveau (Optionnel)'),
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
                                value: _niveau,
                                hint: Text('Tous', style: TextStyle(color: Colors.green.withOpacity(0.4), fontSize: 13)),
                                dropdownColor: Colors.white,
                                style: TextStyle(color: Colors.green[800]),
                                isExpanded: true,
                                icon: Icon(Icons.arrow_drop_down, color: Colors.green),
                                items: [null, 'Licence 1', 'Licence 2', 'Licence 3', 'Master 1', 'Master 2']
                                    .map((n) => DropdownMenuItem(value: n, child: Text(n ?? 'Tous')))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() => _niveau = value);
                                  setModalState(() => _niveau = value);
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

                // Row: Latitude & Longitude
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Lat GPS (Opt.)'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_latitudeController, '12.365', Icons.location_on_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModalLabel('Lng GPS (Opt.)'),
                          const SizedBox(height: 8),
                          _buildModalTextField(_longitudeController, '-1.533', Icons.location_on_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 52,
                      width: 52,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.my_location, color: Colors.green),
                        onPressed: () async {
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            if (context.mounted) Helpers.showError(context, 'Les services de localisation sont désactivés.');
                            return;
                          }
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.denied) {
                              if (context.mounted) Helpers.showError(context, 'Les permissions de localisation sont refusées.');
                              return;
                            }
                          }
                          if (permission == LocationPermission.deniedForever) {
                            if (context.mounted) Helpers.showError(context, 'Les permissions sont définitivement refusées.');
                            return;
                          }
                          
                          if (context.mounted) Helpers.showSuccess(context, 'Récupération de la position...');
                          try {
                            Position position = await Geolocator.getCurrentPosition(
                              desiredAccuracy: LocationAccuracy.high,
                            );
                            setModalState(() {
                              _latitudeController.text = position.latitude.toString();
                              _longitudeController.text = position.longitude.toString();
                            });
                          } catch (e) {
                            if (context.mounted) Helpers.showError(context, 'Erreur lors de la récupération de la position.');
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (coursToEdit == null) {
                        _createCours();
                      } else {
                        _updateCours(coursToEdit.id);
                      }
                    },
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
                      child: Center(
                        child: Text(
                          coursToEdit == null ? 'Créer le cours' : 'Enregistrer les modifications',
                          style: const TextStyle(
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
                                  '${cours.dateCours} · ${Helpers.formatHeure(cours.heureDebut)} - ${Helpers.formatHeure(cours.heureFin)}',
                                  style: TextStyle(
                                    color: Colors.green[800]?.withOpacity(0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                if (cours.filiere != null || cours.niveau != null)
                                  Text(
                                    '${cours.niveau ?? ''} ${cours.filiere ?? ''}'.trim(),
                                    style: TextStyle(
                                      color: Colors.green[800]?.withOpacity(0.5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  'Salle: ${cours.salle} · Prof: ${cours.enseignantPrenom} ${cours.enseignantNom}',
                                  style: TextStyle(
                                    color: Colors.green[800]?.withOpacity(0.5),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _nomController.text = cours.nom;
                                  _salleController.text = cours.salle;
                                  _latitudeController.text = cours.latitude.toString();
                                  _longitudeController.text = cours.longitude.toString();
                                  _heureDebutController.text = cours.heureDebut;
                                  _heureFinController.text = cours.heureFin;
                                  _dateCoursController.text = cours.dateCours;
                                  _enseignantId = cours.enseignantId;
                                  _filiere = cours.filiere;
                                  _niveau = cours.niveau;
                                  _showCreateModal(coursToEdit: cours);
                                },
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue.withOpacity(0.7),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: Text(
                                      'Supprimer ?',
                                      style: TextStyle(color: Colors.green[900]),
                                    ),
                                    content: Text(
                                      'Voulez-vous supprimer le cours ${cours.nom} ?',
                                      style: TextStyle(
                                        color: Colors.green[800]?.withOpacity(0.8),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteCours(cours.id);
                                        },
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.withOpacity(0.7),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () async {
                                  // Télécharger le rapport
                                  final response = await ApiService.getRaw('/cours/${cours.id}/report');
                                  if (response != null) {
                                    Helpers.showSuccess(context, 'Rapport CSV téléchargé (simulation)');
                                  } else {
                                    Helpers.showError(context, 'Erreur lors du téléchargement du rapport');
                                  }
                                },
                                child: Icon(
                                  Icons.download_outlined,
                                  color: Colors.green.withOpacity(0.7),
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}