const db = require('./backend/src/config/db');

async function test() {
  try {
    const [uRows] = await db.execute('SELECT * FROM utilisateurs WHERE matricule = "809640" OR id = 809640 LIMIT 1');
    console.log('Utilisateur:', uRows[0]);
    if(uRows.length > 0) {
      const user = uRows[0];
      const filiere = user.filiere;
      const niveau = user.niveau;
      console.log('Filiere:', filiere, 'Niveau:', niveau);
      
      const [cRows] = await db.execute(`
        SELECT c.*, u.nom AS enseignant_nom, u.prenom AS enseignant_prenom
        FROM cours c
        JOIN utilisateurs u ON c.enseignant_id = u.id
      `);
      console.log('Tous les cours:', cRows);
    }
  } catch(e) {
    console.error(e);
  } finally {
    process.exit(0);
  }
}
test();
