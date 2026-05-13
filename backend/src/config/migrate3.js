const mysql = require('mysql2/promise');

if (process.env.NODE_ENV !== 'production') {
  require('dotenv').config();
}

async function migrate3() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '3306'),
  });

  console.log('✅ Connexion MySQL ok, migration 3 en cours...');

  try {
    await connection.execute(`
      ALTER TABLE cours ADD COLUMN filiere VARCHAR(100) NULL
    `);
    console.log('✅ Colonne filiere ajoutée à la table cours');
  } catch (e) {
    console.log('⚠️ Colonne filiere existe déjà dans cours');
  }

  try {
    await connection.execute(`
      ALTER TABLE cours ADD COLUMN niveau VARCHAR(50) NULL
    `);
    console.log('✅ Colonne niveau ajoutée à la table cours');
  } catch (e) {
    console.log('⚠️ Colonne niveau existe déjà dans cours');
  }

  await connection.end();
  console.log('🎉 Migration 3 terminée avec succès !');
}

migrate3().catch(console.error);
