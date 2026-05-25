const db = require('./src/config/db');

async function test() {
  try {
    const matricule = '809640';
    console.log('--- 1. Check User ---');
    const [users] = await db.execute('SELECT * FROM utilisateurs WHERE matricule = ?', [matricule]);
    if (users.length === 0) {
      console.log('User not found');
      process.exit(1);
    }
    const user = users[0];
    console.log(user);

    console.log('\n--- 2. Fetch Courses for User ---');
    // We need to see how courses are fetched in coursController.js
    // Let's assume it filters by filiere and niveau
    const [cours] = await db.execute(
      `SELECT c.*, u.nom as enseignant_nom, u.prenom as enseignant_prenom 
       FROM cours c 
       LEFT JOIN utilisateurs u ON c.enseignant_id = u.id 
       WHERE c.filiere = ? AND c.niveau = ? AND c.est_archive = FALSE 
       ORDER BY c.date_cours, c.heure_debut`,
      [user.filiere, user.niveau]
    );
    console.log(`Found ${cours.length} courses:`, cours);

    console.log('\n--- 3. Check Presences ---');
    const [presences] = await db.execute('SELECT * FROM presences WHERE etudiant_id = ?', [user.id]);
    console.log(`Found ${presences.length} presences:`, presences);

  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}
test();
