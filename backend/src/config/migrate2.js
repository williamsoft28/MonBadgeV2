const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate2() {
  const connection = await mysql.createConnection({
    host: process.env.MYSQLHOST || process.env.DB_HOST || 'localhost',
    user: process.env.MYSQLUSER || process.env.DB_USER || 'root',
    password: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '',
    database: process.env.MYSQLDATABASE || process.env.DB_NAME || 'monbadge_db',
    port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306'),
  });

  console.log('✅ Connexion MySQL ok, migration 2 en cours...');

  // Ajout filiere
  try {
    await connection.execute(`
      ALTER TABLE utilisateurs ADD COLUMN filiere VARCHAR(100) NULL
    `);
    console.log('✅ Colonne filiere ajoutée');
  } catch (e) {
    console.log('⚠️ Colonne filiere existe déjà');
  }

  // Ajout niveau
  try {
    await connection.execute(`
      ALTER TABLE utilisateurs ADD COLUMN niveau VARCHAR(50) NULL
    `);
    console.log('✅ Colonne niveau ajoutée');
  } catch (e) {
    console.log('⚠️ Colonne niveau existe déjà');
  }

  // Table attributions
  try {
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS attributions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        enseignant_id INT NOT NULL,
        cours_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (enseignant_id) REFERENCES utilisateurs(id),
        FOREIGN KEY (cours_id) REFERENCES cours(id),
        UNIQUE KEY unique_attribution (enseignant_id, cours_id)
      )
    `);
    console.log('✅ Table attributions créée');
  } catch (e) {
    console.log('⚠️ Table attributions existe déjà');
  }

  // Création compte admin par défaut
  try {
    const bcrypt = require('bcryptjs');
    const hash = await bcrypt.hash('password', 10);
    await connection.execute(`
      INSERT INTO utilisateurs (nom, prenom, matricule, email, mot_de_passe, role)
      VALUES (?, ?, ?, ?, ?, ?)
    `, ['Admin', 'MonBadge', 'ADMIN-001', 'admin@monbadge.com', hash, 'admin']);
    console.log('✅ Compte admin créé');
  } catch (e) {
    console.log('⚠️ Compte admin existe déjà');
  }

  await connection.end();
  console.log('🎉 Migration 2 terminée avec succès !');
}

migrate2().catch(console.error);