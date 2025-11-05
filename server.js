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

// 🔹 API: Get user by ID
app.get("/user/:id", (req, res) => {
  const userId = req.params.id;
  const sql = "SELECT id, username, email, role FROM users WHERE id = ?";
  db.query(sql, [userId], (err, results) => {
    if (err) {
      console.error("Error fetching user:", err);
      return res.status(500).json({ message: "Database error" });
    }
    if (results.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(results[0]);
  });
});


// ---------------- BOOKS -------------------
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

// 🌐 Borrow API — insert + update status
app.post('/borrow', (req, res) => {
  const { userId, bookId } = req.body;

  if (!userId || !bookId) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  // 1️⃣ เพิ่มข้อมูลลงตาราง borrowings
  const insertBorrow = `
    INSERT INTO borrowings (user_id, book_id, status, borrow_date, return_date)
    VALUES (?, ?, 'pending', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY))
  `;

  db.query(insertBorrow, [userId, bookId], (err, result) => {
    if (err) {
      console.error('❌ Error inserting borrow:', err);
      return res.status(500).json({ message: 'Borrow failed', error: err });
    }

    // 2️⃣ อัปเดตสถานะหนังสือให้เป็น "pending"
    const updateBook = `UPDATE books SET status = 'pending' WHERE id = ?`;
    db.query(updateBook, [bookId], (err2) => {
      if (err2) {
        console.error('❌ Error updating book status:', err2);
        return res.status(500).json({ message: 'Book update failed' });
      }

      console.log(`✅ User ${userId} borrowed book ${bookId} -> status updated`);
      res.json({ message: 'Borrow success and book status updated' });
    });
  });
});

// ✅ Approve borrow request (for staff/admin)
app.put('/approve/:id', (req, res) => {
  const borrowId = req.params.id;
  const approverId = req.body.approverId || null; // optional

  // 1️⃣ อัปเดต borrowings เป็น borrowed
  const updateBorrow = `
    UPDATE borrowings 
    SET status = 'borrowed', approval_status = 'approved', approved_by = ?, borrow_date = NOW()
    WHERE id = ? AND status = 'pending'
  `;

  db.query(updateBorrow, [approverId, borrowId], (err, result) => {
    if (err) {
      console.error('❌ Error updating borrow status:', err);
      return res.status(500).json({ message: 'Update failed' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'No pending request found' });
    }

    // 2️⃣ ดึง book_id เพื่ออัปเดตตาราง books
    db.query('SELECT book_id FROM borrowings WHERE id = ?', [borrowId], (err2, rows) => {
      if (err2 || rows.length === 0) {
        console.error('❌ Error fetching book_id:', err2);
        return res.status(500).json({ message: 'Book fetch failed' });
      }

      const bookId = rows[0].book_id;

      // 3️⃣ อัปเดตสถานะหนังสือให้เป็น borrowed
      db.query('UPDATE books SET status = "borrowed" WHERE id = ?', [bookId], (err3) => {
        if (err3) {
          console.error('❌ Error updating book status:', err3);
          return res.status(500).json({ message: 'Book status update failed' });
        }

        console.log(`✅ Borrow ${borrowId} approved -> book ${bookId} borrowed`);
        res.json({ message: 'Borrow request approved successfully' });
      });
    });
  });
});

// ---------------- BORROW STATUS ----------------
app.get('/borrow/:userId', (req, res) => {
  const { userId } = req.params;
  const sql = `
    SELECT 
      br.id AS id,           
      br.book_id, 
      br.status, 
      br.borrow_date, 
      br.return_date,
      b.title, 
      b.image
    FROM borrowings br
    JOIN books b ON br.book_id = b.id
    WHERE br.user_id = ? AND br.status NOT IN ('returned', 'rejected')
    ORDER BY br.borrow_date DESC
  `;
  db.query(sql, [userId], (err, rows) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: 'Database error' });
    }
    res.json(rows);
  });
});


