import 'dart:io';
import 'package:flutter/material.dart';
import 'package:projectmobile_g9/Login-Regis/login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

XFile? _pickedImage;
String? _uploadedFileName;

String get baseUrl => dotenv.env['BASE_URL'] ?? '';
String get imageUrl => dotenv.env['IMAGE_URL'] ?? '';

class StaffManage extends StatefulWidget {
  const StaffManage({super.key});

  @override
  State<StaffManage> createState() => _StaffManageState();
}

class _StaffManageState extends State<StaffManage> {
  bool showMenu = false;
  bool showFilter = false;
  bool showAddBook = false;
  int _selectedIndex = 2;
  String selectedStatus = 'available';
  bool showEditBook = false;
  String? selectedFilter;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];

  void _searchBooks(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredBooks = books.where((book) {
        final title = (book['title'] ?? '').toString().toLowerCase();
        final author = (book['author'] ?? '').toString().toLowerCase();
        return title.contains(lowerQuery) || author.contains(lowerQuery);
      }).toList();
    });
  }

  void _filterBooks(String? status) {
    setState(() {
      selectedFilter = status;
      if (status == null) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) {
          return (book['status'] ?? '').toString().toLowerCase() ==
              status.toLowerCase();
        }).toList();
      }
    });
  }

  Future<void> fetchBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/books'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          books = json.decode(res.body);
          filteredBooks = books;
        });
      } else {
        throw Exception('Failed to fetch books');
      }
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  Future<void> addBook() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final book = {
      'title': titleController.text,
      'author': authorController.text,
      'description': detailController.text,
      'status': selectedStatus.toLowerCase(),
      'image': _uploadedFileName ?? 'default.png',
    };

    print('📚 AddBook sending: $book');

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/books/add'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(book),
      );

      print('📚 AddBook status: ${res.statusCode}');
      print('📚 AddBook body: ${res.body}');

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Book added')));
        await fetchBooks();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Add failed: ${res.body}')));
      }
    } catch (e) {
      print('❌ addBook error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> updateBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final book = {
      'title': titleController.text,
      'author': authorController.text,
      'description': detailController.text,
      'status': selectedStatus.toLowerCase(),
      'image': _uploadedFileName ?? editingBook?['image'],
    };
    final res = await http.put(
      Uri.parse('$baseUrl/books/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(book),
    );
    if (res.statusCode == 200) {
      await fetchBooks();
    }
  }

  Future<void> deleteBook(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final res = await http.delete(
      Uri.parse('$baseUrl/books/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      await fetchBooks();
    }
  }

  Map<String, dynamic>? editingBook; // เก็บข้อมูลหนังสือที่กำลังแก้ไข
  // เมื่อกด Edit
  void _editBook(Map<String, dynamic> book) {
    setState(() {
      // ✅ เก็บสำเนา object ลงตัวแปรสถานะ
      editingBook = Map<String, dynamic>.from(book);

      // ✅ อัปเดต controllers ด้วยค่าจาก book
      titleController.text = book['title'] ?? '';
      authorController.text = book['author'] ?? '';
      detailController.text = book['description'] ?? '';

      // ✅ เก็บสถานะให้เป็น lower เพื่อส่ง API ได้ง่าย
      selectedStatus = (book['status'] ?? 'available').toString().toLowerCase();
      _uploadedFileName = book['image'];
      _pickedImage = null;
      selectedStatus = (book['status'] ?? 'available').toString().toLowerCase();

      showEditBook = true;
    });
  }

  // เมื่อกด Save
  Future<void> _saveBook({bool isEdit = false}) async {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill in the title')));
      return;
    }

    if (isEdit) {
      // -------- EDIT MODE --------
      if (editingBook == null) return;

      final int id = (editingBook!['id'] as num).toInt();

      // ถ้ามีรูปใหม่ → ใช้รูปใหม่
      if (_pickedImage != null && _uploadedFileName != null) {
        editingBook!['image'] = _uploadedFileName;
      }

      await updateBook(id);
      await fetchBooks();
    } else {
      // -------- ADD MODE --------

      // ถ้าเลือกภาพแต่ยังไม่อัปโหลดสำเร็จ
      if (_pickedImage != null && _uploadedFileName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please wait for image upload")),
        );
        return;
      }

      await addBook(); // เพิ่มหนังสือใหม่
      await fetchBooks();
    }

    // -------- RESET FORM --------
    setState(() {
      titleController.clear();
      authorController.clear();
      detailController.clear();
      selectedStatus = 'available';
      _pickedImage = null;
      _uploadedFileName = null;
      showAddBook = false;
      showEditBook = false;
    });
  }

  // เมื่อกด Disable
  void _disableBook(int index) {
    setState(() {
      books[index]['status'] = 'Disabled';
    });
  }

  Future<void> patchBookStatus(int id, String status) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";
    final res = await http.patch(
      Uri.parse('$baseUrl/books/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'status': status}),
    );
    if (res.statusCode == 200) {
      await fetchBooks();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update status')));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img == null) return;
    setState(() => _pickedImage = img);
    await _uploadImage(img); // อัปขึ้น server ต่อเลย
  }

  Future<void> _uploadImage(XFile img) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token") ?? "";

    final url = Uri.parse('$baseUrl/upload');
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Content-Type'] = 'multipart/form-data';
    req.files.add(
      await http.MultipartFile.fromPath(
        'image',
        img.path,
        filename: img.name,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final res = await req.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      final data = json.decode(body);
      setState(() {
        _uploadedFileName = data['filename'];

        // 🔥 บังคับให้ editingBook อัปเดตรูปใหม่ด้วย
        if (editingBook != null) {
          editingBook!['image'] = _uploadedFileName;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  // เมื่อกด Delete (พร้อม confirm)
  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Delete this book?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this book permanently?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              final int id = (filteredBooks[index]['id'] as num).toInt();

              Navigator.pop(context);
              await deleteBook(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Column(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFF5E2B2B),
                size: 48,
              ),
              SizedBox(height: 8),
              Text(
                'Are you sure to Logout?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E2B2B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // ปิด dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false, // ล้างทุกหน้าออกจาก stack
                );
              },

              child: const Text('Sure', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'Book Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            setState(() {
              showMenu = !showMenu; // 🔹 สลับสถานะเมนู burger
            });
          },
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  showFilter = !showFilter;
                });
              },
              child: const Text(
                'Filter',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      // 🔹 Body
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            // พื้นหลังหลัก — ให้ขยายเต็มจอจริง ๆ
            SizedBox.expand(
              child: RefreshIndicator(
                color: const Color(0xFF5E2B2B), // สีของวงกลมโหลด
                onRefresh: fetchBooks, // ✅ เรียก API โหลดใหม่
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // ✅ ให้ดึงได้แม้เลื่อนสุด
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        // Search bar
                        TextField(
                          controller: searchController,
                          onChanged: _searchBooks, // ✅ ผูกกับฟังก์ชันค้นหา
                          decoration: InputDecoration(
                            hintText: 'SEARCH BY TITLE OR AUTHOR',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                _searchBooks('');
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 🔹 GridView แสดงหนังสือ
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.68,
                              ),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            final status = (book['status'] ?? '')
                                .toString()
                                .toLowerCase();

                            final statusText =
                                {
                                  'available': 'Available',
                                  'borrowed': 'Borrowed',
                                  'pending': 'Pending Approve',
                                  'disabled': 'Disabled',
                                }[status] ??
                                '-';

                            final statusColor = status == 'available'
                                ? Colors.green
                                : status == 'disabled'
                                ? Colors.red
                                : Colors.orange;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // 🔹 รูปภาพปกหนังสือ
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        '$baseUrl/uploads/${book['image'] ?? 'default.png'}',
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.image_not_supported,
                                                  size: 60,
                                                  color: Colors.grey,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // 🔹 เส้นคั่นบาง ๆ (เพิ่มความเรียบหรู)
                                    Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                      height: 10,
                                    ),

                                    // 🔹 ชื่อหนังสือ
                                    Text(
                                      book['title'] ?? '-',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15, // ✅ ใหญ่ขึ้นจากเดิม
                                        color: Colors.black87,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    // 🔹 ผู้เขียน
                                    Text(
                                      book['author'] ?? '-',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 13, // ✅ ใหญ่ขึ้น
                                        color: Colors.black54,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),

                                    const SizedBox(height: 6),

                                    // 🔹 สถานะ
                                    Text(
                                      'Status: $statusText',
                                      style: TextStyle(
                                        fontSize: 13, // ✅ ใหญ่ขึ้น
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),

                                    const Spacer(),

                                    // 🔹 ปุ่ม Edit / Disable
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.brown[700],
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            minimumSize: const Size(70, 32),
                                          ),
                                          onPressed: () => _editBook(book),
                                          child: const Text(
                                            'Edit',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                (book['status']
                                                        ?.toString()
                                                        .toLowerCase() ==
                                                    'disabled')
                                                ? Colors.grey
                                                : Colors.redAccent,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            minimumSize: const Size(70, 32),
                                          ),
                                          onPressed: () async {
                                            final int id = (book['id'] as num)
                                                .toInt();
                                            await patchBookStatus(
                                              id,
                                              'disabled',
                                            );
                                          },
                                          child: Text(
                                            (book['status']
                                                        ?.toString()
                                                        .toLowerCase() ==
                                                    'disabled')
                                                ? 'Disabled'
                                                : 'Disable',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (showMenu)
              Positioned(
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 180,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.black87),
                      title: const Text(
                        'Log out',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      onTap: () {
                        setState(() => showMenu = false);
                        _showLogoutDialog();
                      },
                    ),
                  ),
                ),
              ),

            // 🔹 Filter Popup
            if (showFilter)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showFilter = false), // แตะนอกปิด
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          width: MediaQuery.of(context).size.width * 0.9,
                          constraints: BoxConstraints(
                            maxHeight:
                                MediaQuery.of(context).size.height * 0.85,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                'Status :',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 10,
                                children: [
                                  FilterChip(
                                    label: const Text('Available'),
                                    selected: selectedFilter == 'available',
                                    onSelected: (_) =>
                                        _filterBooks('available'),
                                  ),
                                  FilterChip(
                                    label: const Text('Borrowed'),
                                    selected: selectedFilter == 'borrowed',
                                    onSelected: (_) => _filterBooks('borrowed'),
                                  ),
                                  FilterChip(
                                    label: const Text('Pending Approve'),
                                    selected: selectedFilter == 'pending',
                                    onSelected: (_) => _filterBooks('pending'),
                                  ),
                                  FilterChip(
                                    label: const Text('Disable'),
                                    selected: selectedFilter == 'disabled',
                                    onSelected: (_) => _filterBooks('disabled'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                    ),
                                    onPressed: () =>
                                        setState(() => showFilter = false),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      _filterBooks(null);
                                      setState(() => showFilter = false);
                                    },
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 🔹 Edit Book Popup
            if (showEditBook)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showEditBook = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🔸 Book cover
                                  Container(
                                    width: 120,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                      image: DecorationImage(
                                        image: (_pickedImage != null)
                                            ? FileImage(
                                                    File(_pickedImage!.path),
                                                  )
                                                  as ImageProvider
                                            : NetworkImage(
                                                '$baseUrl/uploads/${_uploadedFileName ?? editingBook?['image'] ?? 'default.png'}',
                                              ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 🔸 Upload button
                                  Column(
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown[700],
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        onPressed:
                                            _pickImage, // ✅ ใช้ฟังก์ชันเดียวกับ add book
                                        icon: const Icon(
                                          Icons.upload,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          'Upload',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 🔸 Book info
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 6),

                              TextField(
                                controller: authorController,
                                decoration: const InputDecoration(
                                  labelText: 'Author',
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),

                              const Text(
                                'Status :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: selectedStatus == 'available',
                                    onChanged: (_) => setState(
                                      () => selectedStatus = 'available',
                                    ),
                                  ),
                                  const Text('Available'),
                                  Checkbox(
                                    value: selectedStatus == 'pending',
                                    onChanged: (_) => setState(
                                      () => selectedStatus = 'pending',
                                    ),
                                  ),
                                  const Text('Pending'),
                                  Checkbox(
                                    value: selectedStatus == 'borrowed',
                                    onChanged: (_) => setState(
                                      () => selectedStatus = 'borrowed',
                                    ),
                                  ),
                                  const Text('Borrowed'),
                                  Checkbox(
                                    value: selectedStatus == 'disabled',
                                    onChanged: (_) => setState(
                                      () => selectedStatus = 'disabled',
                                    ),
                                  ),
                                  const Text('Disabled'),
                                ],
                              ),

                              const SizedBox(height: 8),
                              const Text(
                                'Detail :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),

                              // 🔸 Detail box
                              TextField(
                                controller: detailController,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      color: Colors.brown,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 🔸 Buttons row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _saveBook(isEdit: true),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (editingBook != null) {
                                        final int id =
                                            (editingBook!['id'] as num).toInt();
                                        await deleteBook(id);
                                        await fetchBooks();
                                      }
                                      setState(() => showEditBook = false);
                                    },
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 25,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () =>
                                        setState(() => showEditBook = false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 🔹 Add Book Popup
            if (showAddBook)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => showAddBook = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 40),
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                      image:
                                          (_pickedImage != null ||
                                              _uploadedFileName != null)
                                          ? DecorationImage(
                                              image: _pickedImage != null
                                                  ? FileImage(
                                                          File(
                                                            _pickedImage!.path,
                                                          ),
                                                        )
                                                        as ImageProvider
                                                  : NetworkImage(
                                                      '$baseUrl/uploads/${_uploadedFileName!}',
                                                    ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child:
                                        (_pickedImage == null &&
                                            _uploadedFileName == null)
                                        ? const Icon(Icons.image, size: 50)
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                    ),
                                    onPressed:
                                        _pickImage, // ✅ ผูกเข้ากับเลือก+อัปโหลด
                                    child: const Text(
                                      'Upload',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 🔸 Title / Author
                              TextField(
                                controller: titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: authorController,
                                decoration: const InputDecoration(
                                  labelText: 'Author',
                                  border: UnderlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 12),
                              const Text(
                                'Status :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              // 🔸 Status radio group
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RadioListTile<String>(
                                    title: const Text('Available'),
                                    value: 'available',
                                    groupValue: selectedStatus,
                                    onChanged: (value) =>
                                        setState(() => selectedStatus = value!),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('Borrowed'),
                                    value: 'borrowed',
                                    groupValue: selectedStatus,
                                    onChanged: (value) =>
                                        setState(() => selectedStatus = value!),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('Pending'),
                                    value: 'pending',
                                    groupValue: selectedStatus,
                                    onChanged: (value) =>
                                        setState(() => selectedStatus = value!),
                                  ),
                                  RadioListTile<String>(
                                    title: const Text('Disable'),
                                    value: 'disabled',
                                    groupValue: selectedStatus,
                                    onChanged: (value) =>
                                        setState(() => selectedStatus = value!),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              const Text(
                                'Detail :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: detailController,
                                maxLines: 6,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.all(10),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 🔸 Buttons row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                    ),
                                    onPressed: () async {
                                      await _saveBook();
                                    },
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        showAddBook = false;
                                        // ✅ รีเซ็ตฟอร์มเมื่อยกเลิก
                                        titleController.clear();
                                        authorController.clear();
                                        detailController.clear();
                                        selectedStatus = 'available';
                                      });
                                    },
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),

      floatingActionButton: (!showAddBook && !showFilter && !showEditBook)
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF5E2B2B),
              icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
              label: const Text(
                'Add Book',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  showAddBook = true;
                });
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
  }
}
