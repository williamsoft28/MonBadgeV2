const db = require('./src/config/db');

async function check() {
  try {
    const [user] = await db.execute('SELECT * FROM utilisateurs WHERE matricule = ?', ['809107']);
    console.log('--- ETUDIANT (809107) ---');
    console.log(user[0] || 'Utilisateur non trouvé');

    const [cours] = await db.execute('SELECT * FROM cours WHERE date_cours = CURDATE()');
    console.log('\n--- COURS DU JOUR (Aujourd\'hui) ---');
    console.log(cours.length > 0 ? cours : 'Aucun cours trouvé pour aujourd\'hui');

  } catch (e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}

check();
