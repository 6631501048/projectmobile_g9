// server.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2');

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(express.json());

// === DB POOL (แก้ database ให้ตรงของมึง) ===
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'bookrent_db',
});

db.connect((err) => {
  if (err) {
    console.error('❌ Database connection failed:', err);
  } else {
    console.log('✅ Connected to MySQL database');
  }
});


// 🔹 API: Register
app.post("/register", (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: "All fields are required" });
  }


  const checkUser = "SELECT * FROM users WHERE username = ? OR email = ?";
  db.query(checkUser, [username, email], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (result.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    const insertUser =
      "INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, 'student')";
    db.query(insertUser, [username, email, password], (err2) => {
      if (err2) {
        console.error(err2);
        return res.status(500).json({ message: "Register failed" });
      }
      res.json({ message: "Registration successful" });
    });
  });
});


// 🔹 API: Login
app.post("/login", (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).json({ message: "Please fill all fields" });
  }

  const sql = "SELECT * FROM users WHERE username = ? AND password = ?";
  db.query(sql, [username, password], (err, results) => {
    if (err) return res.status(500).json({ message: "Server error" });
    if (results.length === 0) {
      return res.status(401).json({ message: "Invalid username or password" });
    }

    const user = results[0];
    res.json({
      id: user.id,
      username: user.username,
      email: user.email,
      role: user.role,
    });
  });
});

// ---------------- BOOKS (สำคัญ) ----------------
app.get('/books', (req, res) => {
  const sql = `
    SELECT 
      id, 
      title, 
      author, 
      category, 
      description, 
      image, 
      STATUS AS status 
    FROM books
  `;

  db.query(sql, (err, results) => {
    if (err) {
      console.error('Error fetching books:', err);
      return res.status(500).json({ message: 'Error fetching books' });
    }
    res.json(results);
  });
});

// 🌐 Example: Borrow
app.post('/borrow', (req, res) => {
  const { userId, bookId } = req.body;
  if (!userId || !bookId) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  // ✅ ใช้ชื่อ table ที่ถูกต้อง
  const sql = 'INSERT INTO borrowings (user_id, book_id) VALUES (?, ?)';

  db.query(sql, [userId, bookId], (err, result) => {
    if (err) {
      console.error('Error inserting borrow:', err);
      return res.status(500).json({ message: 'Borrow failed', error: err });
    }
    res.json({ message: 'Borrow success' });
  });
});
app.listen(3000, () => {
  console.log("🚀 Server running on port 3000");
});
