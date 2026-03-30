const db = require('../config/db');

// Liste tous les cours
exports.getAllCours = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT c.*, u.nom, u.prenom 
      FROM cours c
      JOIN utilisateurs u ON c.enseignant_id = u.id
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Cours d'un étudiant selon le jour
exports.getCoursDuJour = async (req, res) => {
  try {
    const jours = ['Dimanche','Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi'];
    const aujourd_hui = jours[new Date().getDay()];

    const [rows] = await db.execute(`
      SELECT c.*, u.nom, u.prenom
      FROM cours c
      JOIN utilisateurs u ON c.enseignant_id = u.id
      WHERE c.jour = ?
    `, [aujourd_hui]);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Détail d'un cours
exports.getCoursById = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT c.*, u.nom, u.prenom
      FROM cours c
      JOIN utilisateurs u ON c.enseignant_id = u.id
      WHERE c.id = ?
    `, [req.params.id]);

    if (rows.length === 0) {
      return res.status(404).json({ error: '❌ Cours non trouvé' });
    }

    res.json(rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Créer un cours (admin seulement)
exports.createCours = async (req, res) => {
  try {
    const { nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, jour } = req.body;

    await db.execute(`
      INSERT INTO cours (nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, jour)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, jour]);

    res.status(201).json({ message: '✅ Cours créé avec succès' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};