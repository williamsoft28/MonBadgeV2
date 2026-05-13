const db = require('../config/db');

exports.getPresencesReport = async (req, res) => {
  try {
    const { id } = req.params;

    // Verify course exists
    const [cours] = await db.execute('SELECT * FROM cours WHERE id = ?', [id]);
    if (cours.length === 0) {
      return res.status(404).json({ error: 'Cours non trouvé' });
    }

    if (req.user.role === 'enseignant' && cours[0].enseignant_id !== req.user.id) {
      return res.status(403).json({ error: 'Accès refusé' });
    }

    // Get all students matching the course's filiere & niveau
    let queryStudents = 'SELECT id, nom, prenom, matricule FROM utilisateurs WHERE role = "etudiant"';
    let paramsStudents = [];
    if (cours[0].filiere) {
      queryStudents += ' AND filiere = ?';
      paramsStudents.push(cours[0].filiere);
    }
    if (cours[0].niveau) {
      queryStudents += ' AND niveau = ?';
      paramsStudents.push(cours[0].niveau);
    }

    const [etudiants] = await db.execute(queryStudents, paramsStudents);

    // Get all presences for this course
    const [presences] = await db.execute('SELECT etudiant_id, statut, heure_pointage FROM presences WHERE cours_id = ?', [id]);
    const presenceMap = {};
    presences.forEach(p => {
      presenceMap[p.etudiant_id] = p;
    });

    let csv = 'Matricule,Nom,Prenom,Statut,Heure Pointage\n';
    etudiants.forEach(e => {
      const p = presenceMap[e.id];
      const statut = p ? p.statut : 'absent';
      const heure = p ? p.heure_pointage : '-';
      csv += `${e.matricule},${e.nom},${e.prenom},${statut},${heure}\n`;
    });

    res.header('Content-Type', 'text/csv; charset=utf-8');
    res.attachment(`rapport_cours_${id}.csv`);
    return res.send(csv);

  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
