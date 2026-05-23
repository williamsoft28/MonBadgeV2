const mysql = require('mysql2/promise');

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

async function migrate4() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '3306'),
  });

  console.log('✅ Connexion MySQL ok, migration 4 (face_features) en cours...');

  try {
    await connection.execute(`
      ALTER TABLE utilisateurs ADD COLUMN face_features TEXT NULL
    `);
    console.log('✅ Colonne face_features ajoutée à utilisateurs');
  } catch (e) {
    console.log('⚠️ Colonne face_features existe déjà');
  }

  await connection.end();
  console.log('🎉 Migration 4 terminée avec succès !');
}

migrate4().catch(console.error);
