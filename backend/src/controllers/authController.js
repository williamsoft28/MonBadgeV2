const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const faceService = require('../services/faceService');
const faceFeatureService = require('../services/faceFeatureService');

// Inscription (admin seulement)
exports.register = async (req, res) => {
  try {
    const { nom, prenom, matricule, email, mot_de_passe, role, filiere, niveau, matiere } = req.body;

    // Si le rôle n'est pas admin, le mot de passe devient le matricule
    const mdpToHash = (role === 'admin' && mot_de_passe) ? mot_de_passe : matricule;
    const hash = await bcrypt.hash(mdpToHash, 10);

    await db.execute(
      `INSERT INTO utilisateurs (nom, prenom, matricule, email, mot_de_passe, role, filiere, niveau, matiere)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [nom, prenom, matricule, email, hash, role, filiere || null, niveau || null, matiere || null]
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

    // Connexion admin simplifiée (plus de code secret requis)

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

// Enregistrer les features faciales (ML Kit) et le descripteur (DeepFace)
exports.enrollFace = async (req, res) => {
  try {
    const userId = req.user.id;
    const { faceFeatures, faceImageBase64 } = req.body;

    if (!faceImageBase64 && !faceFeatures) {
      return res.status(400).json({ error: '❌ Données du visage manquantes' });
    }

    // Obtenir le descripteur depuis DeepFace (optionnel si le serveur Python est éteint)
    let descriptorString = null;
    if (faceImageBase64) {
      const descriptor = await faceService.getFaceDescriptor(faceImageBase64);
      if (descriptor) {
        descriptorString = JSON.stringify(Array.from(descriptor));
      }
    }

    const featuresString = (faceFeatures && Array.isArray(faceFeatures)) 
                            ? JSON.stringify(faceFeatures.map(Number)) 
                            : null;

    if (!descriptorString && !featuresString) {
      return res.status(400).json({ error: '❌ Aucun visage détecté sur la photo d\'enregistrement' });
    }

    await db.execute(
      `UPDATE utilisateurs 
       SET biometrie_enregistree = TRUE, face_features = ?, face_descriptor = ? 
       WHERE id = ?`,
      [featuresString, descriptorString, userId]
    );

    res.json({
      success: true,
      message: '✅ Visage enregistré avec succès',
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Vérifier le visage au pointage (comparaison serveur)
exports.verifyFace = async (req, res) => {
  try {
    const userId = req.user.id;
    const { faceFeatures, faceImageBase64 } = req.body;

    const [rows] = await db.execute(
      'SELECT face_features, face_descriptor, biometrie_enregistree FROM utilisateurs WHERE id = ?',
      [userId]
    );

    if (rows.length === 0 || (!rows[0].face_features && !rows[0].face_descriptor)) {
      return res.status(403).json({
        error: '❌ Visage non enregistré. Complétez l\'enregistrement facial.',
        verified: false,
      });
    }

    let verified = false;
    let similarityPercent = 0;
    let errorMessage = '';

    // Tentative 1 : DeepFace
    if (faceImageBase64 && rows[0].face_descriptor) {
      const savedDescriptor = new Float32Array(JSON.parse(rows[0].face_descriptor));
      const currentDescriptor = await faceService.getFaceDescriptor(faceImageBase64);
      if (currentDescriptor) {
        const distance = faceService.compareFaces(savedDescriptor, currentDescriptor);
        verified = !isNaN(distance) && distance <= 0.40; // Seuil assoupli à 0.40 pour réduire les faux rejets
        similarityPercent = Math.round(Math.max(0, 1 - distance) * 100);
        errorMessage = `❌ Visage non reconnu par DeepFace (${similarityPercent}%)`;
      }
    }

    // Tentative 2 : ML Kit (Fallback si DeepFace échoue, est éteint, ou inexistant)
    if (!verified && faceFeatures && Array.isArray(faceFeatures) && rows[0].face_features) {
      const savedFeatures = JSON.parse(rows[0].face_features);
      const similarity = faceFeatureService.compareFeatures(savedFeatures, faceFeatures);
      const mlKitSimilarityPercent = faceFeatureService.toPercent(similarity);
      
      if (mlKitSimilarityPercent >= 80) { // Seuil abaissé à 80% pour consistance avec le local
        verified = true;
        similarityPercent = mlKitSimilarityPercent;
        errorMessage = '';
      } else {
        if (mlKitSimilarityPercent > similarityPercent) {
          similarityPercent = mlKitSimilarityPercent;
          errorMessage = `❌ Visage non reconnu (${similarityPercent}% — minimum 80%)`;
        }
      }
    }

    if (!verified) {
      return res.status(403).json({
        success: false,
        verified: false,
        similarity: similarityPercent,
        error: errorMessage || '❌ Visage non enregistré ou non reconnu.',
      });
    }

    res.json({
      success: true,
      verified: true,
      similarity: similarityPercent,
      message: `✅ Visage reconnu (${similarityPercent}%)`,
    });
  } catch (err) {
    res.status(500).json({ error: err.message, verified: false });
  }
};

// Récupérer tous les utilisateurs pour le cache hors-ligne
exports.getOfflineUsers = async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT id, nom, prenom, matricule, mot_de_passe, role, filiere, niveau, face_features, biometrie_enregistree FROM utilisateurs'
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};