// ---------------- RETURN / CANCEL ----------------
app.put('/return/:id', (req, res) => {
  const borrowId = req.params.id;
  const newStatus = (req.body.status || '').toLowerCase().trim();
  const approvalStatus = req.body.approval_status || null;

  const selectSql = 'SELECT book_id, status FROM borrowings WHERE id = ?';
  db.query(selectSql, [borrowId], (err, results) => {
    if (err) {
      console.error('Error selecting borrow:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    const borrowRow = results[0];
    if (!borrowRow) {
      return res.status(404).json({ message: 'Borrow record not found' });
    }

    const currentStatus = borrowRow.status.toLowerCase();

    if (newStatus === 'rejected' && currentStatus !== 'pending') {
      return res.status(400).json({ message: 'Cannot cancel non-pending request' });
    }

    if (newStatus === 'returned' && currentStatus !== 'borrowed') {
      return res.status(400).json({ message: 'Cannot return non-borrowed book' });
    }

    let updateSql = '';
    let updateParams = [];

    if (newStatus === 'returned') {
      updateSql = `
        UPDATE borrowings 
        SET status = ?, approval_status = 'approved', return_date = NOW()
        WHERE id = ?
      `;
      updateParams = [newStatus, borrowId];
    } else if (newStatus === 'rejected') {
      updateSql = 'UPDATE borrowings SET status = ?, approval_status = ? WHERE id = ?';
      updateParams = [newStatus, approvalStatus, borrowId];
    }

    db.query(updateSql, updateParams, (err2) => {
      if (err2) {
        console.error('Error updating return status:', err2);
        return res.status(500).json({ message: 'Update failed' });
      }

      // ✅ คืนหนังสือให้ available ทั้งตอน rejected และ returned
      if (newStatus === 'rejected' || newStatus === 'returned') {
        db.query('UPDATE books SET status = "available" WHERE id = ?', [borrowRow.book_id]);
      }

      console.log(`Borrow ID ${borrowId} updated to ${newStatus}`);
      res.json({ message: `Status updated to ${newStatus}` });
    });
  });
});

// === API: Borrow History (MySQL version) ===
app.get('/api/history/:studentId', (req, res) => {
  const { studentId } = req.params;
  console.log(`📚 Fetching history for student ID: ${studentId}`);

  const sql = `
    SELECT 
      b.title AS book,
      br.borrow_date,
      br.return_date,
      COALESCE(a.username, '-') AS approver,
      COALESCE(r.username, '-') AS receiver,
      br.STATUS AS status,
      b.image
    FROM borrowings br
    JOIN books b ON br.book_id = b.id
    LEFT JOIN users a ON br.approved_by = a.id
    LEFT JOIN users r ON br.received_by = r.id
    WHERE br.user_id = ?
    ORDER BY br.borrow_date DESC
  `;

  db.query(sql, [studentId], (err, rows) => {
    if (err) {
      console.error('❌ Error fetching borrow history:', err);
      return res.status(500).json({ message: 'Error fetching borrow history' });
    }

    if (rows.length === 0) {
      return res.json([]); // ไม่มีข้อมูล
    }

    const BASE_URL = 'http://192.168.49.1:3000'; // ✅ ใช้ IP ของเครื่อง Mochi
    const formatted = rows.map(item => ({
      book: item.book,
      borrow_date: item.borrow_date
        ? new Date(item.borrow_date).toLocaleDateString('th-TH')
        : '-',
      return_date: item.return_date
        ? new Date(item.return_date).toLocaleDateString('th-TH')
        : '-',
      approver: item.approver,
      receiver: item.receiver,
      status: item.status || 'pending',
      image: `${BASE_URL}/public/images/${item.image || 'default.png'}`
    }));

    res.json(formatted);
  });
});

app.listen(3000, () => {
  console.log("🚀 Server running on port 3000");
});
