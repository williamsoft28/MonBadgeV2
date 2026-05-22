const mysql = require('mysql2');
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'monbadge_db'
});

pool.promise().query("ALTER TABLE utilisateurs ADD COLUMN matiere VARCHAR(255) NULL;")
  .then(() => {
    console.log("Table altered successfully.");
    process.exit(0);
  })
  .catch(err => {
    if (err.code === 'ER_DUP_FIELDNAME') {
      console.log("Field already exists.");
      process.exit(0);
    }
    console.error(err);
    process.exit(1);
  });
