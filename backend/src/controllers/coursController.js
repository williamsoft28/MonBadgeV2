const db = require('../config/db');

// Liste tous les cours
exports.getAllCours = async (req, res) => {
  try {
    const today = new Date();
    const dateStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;
    
    // Auto-archivage des cours passés
    await db.execute('UPDATE cours SET est_archive = TRUE WHERE date_cours < ? AND est_archive = FALSE', [dateStr]);

    let query = `
      SELECT c.*, u.nom AS enseignant_nom, u.prenom AS enseignant_prenom 
      FROM cours c
      JOIN utilisateurs u ON c.enseignant_id = u.id
      WHERE 1=1
    `;
    let params = [];

    // L'admin voit tout. Les autres ne voient que les non-archivés
    if (req.user && req.user.role !== 'admin') {
      query += ` AND c.est_archive = FALSE`;
    }

    // Filtrer par niveau et filière si c'est un étudiant
    if (req.user && req.user.role === 'etudiant') {
      let filiere = req.user.filiere;
      let niveau = req.user.niveau;
      
      if (filiere === undefined || niveau === undefined) {
        const [uRows] = await db.execute('SELECT filiere, niveau FROM utilisateurs WHERE id = ?', [req.user.id]);
        if (uRows.length > 0) {
          filiere = uRows[0].filiere;
          niveau = uRows[0].niveau;
        }
      }

      if (filiere && niveau) {
        query += ` AND (LOWER(c.filiere) = LOWER(?) OR c.filiere IS NULL OR c.filiere = '') AND (c.niveau = ? OR c.niveau IS NULL OR c.niveau = '')`;
        params.push(filiere, niveau);
      } else if (filiere) {
        query += ` AND (LOWER(c.filiere) = LOWER(?) OR c.filiere IS NULL OR c.filiere = '')`;
        params.push(filiere);
      } else if (niveau) {
        query += ` AND (c.niveau = ? OR c.niveau IS NULL OR c.niveau = '')`;
        params.push(niveau);
      }
    } else if (req.user && req.user.role === 'enseignant') {
      query += ` AND c.enseignant_id = ?`;
      params.push(req.user.id);
    }

    // Trier par date croissante
    query += ` ORDER BY c.date_cours ASC, c.heure_debut ASC`;

    const [rows] = await db.execute(query, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Cours d'un étudiant pour aujourd'hui
exports.getCoursDuJour = async (req, res) => {
  try {
    const today = new Date();
    const dateStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

    let query = `
      SELECT c.*, u.nom AS enseignant_nom, u.prenom AS enseignant_prenom,
             (SELECT COUNT(*) FROM presences p WHERE p.cours_id = c.id) AS total_presents
      FROM cours c
      JOIN utilisateurs u ON c.enseignant_id = u.id
      WHERE c.date_cours = ? AND c.est_archive = FALSE
    `;
    let params = [dateStr];

    // Filtrer par niveau et filière si c'est un étudiant
    if (req.user && req.user.role === 'etudiant') {
      let filiere = req.user.filiere;
      let niveau = req.user.niveau;
      
      if (filiere === undefined || niveau === undefined) {
        const [uRows] = await db.execute('SELECT filiere, niveau FROM utilisateurs WHERE id = ?', [req.user.id]);
        if (uRows.length > 0) {
          filiere = uRows[0].filiere;
          niveau = uRows[0].niveau;
        }
      }

      if (filiere && niveau) {
        query += ` AND (LOWER(c.filiere) = LOWER(?) OR c.filiere IS NULL OR c.filiere = '') AND (c.niveau = ? OR c.niveau IS NULL OR c.niveau = '')`;
        params.push(filiere, niveau);
      } else if (filiere) {
        query += ` AND (LOWER(c.filiere) = LOWER(?) OR c.filiere IS NULL OR c.filiere = '')`;
        params.push(filiere);
      } else if (niveau) {
        query += ` AND (c.niveau = ? OR c.niveau IS NULL OR c.niveau = '')`;
        params.push(niveau);
      }
    } else if (req.user && req.user.role === 'enseignant') {
      query += ` AND c.enseignant_id = ?`;
      params.push(req.user.id);
    }

    query += ` ORDER BY c.heure_debut ASC`;

    const [rows] = await db.execute(query, params);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Détail d'un cours
exports.getCoursById = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT c.*, u.nom AS enseignant_nom, u.prenom AS enseignant_prenom
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
    const { nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, date_cours, filiere, niveau } = req.body;

    const rayon = rayon_metres || 15; // Valeur par défaut

    await db.execute(`
      INSERT INTO cours (nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, date_cours, filiere, niveau)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [nom, enseignant_id, salle, latitude, longitude, rayon, heure_debut, heure_fin, date_cours, filiere || null, niveau || null]);

    res.status(201).json({ success: true, message: '✅ Cours créé avec succès' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

// Modifier un cours (admin seulement)
exports.updateCours = async (req, res) => {
  try {
    const { nom, enseignant_id, salle, latitude, longitude, rayon_metres, heure_debut, heure_fin, date_cours, filiere, niveau } = req.body;
    const rayon = rayon_metres || 15;
    
    await db.execute(`
      UPDATE cours 
      SET nom = ?, enseignant_id = ?, salle = ?, latitude = ?, longitude = ?, rayon_metres = ?, heure_debut = ?, heure_fin = ?, date_cours = ?, filiere = ?, niveau = ?, est_archive = FALSE
      WHERE id = ?
    `, [nom, enseignant_id, salle, latitude, longitude, rayon, heure_debut, heure_fin, date_cours, filiere || null, niveau || null, req.params.id]);

    res.json({ success: true, message: '✅ Cours modifié avec succès' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

// Supprimer un cours (admin seulement)
exports.deleteCours = async (req, res) => {
  try {
    await db.execute(`DELETE FROM cours WHERE id = ?`, [req.params.id]);
    res.json({ success: true, message: '✅ Cours supprimé avec succès' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};