const mysql = require('mysql2');
require('dotenv').config();

const pool = mysql.createPool(
  process.env.MYSQL_URL || process.env.MYSQL_PRIVATE_URL || {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: parseInt(process.env.DB_PORT || '3306'),
    waitForConnections: true,
    connectionLimit: 10,
  }
);

pool.getConnection((err, connection) => {
  if (err) {
    console.error('❌ Erreur connexion MySQL:', err.message);
  } else {
    console.log('✅ MySQL connecté avec succès !');
    connection.release();
  }
});

module.exports = pool.promise();