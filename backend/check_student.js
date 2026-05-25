require('dotenv').config();
const db = require('./src/config/db');

async function check() {
  try {
    const [users] = await db.execute('SELECT * FROM utilisateurs WHERE matricule = ?', ['809640']);
    console.log("=== UTILISATEUR ===");
    console.log(users[0]);
    if (users.length > 0) {
      const u = users[0];
      const [cours] = await db.execute('SELECT * FROM cours WHERE (LOWER(filiere) = LOWER(?) OR filiere IS NULL OR filiere = "") AND (niveau = ? OR niveau IS NULL OR niveau = "")', [u.filiere, u.niveau]);
      console.log("=== COURS MATCHING FILIERE/NIVEAU ===");
      console.log(cours);
      
      const [allCours] = await db.execute('SELECT * FROM cours');
      console.log("=== TOUS LES COURS ===");
      console.log(allCours);
    } else {
        console.log("Utilisateur non trouvé !");
    }
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}
check();
