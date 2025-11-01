const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'bookrent_db'
});

// ✅ เช็กการเชื่อมต่อ DB ทันที
db.connect((err) => {
  if (err) {
    console.error('❌ Database connect failed:', err);
  } else {
    console.log('✅ Connected to MySQL: bookrent_db');
  }
});

// 🔹 Register (เฉพาะ Student)
app.post('/register', (req, res) => {
  const { username, password } = req.body;
  console.log('📥 Register request:', username, password);

  if (!username || !password) {
    return res.status(400).json({ message: 'กรุณากรอกชื่อและรหัสผ่าน' });
  }

  db.query(
    'INSERT INTO users (username, password, role) VALUES (?, ?, 3)',
    [username, password],
    (err, result) => {
      if (err) {
        console.error('❌ Register DB error:', err);
        return res.status(500).json({ message: 'เกิดข้อผิดพลาดในฐานข้อมูล' });
      }
      console.log('✅ Register success:', result.insertId);
      res.json({ message: 'สมัครสำเร็จ', userId: result.insertId });
    }
  );
});

// 🔹 Login (ใช้ร่วมทุก role)
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  console.log('📥 Login attempt:', username, password);

  if (!username || !password) {
    return res.status(400).json({ message: 'Missing username or password' });
  }

  db.query(
    'SELECT * FROM users WHERE username = ? AND password = ?',
    [username, password],
    (err, results) => {
      if (err) {
        console.error('❌ Login DB error:', err);
        return res.status(500).json({ message: 'เกิดข้อผิดพลาดในฐานข้อมูล' });
      }

      console.log('🔍 Query result:', results);

      if (results.length === 0) {
        console.warn('⚠️ ไม่พบข้อมูลผู้ใช้ในฐานข้อมูล');
        return res.status(401).json({ message: 'ชื่อหรือรหัสผ่านไม่ถูกต้อง' });
      }

      const user = results[0];
      console.log('✅ Login success:', user.username, 'Role:', user.role);

      res.json({
        message: 'เข้าสู่ระบบสำเร็จ',
        id: user.id,
        role: user.role,
        username: user.username
      });
    }
  );
});

app.listen(3000, '0.0.0.0', () => 
  console.log('🚀 Server running on http://0.0.0.0:3000')
);
