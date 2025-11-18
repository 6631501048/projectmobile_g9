// server.js
require('dotenv').config();
const BASE_URL = process.env.BASE_URL;

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

// ---------------- BOOK DETAIL ----------------
app.get('/books/:id', (req, res) => {
  const id = req.params.id;
  const sql = `
    SELECT 
      id, title, author, description, image, STATUS AS status
    FROM books
    WHERE id = ?
  `;

  db.query(sql, [id], (err, results) => {
    if (err) {
      console.error('❌ Error fetching book:', err);
      return res.status(500).json({ message: 'DB error' });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'Book not found' });
    }

    res.json(results[0]);
  });
});

app.post('/borrow', (req, res) => {
  const { userId, bookId, borrowDate, returnDate } = req.body;

  if (!userId || !bookId || !borrowDate || !returnDate) {
    return res.status(400).json({ message: 'Missing fields' });
  }

  const sql = `
    INSERT INTO borrowings (user_id, book_id, status, borrow_date, return_date)
    VALUES (?, ?, 'pending', ?, ?)
  `;

  db.query(sql, [userId, bookId, borrowDate, returnDate], (err, result) => {
    if (err) {
      console.error('❌ Error inserting borrow:', err);
      return res.status(500).json({ message: 'Borrow failed', error: err });
    }

    db.query('UPDATE books SET status = "pending" WHERE id = ?', [bookId], (err2) => {
      if (err2) {
        console.error('❌ Error updating book status:', err2);
        return res.status(500).json({ message: 'Book update failed' });
      }

      console.log(`✅ User ${userId} borrowed book ${bookId}`);
      res.json({ message: 'Borrow success and book status updated' });
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
      updateSql = `
        UPDATE borrowings 
        SET status = ?, 
            approval_status = ?, 
            reject_reason = ?, 
            approved_by = ?
        WHERE id = ?
      `;
      updateParams = [
        newStatus,
        approvalStatus,
        req.body.reject_reason || "-",
        approved_by = req.body.approverId || null,
        borrowId
      ];
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

  const sql = `
    SELECT 
      b.title AS book,
      br.borrow_date,
      br.return_date,
      COALESCE(a.username, '-') AS approver,
      COALESCE(r.username, '-') AS receiver,
      br.status,
      br.reject_reason,
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

    const formatted = rows.map(item => ({
      book: item.book,
      borrow_date: item.borrow_date
        ? new Date(item.borrow_date).toLocaleDateString('th-TH') : '-',
      return_date: item.return_date
        ? new Date(item.return_date).toLocaleDateString('th-TH') : '-',
      approver: item.approver,
      receiver: item.receiver,
      reject_reason: item.reject_reason || "-",
      status: item.status,
      image: `${BASE_URL}/images/${item.image || 'default.png'}`
    }));

    res.json(formatted);
  });
});

// ---------------- DELETE / CANCEL BORROW ----------------
app.delete('/borrow/:id', (req, res) => {
  const borrowId = req.params.id;

  db.query('SELECT book_id, status FROM borrowings WHERE id = ?', [borrowId], (err, results) => {
    if (err) {
      console.error('Error selecting borrow:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    if (results.length === 0) {
      return res.status(404).json({ message: 'Borrow record not found' });
    }

    const borrowRow = results[0];

    db.query('DELETE FROM borrowings WHERE id = ?', [borrowId], (err2, result) => {
      if (err2) {
        console.error('Error deleting borrow:', err2);
        return res.status(500).json({ message: 'Delete failed' });
      }

      db.query('UPDATE books SET status = "available" WHERE id = ?', [borrowRow.book_id], (err3) => {
        if (err3) console.error('Error updating book status:', err3);

        console.log(`Borrow ID ${borrowId} deleted and book ${borrowRow.book_id} set to available`);
        res.json({ message: 'Borrow cancelled and deleted successfully' });
      });
    });
  });
});

// ===================== STAFF =====================
// ---------------- ADD NEW BOOK ----------------
app.post('/books/add', (req, res) => {
  const { title, author, description, image, status } = req.body;
  if (!title) return res.status(400).json({ message: 'Title is required' });

  const sql = `
    INSERT INTO books (title, author, description, image, STATUS)
    VALUES (?, ?, ?, ?, ?)
  `;
  db.query(
    sql,
    [title, author, description, image || 'default.png', status || 'available'],
    (err, result) => {
      if (err) {
        console.error('❌ Error adding book:', err);
        return res.status(500).json({ message: 'Failed to add book' });
      }
      res.json({ message: 'Book added successfully', id: result.insertId });
    }
  );
});

// ---------------- UPDATE BOOK ----------------
app.put('/books/:id', (req, res) => {
  const { id } = req.params;
  const { title, author, description, status } = req.body;
  const sql = `
    UPDATE books
    SET title = ?, author = ?, description = ?, STATUS = ?
    WHERE id = ?
  `;
  db.query(sql, [title, author, description, status, id], (err) => {
    if (err) {
      console.error('❌ Error updating book:', err);
      return res.status(500).json({ message: 'Update failed' });
    }
    res.json({ message: 'Book updated successfully' });
  });
});

// ---------------- DELETE BOOK ----------------
app.delete('/books/:id', (req, res) => {
  const { id } = req.params;
  const sql = 'DELETE FROM books WHERE id = ?';
  db.query(sql, [id], (err, result) => {
    if (err) {
      console.error('❌ Error deleting book:', err);
      return res.status(500).json({ message: 'Delete failed' });
    }
    if (result.affectedRows === 0)
      return res.status(404).json({ message: 'Book not found' });
    res.json({ message: 'Book deleted successfully' });
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

// ✅ patch status
app.patch('/books/:id/status', (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  const sql = 'UPDATE books SET STATUS = ? WHERE id = ?';
  db.query(sql, [status, id], (err, result) => {
    if (err) return res.status(500).json({ message: 'Database error' });
    res.json({ message: `Book status updated to ${status}` });
  });
});

// ✅ API: Dashboard summary
app.get("/api/dashboard/summary", (req, res) => {
  const sql = `
    SELECT 
      SUM(CASE WHEN STATUS = 'available' THEN 1 ELSE 0 END) AS available,
      SUM(CASE WHEN STATUS = 'borrowed' THEN 1 ELSE 0 END) AS borrowed,
      SUM(CASE WHEN STATUS = 'pending' THEN 1 ELSE 0 END) AS pending,
      SUM(CASE WHEN STATUS = 'disabled' THEN 1 ELSE 0 END) AS disabled,
      COUNT(*) AS total
    FROM books;
  `;

  db.query(sql, (err, result) => {
    if (err) {
      console.error("❌ Error fetching dashboard summary:", err);
      return res.status(500).json({ message: "Database error" });
    }

    const row = result && result.length > 0 ? result[0] : {};

    // ✅ แปลงค่าทั้งหมดเป็น number ด้วย Number()
    res.json({
      available: Number(row.available) || 0,
      borrowed: Number(row.borrowed) || 0,
      pending: Number(row.pending) || 0,
      disabled: Number(row.disabled) || 0,
      total: Number(row.total) || 1,
    });
  });
});

// ✅ API: Staff Borrow History (ดูทุกการยืมคืน)
app.get('/api/staff/history', (req, res) => {
  const sql = `
    SELECT 
      br.id AS borrow_id,
      b.title AS book,
      br.borrow_date,
      br.return_date,
      u.username AS borrower,
      COALESCE(a.username, '-') AS approver,
      COALESCE(r.username, '-') AS receiver,
      br.status AS status,
      br.reject_reason,
      b.image
    FROM borrowings br
    JOIN books b ON br.book_id = b.id
    JOIN users u ON br.user_id = u.id
    LEFT JOIN users a ON br.approved_by = a.id
    LEFT JOIN users r ON br.received_by = r.id
    ORDER BY br.borrow_date DESC
  `;

  db.query(sql, (err, rows) => {
    if (err) {
      console.error('❌ Error fetching staff history:', err);
      return res.status(500).json({ message: 'Error fetching staff history' });
    }

    const formatted = rows.map(item => ({
      id: item.borrow_id,
      book: item.book,
      borrower: item.borrower,
      borrowDate: item.borrow_date
        ? new Date(item.borrow_date).toLocaleDateString('th-TH')
        : '-',
      returnDate: item.return_date
        ? new Date(item.return_date).toLocaleDateString('th-TH')
        : '-',
      approver: item.approver,
      receiver: item.receiver,
      status: item.status,
      reject_reason: item.reject_reason || "-",
      image: `${BASE_URL}/images/${item.image || 'default.png'}`
    }));

    res.json(formatted);
  });
});

// ✅ API: Get return list (pending/borrowed)
app.get('/api/staff/getreturn', (req, res) => {
  const sql = `
    SELECT 
      br.id AS borrow_id,
      u.username AS borrower,
      b.title AS book,
      br.borrow_date,
      br.return_date,
      br.status,
      br.reject_reason,
      b.image
    FROM borrowings br
    JOIN users u ON br.user_id = u.id
    JOIN books b ON br.book_id = b.id
    WHERE br.status IN ('pending', 'borrowed')
    ORDER BY br.borrow_date DESC
  `;

  db.query(sql, (err, rows) => {
    if (err) {
      console.error('❌ Error fetching return list:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    const formatted = rows.map(item => ({
      id: item.borrow_id,
      borrower: item.borrower,
      book: item.book,
      from: item.borrow_date
        ? new Date(item.borrow_date).toLocaleDateString('th-TH')
        : '-',
      to: item.return_date
        ? new Date(item.return_date).toLocaleDateString('th-TH')
        : '-',
      status: item.status,
      reject_reason: item.reject_reason || "-",
      image: `${BASE_URL}/images/${item.image || 'default.png'}`
    }));

    res.json(formatted);
  });
});

// ✅ API: Confirm return (staff click “Get Return”)
app.put('/api/staff/return/:id', (req, res) => {
  const { id } = req.params;
  const staffId = req.body.received_by || null; // optional

  const sql = `
    UPDATE borrowings
    SET STATUS = 'returned', approval_status = 'approved', received_by = ?
    WHERE id = ? AND STATUS = 'borrowed'
  `;

  db.query(sql, [staffId, id], (err, result) => {
    if (err) {
      console.error('❌ Error updating return:', err);
      return res.status(500).json({ message: 'Database error' });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'No borrowed record found' });
    } else if (newStatus === 'rejected') {
      updateSql = `
        UPDATE borrowings 
        SET status = ?, approval_status = ?, reject_reason = ?
        WHERE id = ?
      `;
      updateParams = [newStatus, approvalStatus, req.body.reject_reason || null, borrowId];
    }

    // ✅ คืนสถานะหนังสือให้ available
    db.query(
      'UPDATE books b JOIN borrowings br ON b.id = br.book_id SET b.STATUS = "available" WHERE br.id = ?',
      [id]
    );

    console.log(`✅ Borrow ID ${id} marked as returned`);
    res.json({ message: 'Book return confirmed successfully' });
  });
});



// ============ UPLOAD IMAGE API ============ //
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// 📂 ตั้งค่าเก็บไฟล์ในโฟลเดอร์ uploads/
const uploadDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
  console.log('📁 Created uploads folder automatically');
}

// ✅ ตั้งค่า multer
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, uploadDir); // ใช้ path ที่สร้างไว้ด้านบน
  },
  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  },
});

const upload = multer({ storage });

// ✅ endpoint อัปโหลด
app.post('/upload', upload.single('image'), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ message: 'No file uploaded' });
  }

  const fileUrl = `${BASE_URL}/uploads/${req.file.filename}`;
  res.json({
    message: 'Upload success',
    filename: req.file.filename,
    url: fileUrl,
  });
});

// ✅ เปิด static path
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
app.use('/images', express.static(path.join(__dirname, 'uploads')));
// app.use('/images', express.static('assets/images'));

app.listen(3000, () => {
  console.log("🚀 Server running on port 3000");
});