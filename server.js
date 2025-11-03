import express from "express";
import mysql from "mysql2";
import cors from "cors";
import bodyParser from "body-parser";

const app = express();
app.use(cors());
app.use(bodyParser.json());

// ✅ เชื่อมต่อ MySQL
const db = mysql.createConnection({
  host: "localhost",
  user: "root",
  password: "",
  database: "bookrent_db"
});

db.connect((err) => {
  if (err) {
    console.error("Database connection failed:", err);
  } else {
    console.log("✅ Connected to MySQL bookrent_db");
  }
});

// 🔹 API: Register (เฉพาะ Student)
// 🔹 API: Register (เฉพาะ Student)
app.post("/register", (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).json({ message: "All fields are required" });
  }

  // ตรวจ username หรือ email ซ้ำ
  const checkUser = "SELECT * FROM users WHERE username = ? OR email = ?";
  db.query(checkUser, [username, email], (err, result) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (result.length > 0) {
      return res.status(400).json({ message: "Username or email already exists" });
    }

    // ✅ Insert ปลอดภัย
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
      role: user.role,
    });
  });
});

app.listen(3000, () => {
  console.log("🚀 Server running on port 3000");
});
