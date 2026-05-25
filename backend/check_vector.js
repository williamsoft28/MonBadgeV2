require('dotenv').config();
const db = require('./src/config/db');

async function check() {
  try {
    const [users] = await db.execute('SELECT face_descriptor FROM utilisateurs WHERE matricule = ?', ['809640']);
    if (users.length > 0 && users[0].face_descriptor) {
      const desc = JSON.parse(users[0].face_descriptor);
      console.log("Vector length:", desc.length);
    } else {
        console.log("No face descriptor found.");
    }
  } catch (err) {
    console.error(err);
  } finally {
    process.exit(0);
  }
}
check();
