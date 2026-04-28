import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/helpers.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<UserModel> _users = [];
  bool _isLoading = true;

  // Controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _filiereController = TextEditingController();
  final _niveauController = TextEditingController();
  String _role = 'etudiant';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _matriculeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _filiereController.dispose();
    _niveauController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final response = await ApiService.get('/admin/users');
    if (response != null && response is List) {
      setState(() {
        _users = response.map((u) => UserModel.fromJson(u)).toList();
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createUser() async {
    if (_nomController.text.isEmpty ||
        _prenomController.text.isEmpty ||
        _matriculeController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      Helpers.showError(context, 'Veuillez remplir tous les champs');
      return;
    }

    final body = {
      'nom': _nomController.text.trim(),
      'prenom': _prenomController.text.trim(),
      'matricule': _matriculeController.text.trim(),
      'email': _emailController.text.trim(),
      'mot_de_passe': _passwordController.text,
      'role': _role,
    };

    if (_role == 'etudiant') {
      body['filiere'] = _filiereController.text.trim();
      body['niveau'] = _niveauController.text.trim();
    }

    final response = await ApiService.post('/auth/register', body);

    if (response != null && response['message'] != null) {
      if (mounted) {
        Helpers.showSuccess(context, 'Utilisateur créé avec succès !');
        Navigator.pop(context);
        _loadUsers();
        _clearForm();
      }
    } else {
      if (mounted) {
        Helpers.showError(context, response?['error'] ?? 'Erreur création');
      }
    }
  }

  void _clearForm() {
    _nomController.clear();
    _prenomController.clear();
    _matriculeController.clear();
    _emailController.clear();
    _passwordController.clear();
    _filiereController.clear();
    _niveauController.clear();
    setState(() => _role = 'etudiant');
  }

  Future<void> _deleteUser(int id) async {
    final response = await ApiService.delete('/admin/users/$id');
    if (response != null) {
      Helpers.showSuccess(context, 'Utilisateur supprimé !');
      _loadUsers();
    }
  }

  void _showCreateModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A2E),
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
                    const Text(
                      'Créer un utilisateur',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close,
                          color: Colors.white.withOpacity(0.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Rôle
                _buildModalLabel('Rôle'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0A0F),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _role,
                      dropdownColor: const Color(0xFF1A1A2E),
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                            value: 'etudiant', child: Text('Étudiant')),
                        DropdownMenuItem(
                            value: 'enseignant', child: Text('Enseignant')),
                        DropdownMenuItem(
                            value: 'admin', child: Text('Administrateur')),
                      ],
                      onChanged: (value) {
                        setState(() => _role = value!);
                        setModalState(() => _role = value!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                _buildModalLabel('Nom'),
                const SizedBox(height: 8),
                _buildModalTextField(_nomController, 'Traoré', Icons.person_outline),
                const SizedBox(height: 16),

                _buildModalLabel('Prénom'),
                const SizedBox(height: 8),
                _buildModalTextField(_prenomController, 'Mamadou', Icons.person_outline),
                const SizedBox(height: 16),

                _buildModalLabel('Matricule'),
                const SizedBox(height: 8),
                _buildModalTextField(_matriculeController, 'ETU-2024-001', Icons.badge_outlined),
                const SizedBox(height: 16),

                _buildModalLabel('Email'),
                const SizedBox(height: 8),
                _buildModalTextField(_emailController, 'email@exemple.com', Icons.email_outlined),
                const SizedBox(height: 16),

                _buildModalLabel('Mot de passe'),
                const SizedBox(height: 8),
                _buildModalTextField(_passwordController, '••••••••', Icons.lock_outline, isPassword: true),
                const SizedBox(height: 16),

                // Champs spécifiques étudiant
                if (_role == 'etudiant') ...[
                  _buildModalLabel('Filière'),
                  const SizedBox(height: 8),
                  _buildModalTextField(_filiereController, 'Informatique', Icons.school_outlined),
                  const SizedBox(height: 16),

                  _buildModalLabel('Niveau'),
                  const SizedBox(height: 8),
                  _buildModalTextField(_niveauController, 'Licence 3', Icons.grade_outlined),
                  const SizedBox(height: 16),
                ],

                // Info biométrie
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6C63FF).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint,
                          color: Color(0xFF6C63FF), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'La biométrie sera enregistrée à la première connexion de l\'utilisateur',
                          style: TextStyle(
                            color: const Color(0xFF6C63FF).withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _createUser,
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
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'Créer l\'utilisateur',
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
        color: Colors.white.withOpacity(0.7),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildModalTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
          prefixIcon:
              Icon(icon, color: Colors.white.withOpacity(0.3), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return const Color(0xFFE53935);
      case 'enseignant':
        return const Color(0xFF00D4AA);
      default:
        return const Color(0xFF6C63FF);
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'enseignant':
        return 'Enseignant';
      default:
        return 'Étudiant';
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
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gestion utilisateurs',
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _showCreateModal,
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF00D4AA)],
                ),
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
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)))
          : _users.isEmpty
              ? Center(
                  child: Text(
                    'Aucun utilisateur',
                    style:
                        TextStyle(color: Colors.white.withOpacity(0.4)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final color = _getRoleColor(user.role);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.06)),
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
                                '${user.prenom[0]}${user.nom[0]}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
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
                                  '${user.prenom} ${user.nom}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.matricule,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                  ),
                                ),
                                if (user.filiere != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    '${user.filiere} · ${user.niveau}',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _getRoleLabel(user.role),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor:
                                        const Color(0xFF1A1A2E),
                                    title: const Text(
                                      'Supprimer ?',
                                      style:
                                          TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      'Voulez-vous supprimer ${user.prenom} ${user.nom} ?',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.6)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        child: const Text('Annuler'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteUser(user.id);
                                        },
                                        child: const Text(
                                          'Supprimer',
                                          style: TextStyle(
                                              color: Color(0xFFE53935)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white.withOpacity(0.3),
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