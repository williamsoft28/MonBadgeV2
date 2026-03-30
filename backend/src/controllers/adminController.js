const db = require('../config/db');

// Dashboard stats
exports.getStats = async (req, res) => {
  try {
    const [totalEtudiants] = await db.execute(
      `SELECT COUNT(*) as total FROM utilisateurs WHERE role = 'etudiant'`
    );

    const [totalCours] = await db.execute(
      `SELECT COUNT(*) as total FROM cours`
    );

    const [totalPresences] = await db.execute(
      `SELECT COUNT(*) as total FROM presences`
    );

    const [presencesAujourdhui] = await db.execute(
      `SELECT COUNT(*) as total FROM presences WHERE date = CURDATE()`
    );

    const [tauxPresence] = await db.execute(`
      SELECT 
        ROUND(COUNT(*) * 100.0 / (
          SELECT COUNT(*) FROM utilisateurs WHERE role = 'etudiant'
        ), 2) as taux
      FROM presences 
      WHERE date = CURDATE()
    `);

    res.json({
      total_etudiants: totalEtudiants[0].total,
      total_cours: totalCours[0].total,
      total_presences: totalPresences[0].total,
      presences_aujourdhui: presencesAujourdhui[0].total,
      taux_presence_aujourdhui: tauxPresence[0].taux || 0,
    });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Liste tous les utilisateurs
exports.getAllUsers = async (req, res) => {
  try {
    const [rows] = await db.execute(
      `SELECT id, nom, prenom, matricule, email, role, 
              biometrie_enregistree, created_at 
       FROM utilisateurs
       ORDER BY created_at DESC`
    );
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Supprimer un utilisateur
exports.deleteUser = async (req, res) => {
  try {
    await db.execute(
      `DELETE FROM utilisateurs WHERE id = ?`, [req.params.id]
    );
    res.json({ message: '✅ Utilisateur supprimé' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Rapport présences par cours
exports.getRapportCours = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT 
        c.nom as cours,
        c.salle,
        COUNT(p.id) as total_presences,
        COUNT(DISTINCT p.etudiant_id) as etudiants_presents,
        p.date
      FROM presences p
      JOIN cours c ON p.cours_id = c.id
      GROUP BY c.id, p.date
      ORDER BY p.date DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Rapport absences par étudiant
exports.getAbsencesEtudiant = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT 
        u.nom, u.prenom, u.matricule,
        COUNT(p.id) as total_presences,
        (SELECT COUNT(*) FROM cours) as total_cours,
        ROUND(COUNT(p.id) * 100.0 / (SELECT COUNT(*) FROM cours), 2) as taux
      FROM utilisateurs u
      LEFT JOIN presences p ON u.id = p.etudiant_id
      WHERE u.role = 'etudiant'
      GROUP BY u.id
      ORDER BY taux ASC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};