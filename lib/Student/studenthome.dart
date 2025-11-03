import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// ====== หน้าต่าง ๆ เดิมของมึง ถ้ามีให้ import ตามนี้ ======
import 'studenthistory.dart';
import 'student_request.dart';
import 'studentprofile.dart';
import 'package:projectmobile_g9/Login-Regis/Login.dart';

// ================== CONFIG ==================
// Emulator Android ใช้ 10.0.2.2
// ถ้าเป็นมือถือจริงใน LAN ให้เปลี่ยนเป็น IP คอม เช่น 'http://192.168.1.50:3000'
const String baseUrl = 'http://192.168.49.1:3000';
const int kDemoUserId = 9; // ให้ตรงกับ users.id ใน DB

// ============================================

void main() {
  runApp(const StudentHome());
}

class StudentHome extends StatelessWidget {
  const StudentHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B1A1A)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const BookStoreHome(),
    );
  }
}

/// เปลี่ยนบทบาทเพื่อสลับเมนูให้เหมือนภาพแต่ละแบบ
enum UserRole { student, staff, admin }

class BookStoreHome extends StatefulWidget {
  const BookStoreHome({super.key});

  @override
  State<BookStoreHome> createState() => _BookStoreHomeState();
}

class _BookStoreHomeState extends State<BookStoreHome> {
  
  // ตั้งค่าเริ่มเป็นนักศึกษา ตามภาพที่ให้มา
  UserRole currentRole = UserRole.student;
 
  int _currentIndex = 0;
  String _query = '';

  // สีตามดีไซน์
  static const Color kBar = Color(0xFF7A1B1B); // แถบล่าง
  static const Color kActive = Color(0xFF5C1313); // วงรีตอนเลือก
  static const Color kTextIcon = Colors.white; // สีไอคอน/ตัวหนังสือ

  @override
  Widget build(BuildContext context) {
    final pages = _pagesForRole(currentRole);

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: _SearchBar(onChanged: (v) => setState(() => _query = v)),
            )
          : AppBar(
              backgroundColor: const Color(0xFF8B1A1A),
              title: Text(
                pages[_currentIndex].label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
              centerTitle: true,
            ),
      body: IndexedStack(
        index: _currentIndex,
        children: List.generate(pages.length, (i) {
          if (i == 0) {
            // หน้า Home → ดึงจาก API จริง
            return _HomeGrid(query: _query);
          } else if (currentRole == UserRole.student && i == 1) {
            // หน้า My Request
            return RequestPage();
          } else if (currentRole == UserRole.student && i == 2) {
            // หน้า History
            return const StudentHistory();
          } else if (currentRole == UserRole.student && i == 3) {
            // 🔹 หน้า Profile
            return const StudentProfile();
          }
          // หน้าที่เหลือเป็น placeholder
          return _PlaceholderPage(title: pages[i].label);
        }),
      ),

      // ---------- Bottom Bar แบบ custom (แดง + วงรี active) ----------
      bottomNavigationBar: _CurvedBottomBar(
        items: pages,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: kBar,
        activePillColor: kActive,
        iconAndTextColor: kTextIcon,
      ),
    );
  }

  List<_NavPage> _pagesForRole(UserRole role) {
    switch (role) {
      case UserRole.staff:
        return const [
          _NavPage('Home', Icons.home_outlined),
          _NavPage('Approve', Icons.note_add_outlined),
          _NavPage('Dashboard', Icons.dashboard_customize_outlined),
          _NavPage('History', Icons.access_time),
          _NavPage('Profile', Icons.sentiment_satisfied_alt_outlined),
        ];
      case UserRole.student:
        // << แบบในรูป: Home / My Request / History / Profile >>
        return const [
          _NavPage('Home', Icons.home_outlined),
          _NavPage('My Request', Icons.note_add_outlined),
          _NavPage('History', Icons.access_time),
          _NavPage('Profile', Icons.sentiment_satisfied_alt_outlined),
        ];
      case UserRole.admin:
        return const [
          _NavPage('Home', Icons.home_outlined),
          _NavPage('Dashboard', Icons.dashboard_customize_outlined),
          _NavPage('Manage', Icons.edit_note),
          _NavPage('History', Icons.access_time),
          _NavPage('Get Return', Icons.assignment_return_outlined),
        ];
    }
  }
}

class _NavPage {
  final String label;
  final IconData icon;
  const _NavPage(this.label, this.icon);
}

/// ----------------- Bottom Bar (custom pill highlight) -----------------
class _CurvedBottomBar extends StatelessWidget {
  final List<_NavPage> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color backgroundColor;
  final Color activePillColor;
  final Color iconAndTextColor;

  const _CurvedBottomBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.backgroundColor,
    required this.activePillColor,
    required this.iconAndTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: backgroundColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isActive = i == currentIndex;

