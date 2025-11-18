import 'package:flutter/material.dart';
import 'staff_dashboard.dart';
import 'staff_manage.dart';
import 'staffhistory.dart';
import 'staffgetreturn.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projectmobile_g9/Login-Regis/login.dart';

void main() => runApp(const StaffBookStoreApp());

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';
String fixImage(String? img) {
  if (img == null || img.isEmpty) {
    return '$baseUrl/uploads/default.png';
  }

  if (img.startsWith('http')) return img;

  // ถ้า img มีคำว่า uploads อยู่แล้ว ให้ใช้ตรงๆ
  if (img.contains('uploads')) {
    return '$baseUrl/$img';
  }

  return '$baseUrl/uploads/$img';
}

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
  final GlobalKey<_BookGridSectionState> _gridKey =
      GlobalKey<_BookGridSectionState>();

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
                gridKey: _gridKey,
              ),
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _BookGridSection(key: _gridKey, query: _query),
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
class _BookGridSection extends StatefulWidget {
  final String query;
  const _BookGridSection({super.key, required this.query});

  @override
  State<_BookGridSection> createState() => _BookGridSectionState();
}

class _BookGridSectionState extends State<_BookGridSection> {
  List<BookItem> books = [];
  bool isLoading = true;
  String selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }

  Future<void> fetchBooks() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/books'));
      if (res.statusCode == 200) {
        final List data = json.decode(res.body);
        setState(() {
          books = data.map((b) => BookItem.fromJson(b)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch books');
      }
    } catch (e) {
      print('❌ Error fetching books: $e');
      setState(() => isLoading = false);
    }
  }

  void setFilter(String newFilter) {
    setState(() {
      selectedFilter = newFilter;
      // ✅ ไม่เรียก fetchBooks() ใหม่
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFF7A1B1B)),
          )
        : RefreshIndicator(
            color: const Color(0xFF7A1B1B), // สีวงกลมโหลด
            onRefresh: fetchBooks, // ✅ เรียกฟังก์ชันโหลดใหม่
            child: CustomScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // ✅ ให้ดึงลงได้เสมอ
              slivers: [
                // ✅ Banner ส่วนบน (คงที่)
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
                        '$baseUrl/uploads/banner.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 180,
                          color: Colors.black12,
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),

                // ✅ ส่วนแสดงหนังสือ
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: _BookGridView(
                    books: books,
                    query: widget.query,
                    filter: selectedFilter,
                  ),
                ),
              ],
            ),
          );
  }
}

/// ---------------------- Book Card ----------------------
enum BookStatus { available, borrow, disable, pendingReturn }

class BookItem {
  final int id;
  final String title;
  final String author;
  final String description;
  final String image;
  final String status;

  const BookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.image,
    required this.status,
  });

  factory BookItem.fromJson(Map<String, dynamic> json) {
    return BookItem(
      id: json['id'],
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 'unknown',
    );
  }
}

class _BookItemCard extends StatelessWidget {
  final BookItem book;
  const _BookItemCard({required this.book});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'borrowed':
        return Colors.orange;
      case 'pending':
        return Colors.blueGrey;
      case 'disabled':
        return Colors.grey;
      default:
        return Colors.black45;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(book.status);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(book.title),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Author: ${book.author}'),
                  const SizedBox(height: 6),
                  Text('Status: ${book.status}'),
                  const SizedBox(height: 6),
                  Text(
                    book.description.isNotEmpty
                        ? book.description
                        : 'No description available.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  // ✅ ใช้ dialogContext แทน context
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Close'),
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
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(fixImage(book.image)),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                  book.status,
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

class _BookGridView extends StatelessWidget {
  final List<BookItem> books;
  final String query;
  final String filter;

  const _BookGridView({
    required this.books,
    required this.query,
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    final filteredBooks = books.where((b) {
      final matchesQuery = b.title.toLowerCase().contains(query.toLowerCase());
      final matchesFilter =
          filter == 'All' || b.status.toLowerCase() == filter.toLowerCase();
      return matchesQuery && matchesFilter;
    }).toList();

    if (filteredBooks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 40),
            child: Text('No books found'),
          ),
        ),
      );
    }

    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 22,
        crossAxisSpacing: 18,
        childAspectRatio: 0.70,
      ),
      itemCount: filteredBooks.length,
      itemBuilder: (_, i) => _BookItemCard(book: filteredBooks[i]),
    );
  }
}

/// ---------------------- Search Bar ----------------------
class _BookSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final GlobalKey<_BookGridSectionState> gridKey;

  const _BookSearchBar({
    required this.onChanged,
    required this.gridKey, // ✅ เพิ่มตรงนี้
  });

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
            icon: const Icon(Icons.menu), // เปลี่ยนเป็น burger icon
            onPressed: () async {
              final sectionState = gridKey.currentState;
              if (sectionState == null) return;

              // เปิด bottom sheet แบบใหม่ที่มีทั้ง Filter และ Logout
              final result = await showModalBottomSheet<String>(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (ctx) {
                  String tempFilter = sectionState.selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Menu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ปุ่ม Filter
                        ListTile(
                          leading: const Icon(Icons.filter_list),
                          title: const Text('Filter Books'),
                          onTap: () async {
                            Navigator.pop(ctx); // ปิดก่อนเปิด filter sheet ใหม่
                            final newFilter =
                                await showModalBottomSheet<String>(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (ctx2) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Wrap(
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
                                              label: Text(status),
                                              selected: tempFilter == status,
                                              selectedColor:
                                                  Colors.red.shade100,
                                              labelStyle: TextStyle(
                                                color: tempFilter == status
                                                    ? Colors.black
                                                    : Colors.grey[700],
                                                fontWeight: tempFilter == status
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                              onSelected: (_) {
                                                Navigator.pop(ctx2, status);
                                              },
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                            if (newFilter != null && context.mounted) {
                              sectionState.setFilter(newFilter);
                            }
                          },
                        ),

                        const Divider(height: 1),

                        // ปุ่ม Logout
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(ctx); // ปิด sheet
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Confirm Logout'),
                                content: const Text(
                                  'Are you sure you want to log out?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pop(); // ปิด dialog
                                      Future.delayed(
                                        const Duration(milliseconds: 150),
                                        () {
                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pushAndRemoveUntil(
                                            MaterialPageRoute(
                                              builder: (_) => const LoginPage(),
                                            ),
                                            (route) => false,
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'Logout',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
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
