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
// ============================================

class StudentHome extends StatelessWidget {
  final int userId;
  const StudentHome({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BookStoreHome(userId: userId);
  }
}

/// เปลี่ยนบทบาทเพื่อสลับเมนูให้เหมือนภาพแต่ละแบบ
enum UserRole { student, staff, admin }

class BookStoreHome extends StatefulWidget {
  final int userId;
  const BookStoreHome({super.key, required this.userId});

  @override
  State<BookStoreHome> createState() => _BookStoreHomeState();
}

class _BookStoreHomeState extends State<BookStoreHome> {
  // ตั้งค่าเริ่มเป็นนักศึกษา ตามภาพที่ให้มา
  UserRole currentRole = UserRole.student;

  int _currentIndex = 0;
  String _query = '';
  String _selectedFilter = 'All';

  int? selectedBookId;

  // ✅ และเพิ่ม key เพื่อ refresh หน้า Home
  final GlobalKey<_HomeGridState> _homeKey = GlobalKey<_HomeGridState>();

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
              title: _SearchBar(
                onChanged: (v) => setState(() => _query = v),
                onFilterChanged: (status) {
                  setState(() => _selectedFilter = status); // ✅ อัปเดตใน state
                  _homeKey.currentState?.setFilter(
                    status,
                  ); // ✅ ส่งต่อไปกรองใน grid
                },
                selectedFilter: _selectedFilter,
              ),
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
            return _HomeGrid(
              key: _homeKey,
              query: _query,
              userId: widget.userId,
            );
          } else if (currentRole == UserRole.student && i == 1) {
            // หน้า My Request
            return RequestPage(
              key: UniqueKey(),
              bookId: selectedBookId,
              userId: widget.userId,
              initialTab: selectedBookId != null ? 'request' : 'status',
            );
          } else if (currentRole == UserRole.student && i == 2) {
            // หน้า History
            return StudentHistory(userId: widget.userId);
          } else if (currentRole == UserRole.student && i == 3) {
            // 🔹 หน้า Profile
            return StudentProfile(userId: widget.userId);
          }
          // หน้าที่เหลือเป็น placeholder
          return _PlaceholderPage(title: pages[i].label);
        }),
      ),

      // ---------- Bottom Bar แบบ custom (แดง + วงรี active) ----------
      bottomNavigationBar: _CurvedBottomBar(
        items: pages,
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
            selectedBookId = null;
          });
        },
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
  final int userId; // ✅ เพิ่มตรงนี้
  const _HomeGrid({super.key, required this.query, required this.userId});

  @override
  State<_HomeGrid> createState() => _HomeGridState();
}

class _HomeGridState extends State<_HomeGrid> {
  String _selectedStatus = 'All';

  void setFilter(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  Future<void> _refresh() async {
    setState(() {}); // รีเฟรชให้ FutureBuilder เรียกใหม่
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ รีเฟรชข้อมูลสำเร็จ'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<dynamic>>(
        // ✅ ดึงข้อมูลใหม่ทุกครั้งจาก server
        future: ApiClient.fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('ไม่มีหนังสือในระบบ')),
              ],
            );
          }

          final books = snapshot.data!.where((b) {
            final title = _readS(b, ['title', 'TITLE']).toLowerCase();
            final status = _readS(b, ['status', 'STATUS']).toLowerCase();
            final queryMatch = title.contains(
              widget.query.toLowerCase().trim(),
            );
            final filterMatch =
                _selectedStatus == 'All' ||
                status == _selectedStatus.toLowerCase();
            return queryMatch && filterMatch;
          }).toList();

          // ✅ แสดงหนังสือทั้งหมดใน Grid
          return CustomScrollView(
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
                  itemBuilder: (context, i) => _BookCardFromJson(
                    book: books[i],
                    onChanged: _refresh,
                    userId: widget.userId,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 🔹 ฟังก์ชันช่วยโหลดภาพ (รองรับทั้ง URL, assets, และชื่อไฟล์จาก server)
ImageProvider _bookImage(String? raw) {
  final s = (raw ?? '').trim();
  if (s.isEmpty) {
    // ✅ ไม่มีรูปให้ใช้ placeholder
    return const AssetImage('assets/images/ready.jpg');
  }

  // ✅ ถ้ามาเป็น URL เต็ม เช่น http://192.168.49.1:3000/uploads/xxx.jpg
  if (s.startsWith('http')) {
    return NetworkImage(s);
  }

  // ✅ ถ้าเป็นชื่อไฟล์ที่อยู่ใน server เช่น image-xxx.jpg
  if (s.endsWith('.jpg') || s.endsWith('.png') || s.contains('/uploads/')) {
    return NetworkImage('$baseUrl/uploads/$s');
  }

  // ✅ ถ้าเป็นชื่อไฟล์ใน assets ภายในโปรเจกต์
  return AssetImage('assets/images/$s');
}

/// 🔹 ฟังก์ชันช่วยอ่านคีย์ได้ทั้งตัวเล็ก/ตัวใหญ่
String _readS(
  Map<String, dynamic> m,
  List<String> keys, {
  String fallback = '',
}) {
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
  final int userId;
  const _BookCardFromJson({
    required this.book,
    required this.onChanged,
    required this.userId,
  });

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
    final int id = _readI(book, ['id', 'ID']);
    final String title = _readS(book, ['title', 'TITLE']);
    final String image = _readS(book, ['image', 'IMAGE']);
    final String author = _readS(book, ['author', 'AUTHOR']);
    final String status = _readS(book, ['status', 'STATUS']);
    final String description = _readS(book, [
      'description',
      'DESCRIPTION',
      'desc',
      'Desc',
      'DESC',
    ]);
    final Color color = _statusColor(status);

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
                        'Author: ${author.isEmpty ? "-" : author}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Status: ${status.isEmpty ? "-" : status}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const Text(
                        'Description',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      Navigator.pop(ctx);

                      final homeState = context
                          .findAncestorStateOfType<_BookStoreHomeState>();

                      if (homeState != null) {
                        homeState.setState(() {
                          homeState._currentIndex = 1;
                          homeState.selectedBookId = id;
                        });
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
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
  final ValueChanged<String> onFilterChanged;
  final String selectedFilter;

  const _SearchBar({
    required this.onChanged,
    required this.onFilterChanged,
    required this.selectedFilter,
  });

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
            onPressed: () async {
              final result = await showModalBottomSheet<String>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) {
                  String tempFilter = selectedFilter; // ใช้ตัวชั่วคราวใน sheet

                  return StatefulBuilder(
                    builder: (context, setModalState) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Filter by Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              children: [
                                for (final status in [
                                  'All',
                                  'Available',
                                  'Borrowed',
                                  'Pending',
                                  'Disabled',
                                ])
                                  ChoiceChip(
                                    label: Text(status), // ✅ เอา icon check ออก
                                    selected: tempFilter == status,
                                    selectedColor: Colors.red.shade100,
                                    labelStyle: TextStyle(
                                      color: tempFilter == status
                                          ? Colors.black
                                          : Colors.grey[700],
                                      fontWeight: tempFilter == status
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    onSelected: (_) {
                                      setModalState(() => tempFilter = status);
                                      Future.delayed(
                                        const Duration(milliseconds: 180),
                                        () {
                                          Navigator.pop(ctx, status);
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );

              if (result != null && context.mounted) {
                onFilterChanged(result);
              }
            },
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
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