          return GestureDetector(
            onTap: () => onTap(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? activePillColor : Colors.transparent,
                borderRadius: BorderRadius.circular(44),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, color: iconAndTextColor, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      color: iconAndTextColor,
                      fontSize: 12,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ====================== API CLIENT ======================
class ApiClient {
  static Future<List<dynamic>> fetchBooks() async {
    final r = await http.get(Uri.parse('$baseUrl/books'));
    if (r.statusCode != 200) {
      throw Exception('Fetch books failed: ${r.statusCode} ${r.body}');
    }
    return jsonDecode(r.body) as List<dynamic>;
  }

  static Future<void> borrow({required int userId, required int bookId}) async {
    final r = await http.post(
      Uri.parse('$baseUrl/borrow'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'bookId': bookId}),
    );
    if (r.statusCode != 200) {
      throw Exception('Borrow failed: ${r.body}');
    }
  }
}

/// ===================== HOME GRID (API จริง) =====================
class _HomeGrid extends StatefulWidget {
  final String query;
  const _HomeGrid({required this.query});

  @override
  State<_HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<_HomeGrid> {
  late Future<List<dynamic>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = ApiClient.fetchBooks();
  }

  Future<void> _refresh() async {
    setState(() {
      _booksFuture = ApiClient.fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('ไม่มีหนังสือในระบบ')),
              ],
            ),
          );
        }

        final books = snapshot.data!
    .where((b) => _readS(b, ['title', 'TITLE'])
        .toLowerCase()
        .contains(widget.query.toLowerCase().trim()))
    .toList();

        return RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 7,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black12,
                        ),
                        child: Image.asset(
                          'assets/images/1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, i) =>
                      _BookCardFromJson(book: books[i], onChanged: _refresh),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
/// 🔹 ฟังก์ชันช่วยโหลดภาพ (รองรับทั้ง URL, assets, และชื่อไฟล์ตรง)
ImageProvider _bookImage(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) {
    return const AssetImage('assets/images/ready.jpg'); // placeholder
  }
  if (s.startsWith('http')) return NetworkImage(s);
  if (s.startsWith('assets/')) return AssetImage(s);
  return AssetImage('assets/images/$s'); // เช่น "1.jpg", "redhood.jpg"
}
/// 🔹 ฟังก์ชันช่วยอ่านคีย์ได้ทั้งตัวเล็ก/ตัวใหญ่
/// 🔹 ฟังก์ชันช่วยอ่านคีย์ได้ทั้งตัวเล็ก/ตัวใหญ่
/// 
String _readS(Map<String, dynamic> m, List<String> keys, {String fallback = ''}) {
  for (final k in keys) {
    final v = m[k];
    if (v != null) return v.toString(); // ✅ เพิ่ม ; ตรงนี้
  }
  return fallback;
}

int _readI(Map<String, dynamic> m, List<String> keys, {int fallback = 0}) {
  
  for (final k in keys) {
    final v = m[k];
    if (v is int) return v;
    if (v is String) {
      final n = int.tryParse(v);
      if (n != null) return n;
    }
  }
  return fallback;
}

/// =================== BOOK CARD (จาก JSON API) ===================
class _BookCardFromJson extends StatelessWidget {
  final Map<String, dynamic> book;
  final Future<void> Function() onChanged;
  const _BookCardFromJson({required this.book, required this.onChanged});

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'borrowed':
        return Colors.orange;
      case 'disabled':
      case 'disable':
        return Colors.grey;
      case 'pending':
      default:
        return Colors.blueGrey;
    }
  }
 
  @override
  Widget build(BuildContext context) {
    
  final int id             = _readI(book, ['id', 'ID']);
  final String title       = _readS(book, ['title', 'TITLE']);
  final String image       = _readS(book, ['image', 'IMAGE']);
  final String status      = _readS(book, ['status', 'STATUS']);
  final String description = _readS(book, [ 'description','DESCRIPTION','desc','Desc','DESC']);
  final Color color        = _statusColor(status);

  return Material(
    color: Colors.white,
    elevation: 0,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        final desc = description.trim();
        // ใช้ status จากตัวแปรด้านบน ไม่ต้องประกาศซ้ำ
   

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
 content: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          'Status: ${status.isEmpty ? "-" : status}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      if (description.trim().isNotEmpty) ...[
        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(description.trim()),
      ] else
        const Text('No description'),
    ],
  ),
),

      actions: [
        if (status.toLowerCase().trim() == 'available')
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx); // ปิด dialog ก่อน
              try {
                await ApiClient.borrow(
                  userId: kDemoUserId,
                  bookId: id,
                );
                await onChanged();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Borrow success')),
                  );
                }
              } catch (e) {
                final msg = e.toString();
                var pretty = 'Borrow failed';
                if (msg.contains('ER_NO_REFERENCED_ROW_2')) {
                  pretty = 'Borrow failed: ไม่พบ userId ในตาราง users (เช็ค kDemoUserId ให้ตรง DB)';
                } else if (msg.contains('ECONNREFUSED')) {
                  pretty = 'Borrow failed: ต่อเซิร์ฟเวอร์ไม่ได้ (เช็ค baseUrl/พอร์ต)';
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(pretty)),
                  );
                }
              }
            },
            child: const Text('Borrow'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
},

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: _bookImage(image), // ✅ ใช้ฟังก์ชันช่วยโหลดภาพ
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withOpacity(0.35)),
                ),
                child: Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}



/// ----------------------------- Search Bar -----------------------------
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Menu tapped'))),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'SEARCH',
                border: InputBorder.none,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}

/// -------------------------- Placeholder pages --------------------------
class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}