const mysql = require('mysql2/promise');

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

async function migrate() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '3306'),
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
      device_biometric_token VARCHAR(255),
      face_descriptor TEXT,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);
  
  // Update existing table if needed
  try {
    await connection.execute('ALTER TABLE utilisateurs ADD COLUMN device_biometric_token VARCHAR(255)');
    console.log('✅ Colonne device_biometric_token ajoutée');
  } catch (e) {}

  try {
    await connection.execute('ALTER TABLE utilisateurs ADD COLUMN face_descriptor TEXT');
    console.log('✅ Colonne face_descriptor ajoutée');
  } catch (e) {}

  console.log('✅ Table utilisateurs créée');

  // Pour la migration, on vide et supprime les anciennes tables de cours et présences
  await connection.execute(`SET FOREIGN_KEY_CHECKS = 0`);
  await connection.execute(`DROP TABLE IF EXISTS presences_offline`);
  await connection.execute(`DROP TABLE IF EXISTS presences`);
  await connection.execute(`DROP TABLE IF EXISTS cours`);
  await connection.execute(`SET FOREIGN_KEY_CHECKS = 1`);

  await connection.execute(`
    CREATE TABLE cours (
      id INT AUTO_INCREMENT PRIMARY KEY,
      nom VARCHAR(150) NOT NULL,
      enseignant_id INT NOT NULL,
      salle VARCHAR(50) NOT NULL,
      latitude DECIMAL(10, 8) NOT NULL,
      longitude DECIMAL(11, 8) NOT NULL,
      rayon_metres INT DEFAULT 15,
      heure_debut TIME NOT NULL,
      heure_fin TIME NOT NULL,
      date_cours DATE NOT NULL,
      filiere VARCHAR(100),
      niveau VARCHAR(50),
      est_archive BOOLEAN DEFAULT FALSE,
      FOREIGN KEY (enseignant_id) REFERENCES utilisateurs(id)
    )
  `);
  console.log('✅ Table cours recréée avec date_cours et est_archive');

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