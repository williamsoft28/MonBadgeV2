const db = require('../config/db');
const faceService = require('../services/faceService');

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

    // Vérifier le Timing (Verrouillage du cours)
    // cours[0].date_cours est un objet Date MySQL, on prend sa string (ex: '2026-05-13')
    // Pour être sûr du format :
    const d = new Date(cours[0].date_cours);
    const dateStr = `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    
    const timeDebut = new Date(`${dateStr}T${cours[0].heure_debut}`);
    const timeFin = new Date(`${dateStr}T${cours[0].heure_fin}`);
    const now = new Date();

    const windowStart = new Date(timeDebut.getTime() - 10 * 60000); // 10 min avant
    const windowEnd = new Date(timeFin.getTime() + 10 * 60000);   // 10 min après la fin

    if (now < windowStart) {
      return res.status(403).json({ error: "❌ Le cours n'a pas encore commencé. (Prise de présence ouverte 10min avant)." });
    }
    if (now > windowEnd) {
      return res.status(403).json({ error: "❌ Le cours est verrouillé (terminé)." });
    }

    // Statut : retard si > heure_debut + 10 mins
    const limitRetard = new Date(timeDebut.getTime() + 10 * 60000);
    let statut = 'present';
    if (now > limitRetard) {
      statut = 'retard';
    }

    // Vérifier biométrie via reconnaissance faciale
    const { faceImageBase64 } = req.body;
    if (!faceImageBase64) {
      return res.status(403).json({ error: '❌ Image du visage requise pour la présence' });
    }

    const [uRows] = await db.execute('SELECT face_descriptor FROM utilisateurs WHERE id = ?', [etudiant_id]);
    if (uRows.length === 0 || !uRows[0].face_descriptor) {
      return res.status(403).json({ error: '❌ Visage non enregistré. Veuillez reconfigurer votre biométrie.' });
    }

    const savedDescriptorStr = uRows[0].face_descriptor;
    const savedDescriptor = new Float32Array(JSON.parse(savedDescriptorStr));

    const currentDescriptor = await faceService.getFaceDescriptor(faceImageBase64);
    if (!currentDescriptor) {
      return res.status(403).json({ error: '❌ Impossible de détecter un visage sur la photo fournie.' });
    }

    const faceDistance = faceService.compareFaces(savedDescriptor, currentDescriptor);
    if (faceDistance > 0.6) {
      return res.status(403).json({ error: '❌ Visage non reconnu ou différent de celui enregistré.' });
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
       (etudiant_id, cours_id, date, heure_pointage, latitude, longitude, biometrie_validee, statut)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [etudiant_id, cours_id, today, heure, latitude, longitude, biometrie_validee, statut]
    );

    res.status(201).json({ message: `✅ Présence enregistrée avec succès (${statut})` });

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
      if (p.faceImageBase64) {
        const [uRows] = await db.execute('SELECT face_descriptor FROM utilisateurs WHERE id = ?', [p.etudiant_id]);
        if (uRows.length > 0 && uRows[0].face_descriptor) {
          const savedDescriptor = new Float32Array(JSON.parse(uRows[0].face_descriptor));
          const currentDescriptor = await faceService.getFaceDescriptor(p.faceImageBase64);
          
          if (!currentDescriptor || faceService.compareFaces(savedDescriptor, currentDescriptor) > 0.6) {
            continue; // skip invalid face presence
          }
        } else {
          continue; // no face registered
        }
      } else {
        continue; // reject offline without face proof for now to ensure security
      }

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

exports.getStats = async (req, res) => {
  try {
    if (req.user.role === 'etudiant') {
      const [[{ total_presences }]] = await db.execute(
        `SELECT COUNT(*) as total_presences FROM presences WHERE etudiant_id = ?`, 
        [req.user.id]
      );
      
      let filiere = req.user.filiere;
      let niveau = req.user.niveau;
      if (!filiere || !niveau) {
        const [uRows] = await db.execute('SELECT filiere, niveau FROM utilisateurs WHERE id = ?', [req.user.id]);
        if (uRows.length > 0) {
          filiere = uRows[0].filiere;
          niveau = uRows[0].niveau;
        }
      }

      let coursQuery = `SELECT COUNT(*) as total_cours FROM cours WHERE 1=1`;
      let params = [];
      if (filiere && niveau) {
        coursQuery += ` AND (LOWER(filiere) = LOWER(?) OR filiere IS NULL OR filiere = '') AND (niveau = ? OR niveau IS NULL OR niveau = '')`;
        params.push(filiere, niveau);
      }
      
      const [[{ total_cours }]] = await db.execute(coursQuery, params);

      const absences = total_cours - total_presences > 0 ? total_cours - total_presences : 0;
      const taux = total_cours > 0 ? Math.round((total_presences / total_cours) * 100) : 0;

      res.json({ presences: total_presences, absences, taux: `${taux}%` });
    } else {
      const [[{ total_presences }]] = await db.execute(
        `SELECT COUNT(*) as total_presences FROM presences p JOIN cours c ON p.cours_id = c.id WHERE c.enseignant_id = ?`,
        [req.user.id]
      );
      res.json({ presences: total_presences, absences: 0, taux: 'N/A' });
    }
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