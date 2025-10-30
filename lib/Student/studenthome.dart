import 'package:flutter/material.dart';
import 'studenthistory.dart';
import 'student_request.dart';
import 'studentprofile.dart';
import 'package:projectmobile_g9/Login-Regis/Login.dart';

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
            // หน้า Home
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

//
// --------------------------- Home: Banner + Grid ---------------------------
//
class _HomeGrid extends StatelessWidget {
  final String query;
  const _HomeGrid({required this.query});

  @override
  Widget build(BuildContext context) {
    final books = _sampleBooks
        .where(
          (b) => b.title.toLowerCase().contains(query.toLowerCase().trim()),
        )
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black12,
                  ),
                  child: Image.network(
                    'https://picsum.photos/seed/bookstore-banner/1200/520',
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
            itemBuilder: (context, i) => _BookCard(book: books[i]),
          ),
        ),
      ],
    );
  }
}

//
// ----------------------------- Book Card -----------------------------
//
enum BookStatus { available, borrow, disable, pendingReturn }

class Book {
  final String title;
  final String coverUrl; // asset path
  final BookStatus status;

  Book({required this.title, required this.coverUrl, required this.status});
}

class _BookCard extends StatelessWidget {
  final Book book;
  const _BookCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final label = switch (book.status) {
      BookStatus.available => 'Status : Available',
      BookStatus.borrow => 'Status : Borrow',
      BookStatus.disable => 'Status : Disable',
      BookStatus.pendingReturn => 'Status : Pending Return',
    };

    final color = switch (book.status) {
      BookStatus.available => Colors.green,
      BookStatus.borrow => Colors.orange,
      BookStatus.disable => Colors.grey,
      BookStatus.pendingReturn => Colors.blueGrey,
    };

    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(book.title),
              content: Text(label),
              actions: [
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
                    image: AssetImage(book.coverUrl), // โหลดจาก assets
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.title,
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
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.shade700,
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

//
// ----------------------------- Search Bar -----------------------------
//
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

//
// -------------------------- Placeholder pages --------------------------
//
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

//
// ------------------------- Sample data (assets) -------------------------
//
final _sampleBooks = <Book>[
  Book(
    title: 'เรือนแรมสีแดง',
    coverUrl: '',
    status: BookStatus.disable,
  ),
  Book(
    title: 'แปดขุนเขา',
    coverUrl: '',
    status: BookStatus.borrow,
  ),
  Book(
    title: 'หนูน้อยหมวกแดงพบศพระหว่างเดินทาง',
    coverUrl: '',
    status: BookStatus.available,
  ),
  Book(
    title: 'เพราะรักบานในทุ่งดอกไม้',
    coverUrl: '',
    status: BookStatus.available,
  ),
];
