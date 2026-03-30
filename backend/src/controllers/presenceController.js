const db = require('../config/db');

// Pointer présence
exports.pointerPresence = async (req, res) => {
  try {
    const { cours_id, latitude, longitude, biometrie_validee } = req.body;
    const etudiant_id = req.user.id;

    // Vérifier que le cours existe
    const [cours] = await db.execute(
      `SELECT * FROM cours WHERE id = ?`, [cours_id]
    );

    if (cours.length === 0) {
      return res.status(404).json({ error: '❌ Cours non trouvé' });
    }

    // Vérifier la géolocalisation
    const distance = calculerDistance(
      latitude, longitude,
      cours[0].latitude, cours[0].longitude
    );

    if (distance > cours[0].rayon_metres) {
      return res.status(403).json({ 
        error: `❌ Vous êtes trop loin de la salle (${Math.round(distance)}m)` 
      });
    }

    // Vérifier biométrie
    if (!biometrie_validee) {
      return res.status(403).json({ error: '❌ Biométrie non validée' });
    }

    // Vérifier si déjà pointé aujourd'hui
    const today = new Date().toISOString().split('T')[0];
    const [dejaPoi] = await db.execute(
      `SELECT * FROM presences 
       WHERE etudiant_id = ? AND cours_id = ? AND date = ?`,
      [etudiant_id, cours_id, today]
    );

    if (dejaPoi.length > 0) {
      return res.status(409).json({ error: '❌ Présence déjà enregistrée' });
    }

    // Enregistrer la présence
    const heure = new Date().toTimeString().split(' ')[0];
    await db.execute(
      `INSERT INTO presences 
       (etudiant_id, cours_id, date, heure_pointage, latitude, longitude, biometrie_validee)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [etudiant_id, cours_id, today, heure, latitude, longitude, biometrie_validee]
    );

    res.status(201).json({ message: '✅ Présence enregistrée avec succès' });

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Historique des présences d'un étudiant
exports.getHistorique = async (req, res) => {
  try {
    const etudiant_id = req.user.id;

    const [rows] = await db.execute(`
      SELECT p.*, c.nom as cours_nom, c.salle
      FROM presences p
      JOIN cours c ON p.cours_id = c.id
      WHERE p.etudiant_id = ?
      ORDER BY p.date DESC
    `, [etudiant_id]);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Liste présences d'un cours (enseignant/admin)
exports.getPresencesCours = async (req, res) => {
  try {
    const [rows] = await db.execute(`
      SELECT p.*, u.nom, u.prenom, u.matricule
      FROM presences p
      JOIN utilisateurs u ON p.etudiant_id = u.id
      WHERE p.cours_id = ?
      ORDER BY p.heure_pointage ASC
    `, [req.params.cours_id]);

    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Sync offline
exports.syncOffline = async (req, res) => {
  try {
    const { presences } = req.body;
    let synced = 0;

    for (const p of presences) {
      const [existe] = await db.execute(
        `SELECT * FROM presences 
         WHERE etudiant_id = ? AND cours_id = ? AND date = ?`,
        [p.etudiant_id, p.cours_id, p.date]
      );

      if (existe.length === 0) {
        await db.execute(
          `INSERT INTO presences 
           (etudiant_id, cours_id, date, heure_pointage, latitude, longitude, biometrie_validee, sync_serveur)
           VALUES (?, ?, ?, ?, ?, ?, ?, true)`,
          [p.etudiant_id, p.cours_id, p.date, p.heure_pointage, p.latitude, p.longitude, p.biometrie_validee]
        );
        synced++;
      }
    }

    res.json({ message: `✅ ${synced} présence(s) synchronisée(s)` });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

// Calcul distance GPS en mètres
function calculerDistance(lat1, lon1, lat2, lon2) {
  const R = 6371000;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
            Math.sin(dLon/2) * Math.sin(dLon/2);
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
}