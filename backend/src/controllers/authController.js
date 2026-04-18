const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Inscription (admin seulement)
exports.register = async (req, res) => {
  try {
    const { nom, prenom, matricule, email, mot_de_passe, role, filiere, niveau } = req.body;

    const hash = await bcrypt.hash(mot_de_passe, 10);

    await db.execute(
      `INSERT INTO utilisateurs (nom, prenom, matricule, email, mot_de_passe, role, filiere, niveau)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [nom, prenom, matricule, email, hash, role, filiere || null, niveau || null]
    );

    res.status(201).json({ message: '✅ Utilisateur créé avec succès' });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Connexion
exports.login = async (req, res) => {
  try {
    const { matricule, mot_de_passe, code_admin } = req.body;

    const [rows] = await db.execute(
      `SELECT * FROM utilisateurs WHERE matricule = ?`,
      [matricule]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: '❌ Utilisateur non trouvé' });
    }

    const user = rows[0];
    const match = await bcrypt.compare(mot_de_passe, user.mot_de_passe);

    if (!match) {
      return res.status(401).json({ error: '❌ Mot de passe incorrect' });
    }

    // Vérification code secret admin
    if (user.role === 'admin') {
      if (!code_admin) {
        return res.status(401).json({ error: '❌ Code administrateur requis' });
      }
      if (code_admin !== process.env.ADMIN_SECRET_CODE) {
        return res.status(401).json({ error: '❌ Code administrateur invalide' });
      }
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || 'monbadge_secret',
      { expiresIn: '7d' }
    );

    res.json({
      message: '✅ Connexion réussie',
      token,
      user: {
        id: user.id,
        nom: user.nom,
        prenom: user.prenom,
        matricule: user.matricule,
        role: user.role,
        filiere: user.filiere,
        niveau: user.niveau,
      }
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};