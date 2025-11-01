// 📦 config/db.js
const mysql = require('mysql2');

const con = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',        // ถ้ามีรหัสผ่าน MySQL ให้ใส่ตรงนี้
  database: 'bookrent_db'
});