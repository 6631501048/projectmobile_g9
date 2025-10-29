import 'package:flutter/material.dart';
import 'staff_dashboard.dart';
import 'staff_manage.dart';
import 'staffhistory.dart';
import 'staffgetreturn.dart';

void main() => runApp(const StaffBookStoreApp());

class StaffBookStoreApp extends StatelessWidget {
  const StaffBookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF7A1B1B), // พื้นหลังแถบล่าง (แดงเข้ม)
          selectedItemColor: Colors.white, // สีที่เลือก
          unselectedItemColor: Colors.white70, // สีที่ไม่เลือก
          showUnselectedLabels: true,
          selectedIconTheme: IconThemeData(size: 24),
          unselectedIconTheme: IconThemeData(size: 22),
          selectedLabelStyle: TextStyle(fontSize: 11),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
      home: const StaffBookStoreScreen(),
    );
  }
}

/// ---------------------- Screen (Admin style: Home/Dashboard/Manage/History/Get Return) ----------------------
class StaffBookStoreScreen extends StatefulWidget {
  const StaffBookStoreScreen({super.key});

  @override
  State<StaffBookStoreScreen> createState() => _StaffBookStoreScreenState();
}

class _StaffBookStoreScreenState extends State<StaffBookStoreScreen> {
  int _currentIndex = 0;
  String _query = '';

  final _pages = const [
    _NavItem('Home', Icons.home_outlined),
    _NavItem('Dashboard', Icons.dashboard_customize_outlined),
    _NavItem('Manage', Icons.edit_note),
    _NavItem('History', Icons.access_time),
    _NavItem('Get Return', Icons.arrow_right_alt), // ไอคอนตามภาพ
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              backgroundColor: Colors.white,
              title: _BookSearchBar(
                onChanged: (v) => setState(() => _query = v),
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _BookGridSection(query: _query),
          const StaffDash(),
          const StaffManage(),
          const StaffHistory(),
          const Returnbook(),
        ],
      ),

      // ---------------------- BottomNavigationBar แบบเรียบ (ไม่มีวงรี) ----------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _currentIndex = i),
        items: _pages
            .map(
              (p) =>
                  BottomNavigationBarItem(icon: Icon(p.icon), label: p.label),
            )
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

/// ---------------------- Banner + Grid (เดโม่) ----------------------
class _BookGridSection extends StatelessWidget {
  final String query;
  const _BookGridSection({required this.query});

  @override
  Widget build(BuildContext context) {
    final list = _bookData
        .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return CustomScrollView(
      slivers: [
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 22,
              crossAxisSpacing: 18,
              childAspectRatio: 0.70,
            ),
            itemCount: list.length,
            itemBuilder: (_, i) => _BookItemCard(book: list[i]),
          ),
        ),
      ],
    );
  }
}

/// ---------------------- Book Card ----------------------
enum BookStatus { available, borrow, disable, pendingReturn }

class BookItem {
  final String title;
  final String coverAsset;
  final BookStatus status;

  const BookItem({
    required this.title,
    required this.coverAsset,
    required this.status,
  });
}

class _BookItemCard extends StatelessWidget {
  final BookItem book;
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
            // ปกหนังสือ
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black12,
                  image: DecorationImage(
                    image: AssetImage(book.coverAsset),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ชื่อเรื่อง
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // สถานะ
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

/// ---------------------- Search Bar ----------------------
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
          IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: const InputDecoration(
                hintText: 'SEARCH',
                border: InputBorder.none,
              ),
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

class _FeaturePlaceholder extends StatelessWidget {
  final String title;
  const _FeaturePlaceholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// ---------------------- Sample book data (assets) ----------------------
const _bookData = <BookItem>[
  BookItem(
    title: 'เรือนแรมสีแดง',
    coverAsset: 'assets/images/1.jpg',
    status: BookStatus.disable,
  ),
  BookItem(
    title: 'แปดขุนเขา',
    coverAsset: 'assets/images/2.jpg',
    status: BookStatus.borrow,
  ),
  BookItem(
    title: 'เพราะรักบานในทุ่งดอกไม้',
    coverAsset: 'assets/images/qqq.jpg',
    status: BookStatus.available,
  ),
  BookItem(
    title: 'หนูน้อยหมวกแดงพบศพระหว่างเดินทาง',
    coverAsset: 'assets/images/4.jpg',
    status: BookStatus.available,
  ),
];
