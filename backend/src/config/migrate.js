const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
  const connection = await mysql.createConnection({
    host: process.env.MYSQLHOST || process.env.DB_HOST,
    user: process.env.MYSQLUSER || process.env.DB_USER,
    password: process.env.MYSQLPASSWORD || process.env.DB_PASSWORD || '',
    database: process.env.MYSQLDATABASE || process.env.DB_NAME,
    port: parseInt(process.env.MYSQLPORT || process.env.DB_PORT || '3306'),
  });

  console.log('✅ Connexion MySQL ok, migration en cours...');

  await connection.execute(`
    CREATE TABLE IF NOT EXISTS utilisateurs (
      id INT AUTO_INCREMENT PRIMARY KEY,
      nom VARCHAR(100) NOT NULL,
      prenom VARCHAR(100) NOT NULL,
      matricule VARCHAR(50) UNIQUE NOT NULL,
      email VARCHAR(150) UNIQUE NOT NULL,
      mot_de_passe VARCHAR(255) NOT NULL,
      role ENUM('etudiant', 'enseignant', 'admin') NOT NULL,
      biometrie_enregistree BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  console.log('✅ Table utilisateurs créée');

  await connection.execute(`
    CREATE TABLE IF NOT EXISTS cours (
      id INT AUTO_INCREMENT PRIMARY KEY,
      nom VARCHAR(150) NOT NULL,
      enseignant_id INT NOT NULL,
      salle VARCHAR(50) NOT NULL,
      latitude DECIMAL(10, 8) NOT NULL,
      longitude DECIMAL(11, 8) NOT NULL,
      rayon_metres INT DEFAULT 15,
      heure_debut TIME NOT NULL,
      heure_fin TIME NOT NULL,
      jour ENUM('Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi') NOT NULL,
      FOREIGN KEY (enseignant_id) REFERENCES utilisateurs(id)
    )
  `);
  console.log('✅ Table cours créée');

  await connection.execute(`
    CREATE TABLE IF NOT EXISTS presences (
      id INT AUTO_INCREMENT PRIMARY KEY,
      etudiant_id INT NOT NULL,
      cours_id INT NOT NULL,
      date DATE NOT NULL,
      heure_pointage TIME NOT NULL,
      statut ENUM('present', 'absent', 'retard') DEFAULT 'present',
      latitude DECIMAL(10, 8),
      longitude DECIMAL(11, 8),
      biometrie_validee BOOLEAN DEFAULT FALSE,
      sync_serveur BOOLEAN DEFAULT TRUE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (etudiant_id) REFERENCES utilisateurs(id),
      FOREIGN KEY (cours_id) REFERENCES cours(id)
    )
  `);
  console.log('✅ Table presences créée');

  await connection.execute(`
    CREATE TABLE IF NOT EXISTS presences_offline (
      id INT AUTO_INCREMENT PRIMARY KEY,
      etudiant_id INT NOT NULL,
      cours_id INT NOT NULL,
      date DATE NOT NULL,
      heure_pointage TIME NOT NULL,
      latitude DECIMAL(10, 8),
      longitude DECIMAL(11, 8),
      biometrie_validee BOOLEAN DEFAULT FALSE,
      sync_serveur BOOLEAN DEFAULT FALSE,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (etudiant_id) REFERENCES utilisateurs(id),
      FOREIGN KEY (cours_id) REFERENCES cours(id)
    )
  `);
  console.log('✅ Table presences_offline créée');

  await connection.end();
  console.log('🎉 Migration terminée avec succès !');
}

migrate().catch(console.error);