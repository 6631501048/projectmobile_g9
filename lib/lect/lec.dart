import 'package:flutter/material.dart';
import 'package:projectmobile_g9/lect/lectdash.dart';
import 'package:projectmobile_g9/lect/lecthistory.dart';
import 'package:projectmobile_g9/lect/lectprofile.dart';
import 'package:projectmobile_g9/lect/lecturer_dashboard_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class LectHomeApp extends StatelessWidget {
  final int userId;
  const LectHomeApp({super.key, required this.userId});

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
      home: LectHome(userId: userId),
    );
  }
}

/// ---------------------------------------------------------------------
/// 📚 หน้าหลักของอาจารย์ (LectHome)
/// ---------------------------------------------------------------------
class LectHome extends StatefulWidget {
  final int userId;
  const LectHome({super.key, required this.userId});

  @override
  State<LectHome> createState() => _LectHomeState();
}

class _LectHomeState extends State<LectHome> {
  final GlobalKey<_BookGridSectionState> _bookGridKey =
      GlobalKey<_BookGridSectionState>();

  static const Color kBar = Color(0xFF7A1B1B); // พื้นหลังแท็บ
  static const Color kActive = Color(0xFF5C1313); // วงรีเมื่อเลือก
  static const Color kTextIcon = Colors.white; // ไอคอน/ข้อความ

  int _currentIndex = 0;
  String _query = '';
  String _selectedFilter = 'All'; // ✅ filter เริ่มต้น

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
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: _BookSearchBar(
                onChanged: (v) => setState(() => _query = v),
                onFilterChanged: (status) {
                  setState(() => _selectedFilter = status);
                  _bookGridKey.currentState?.setFilter(status);
                },
                selectedFilter: _selectedFilter,
              ),
            )
          : null,

      body: IndexedStack(
        index: _currentIndex,
        children: [
          _BookGridSection(
            key: _bookGridKey,
            query: _query,
            selectedFilter: _selectedFilter,
          ),
          LecturerDashboardScreen(userId: widget.userId),
          const Lectdash(),
          Lecthistory(userId: widget.userId),
          Lectprofile(userId: widget.userId),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
class _BookGridSection extends StatefulWidget {
  final String query;
  final String selectedFilter;
  const _BookGridSection({
    Key? key,
    required this.query,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  State<_BookGridSection> createState() => _BookGridSectionState();
}

class _BookGridSectionState extends State<_BookGridSection> {
  List<dynamic> books = [];
  bool isLoading = true;
  String _selectedFilter = 'All';

  String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    fetchBooks();
  }

  void setFilter(String status) {
    setState(() {
      _selectedFilter = status;
    });
  }

  Future<void> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/books'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          books = json.decode(res.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('❌ Error fetching books: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = books.where((b) {
      final titleMatch = b['title'].toString().toLowerCase().contains(
        widget.query.toLowerCase(),
      );
      final status = (b['status'] ?? '').toString().toLowerCase();
      final filterMatch =
          _selectedFilter == 'All' || status == _selectedFilter.toLowerCase();
      return titleMatch && filterMatch;
    }).toList();

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF7A1B1B)),
      );
    }

    // ✅ ครอบ CustomScrollView ด้วย RefreshIndicator
    return RefreshIndicator(
      onRefresh: fetchBooks, // ดึงข้อมูลใหม่จาก API
      color: const Color(0xFF7A1B1B),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AspectRatio(
              aspectRatio: 16 / 7,
              child: Container(
                margin: const EdgeInsets.all(12),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// 🔍 Search Bar พร้อม Filter BottomSheet
/// ---------------------------------------------------------------------
class _BookSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFilterChanged;
  final String selectedFilter;
  const _BookSearchBar({
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
                  String tempFilter = selectedFilter;

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
                                    label: Text(status),
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
                                        const Duration(milliseconds: 200),
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

/// ---------------------------------------------------------------------
/// 📖 Book Card
/// ---------------------------------------------------------------------
class _BookItemCard extends StatelessWidget {
  final Map<String, dynamic> book;
  const _BookItemCard({required this.book});

  @override
  Widget build(BuildContext context) {
    final String title = book['title'] ?? '-';
    final String author = book['author'] ?? '-';
    final String status = (book['status'] ?? '').toLowerCase();
    final String description = (book['description'] ?? '').toString().trim();
    final String imagePath =
        '$baseUrl/uploads/${book['image'] ?? 'default.png'}';

    // 🔹 สีและ label ตามสถานะ
    final (label, color) = switch (status) {
      'available' => ('Available', Colors.green),
      'borrowed' => ('Borrowed', Colors.orange),
      'pending' => ('Pending Approve', Colors.blueGrey),
      'disabled' => ('Disabled', Colors.red),
      _ => ('Unknown', Colors.grey),
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              titlePadding: EdgeInsets.zero,
              title: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  imagePath,
                  height: 180,
                  width: MediaQuery.of(ctx).size.width * 0.9,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🏷️ ชื่อหนังสือ
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ✍️ ผู้แต่ง
                    Text(
                      'Author: ${author.isEmpty ? "-" : author}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 📘 สถานะ
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: color.withOpacity(0.35)),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: color.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 📄 คำอธิบาย
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isNotEmpty
                          ? description
                          : 'No description available.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A1B1B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
                  color: Colors.black12,
                  image: DecorationImage(
                    image: NetworkImage(imagePath),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
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
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
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
