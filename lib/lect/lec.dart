import 'package:flutter/material.dart';
import 'package:projectmobile_g9/lect/lectdash.dart';
import 'package:projectmobile_g9/lect/lecthistory.dart';
import 'package:projectmobile_g9/lect/lectprofile.dart';
import 'package:projectmobile_g9/lect/lecturer_dashboard_screen.dart';

void main() {
  runApp(const LectHomeApp());
}

class LectHomeApp extends StatelessWidget {
  const LectHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lecturer Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7A1B1B)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LectHome(),
    );
  }
}

/// ---------------------------------------------------------------------
/// 📚 หน้าหลักของอาจารย์ (LectHome)
/// ---------------------------------------------------------------------
class LectHome extends StatefulWidget {
  const LectHome({super.key});

  @override
  State<LectHome> createState() => _LectHomeState();
}

class _LectHomeState extends State<LectHome> {
  // สีตามดีไซน์รูป
  static const Color kBar = Color(0xFF7A1B1B);     // พื้นหลังแท็บ
  static const Color kActive = Color(0xFF5C1313);  // วงรีเมื่อเลือก
  static const Color kTextIcon = Colors.white;     // ไอคอน/ข้อความ

  int _currentIndex = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _BottomNavItem('Home', Icons.home_outlined),
      _BottomNavItem('Approve', Icons.note_add_outlined),
      _BottomNavItem('Dashboard', Icons.dashboard_customize_outlined),
      _BottomNavItem('History', Icons.access_time),
      _BottomNavItem('Profile', Icons.sentiment_satisfied_alt_outlined),
    ];

    return Scaffold(
      // ✅ แสดง Search เฉพาะหน้า Home
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: _BookSearchBar(onChanged: (v) => setState(() => _query = v)),
            )
          : null,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          _BookGridSection(query: _query),
          const LecturerDashboardScreen(),
          const Lectdash(),
          const Lecthistory(),
          const LectProfile(),
        ],
      ),

      // ---------------------- Bottom Bar ----------------------
      bottomNavigationBar: Container(
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(color: kBar),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(pages.length, (i) {
            final item = pages[i];
            final isActive = i == _currentIndex;

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? kActive : Colors.transparent,
                  borderRadius: BorderRadius.circular(44),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: kTextIcon, size: 28),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: const TextStyle(
                        color: kTextIcon,
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
      ),
    );
  }
}

class _BottomNavItem {
  final String label;
  final IconData icon;
  const _BottomNavItem(this.label, this.icon);
}

/// ---------------------------------------------------------------------
/// 🏷️ Section: Banner + Grid
/// ---------------------------------------------------------------------
class _BookGridSection extends StatelessWidget {
  final String query;
  const _BookGridSection({required this.query});

  @override
  Widget build(BuildContext context) {
    final filtered = _bookDataList
        .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return CustomScrollView(
      slivers: [
        // Banner ด้านบน
        SliverToBoxAdapter(
          child: AspectRatio(
            aspectRatio: 16 / 7,
            child: Container(
              margin: const EdgeInsets.all(12),
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
        ),
        // กริดหนังสือ
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 22,
              crossAxisSpacing: 18,
              childAspectRatio: 0.70,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, i) => _BookItemCard(book: filtered[i]),
          ),
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------------------
/// 📖 Book Card
/// ---------------------------------------------------------------------
enum BookStatus { available, borrow, disable, pendingReturn }

class Book {
  final String title;
  final String coverPath;
  final BookStatus status;

  const Book({
    required this.title,
    required this.coverPath,
    required this.status,
  });
}

class _BookItemCard extends StatelessWidget {
  final Book book;
  const _BookItemCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (book.status) {
      BookStatus.available => ('Status : Available', Colors.green),
      BookStatus.borrow => ('Status : Borrow', Colors.orange),
      BookStatus.disable => ('Status : Disable', Colors.grey),
      BookStatus.pendingReturn => ('Status : Pending Return', Colors.blueGrey),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(book.title),
            content: Text(label),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                  image: DecorationImage(
                    image: AssetImage(book.coverPath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

/// ---------------------------------------------------------------------
/// 🔍 Search Bar
/// ---------------------------------------------------------------------
class _BookSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _BookSearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black26),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menu tapped')),
            ),
          ),
          const SizedBox(width: 4),
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

/// ---------------------------------------------------------------------
/// 🧩 Placeholder Pages
/// ---------------------------------------------------------------------
class _FeaturePlaceholder extends StatelessWidget {
  final String title;
  const _FeaturePlaceholder({required this.title});

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

/// ---------------------------------------------------------------------
/// 📚 Sample Data (Assets)
/// ---------------------------------------------------------------------
const _bookDataList = <Book>[
  Book(
    title: 'เรือนแรมสีแดง',
    coverPath: 'assets/images/1.jpg',
    status: BookStatus.disable,
  ),
  Book(
    title: 'แปดขุนเขา',
    coverPath: 'assets/images/2.jpg',
    status: BookStatus.borrow,
  ),
  Book(
    title: 'เพราะรักบานในทุ่งดอกไม้',
    coverPath: 'assets/images/qqq.jpg',
    status: BookStatus.available,
  ),
  Book(
    title: 'หนูน้อยหมวกแดงพบศพระหว่างเดินทาง',
    coverPath: 'assets/images/4.jpg',
    status: BookStatus.available,
  ),
];
