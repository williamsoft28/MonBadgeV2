const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const faceService = require('../services/faceService');

// Inscription (admin seulement)
exports.register = async (req, res) => {
  try {
    const { nom, prenom, matricule, email, mot_de_passe, role, filiere, niveau } = req.body;

    // Si le rôle n'est pas admin, le mot de passe devient le matricule
    const mdpToHash = (role === 'admin' && mot_de_passe) ? mot_de_passe : matricule;
    const hash = await bcrypt.hash(mdpToHash, 10);

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
      { 
        id: user.id, 
        role: user.role,
        filiere: user.filiere,
        niveau: user.niveau
      },
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
        biometrie_active: user.biometrie_enregistree === 1 || user.biometrie_enregistree === true,
      }
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Connexion via Biométrie
exports.loginBiometric = async (req, res) => {
  try {
    const { matricule, deviceToken } = req.body;

    if (!deviceToken) {
      return res.status(400).json({ error: 'Token biométrique manquant' });
    }

    const [rows] = await db.execute(
      `SELECT * FROM utilisateurs WHERE matricule = ? AND device_biometric_token = ?`,
      [matricule, deviceToken]
    );

    if (rows.length === 0) {
      return res.status(401).json({ error: '❌ Empreinte ou appareil non reconnu' });
    }

    const user = rows[0];

    const token = jwt.sign(
      { 
        id: user.id, 
        role: user.role,
        filiere: user.filiere,
        niveau: user.niveau
      },
      process.env.JWT_SECRET || 'monbadge_secret',
      { expiresIn: '7d' }
    );

    res.json({
      message: '✅ Connexion biométrique réussie',
      token,
      user: {
        id: user.id,
        nom: user.nom,
        prenom: user.prenom,
        matricule: user.matricule,
        role: user.role,
        filiere: user.filiere,
        niveau: user.niveau,
        biometrie_active: true,
      }
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Activer la biométrie avec une image (face recognition)
exports.enableBiometrics = async (req, res) => {
  try {
    const { userId, faceImageBase64 } = req.body;
    if (!userId) return res.status(400).json({ error: 'User ID manquant' });
    if (!faceImageBase64) return res.status(400).json({ error: 'Image du visage manquante' });

    // Analyser l'image et extraire le descripteur facial
    const descriptor = await faceService.getFaceDescriptor(faceImageBase64);
    if (!descriptor) {
      return res.status(400).json({ error: 'Aucun visage détecté sur la photo' });
    }

    // Convertir le Float32Array en string pour la base de données
    const descriptorString = JSON.stringify(Array.from(descriptor));

    let query = `UPDATE utilisateurs SET biometrie_enregistree = TRUE, face_descriptor = ? WHERE id = ?`;
    let params = [descriptorString, userId];

    await db.execute(query, params);

    res.json({ success: true, message: '✅ Biométrie (Visage) activée avec succès' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};