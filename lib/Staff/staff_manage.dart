import 'package:flutter/material.dart';

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
  String selectedStatus = 'Available';
  bool showEditBook = false;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  final List<Map<String, String>> books = [
    {
      'title': 'DUNE (MOVIE TIE-IN)',
      'tag': 'Literature',
      'status': 'Available',
      'image': 'assets/images/dune1.jpeg',
    },
    {
      'title': 'Ready Player One',
      'tag': 'Literature',
      'status': 'Available',
      'image': 'assets/images/ready.jpg',
    },
    {
      'title': 'เรือนมรณะแดง',
      'tag': 'Horror',
      'status': 'Disable',
      'image': 'assets/images/redboat.jpg',
    },
  ];

  Map<String, String>? editingBook; // เก็บข้อมูลหนังสือที่กำลังแก้ไข

  // เมื่อกด Edit
  void _editBook(Map<String, String> book) {
    setState(() {
      editingBook = Map<String, String>.from(book);
      titleController.text = editingBook!['title'] ?? '';
      authorController.text = editingBook!['author'] ?? '';
      detailController.text = editingBook!['detail'] ?? '';
      selectedStatus = editingBook!['status'] ?? 'Available';
      showEditBook = true; // ✅ แสดง popup สำหรับแก้ไข
    });
  }

  // เมื่อกด Save
  void _saveBook({bool isEdit = false}) {
    setState(() {
      if (isEdit && editingBook != null) {
        // 🔸 กรณีแก้ไข
        final index = books.indexWhere(
          (b) => b['title'] == editingBook!['title'],
        );
        if (index != -1) {
          books[index]['title'] = titleController.text;
          books[index]['author'] = authorController.text;
          books[index]['detail'] = detailController.text;
          books[index]['status'] = selectedStatus;
        }
        editingBook = null;
        showEditBook = false;
      } else {
        // 🔹 กรณีเพิ่มใหม่
        books.add({
          'title': titleController.text,
          'author': authorController.text,
          'tag': 'Literature',
          'status': selectedStatus,
          'image': 'assets/images/default.png',
          'detail': detailController.text,
        });
        showAddBook = false;
      }

      // เคลียร์ช่องหลังบันทึก
      titleController.clear();
      authorController.clear();
      detailController.clear();
    });
  }

  // เมื่อกด Disable
  void _disableBook(int index) {
    setState(() {
      books[index]['status'] = 'Disable';
    });
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
            onPressed: () {
              setState(() {
                books.removeAt(index);
                showAddBook = false;
              });
              Navigator.pop(context);
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
                Navigator.pop(context); // กลับไปหน้า login
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
              child: SingleChildScrollView(
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
                        decoration: InputDecoration(
                          hintText: 'SEARCH',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              setState(() {});
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // เนื้อหาหนังสือจริง (ตอนนี้เอา placeholder ออกได้เลย)
                      // หรือจะใช้ Container สูง ๆ แทนก็ได้
                      // 🔹 GridView แสดงหนังสือ
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio:
                                  0.5, // ✅ ปรับอัตราส่วนให้สูงขึ้นเล็กน้อย
                            ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ), // ✅ เพิ่มระยะหายใจ
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    child: Image.asset(
                                      book['image']!,
                                      height: 120, // ✅ ลดความสูงภาพลง
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: Text(
                                      book['title']!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    'Tag: ${book['tag']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Status: ${book['status']}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: book['status'] == 'Available'
                                          ? Colors.green
                                          : (book['status'] == 'Disable'
                                                ? Colors.red
                                                : Colors.orange),
                                    ),
                                  ),
                                  const Spacer(), // ✅ ดันปุ่มลงล่างแบบไม่ล้น
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.brown[700],
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          minimumSize: const Size(60, 25),
                                        ),
                                        onPressed: () => _editBook(book),
                                        child: const Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              book['status'] == 'Disable'
                                              ? Colors.grey
                                              : Colors.redAccent,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          minimumSize: const Size(60, 25),
                                        ),
                                        onPressed: () => _disableBook(index),
                                        child: Text(
                                          book['status'] == 'Disable'
                                              ? 'Disabled'
                                              : 'Disable',
                                          style: const TextStyle(
                                            fontSize: 11,
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
                              const Text(
                                'Category :',
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
                                    label: const Text('Education'),
                                    onSelected: (_) {},
                                  ),
                                  FilterChip(
                                    label: const Text('Literature'),
                                    onSelected: (_) {},
                                  ),
                                  FilterChip(
                                    label: const Text('Art & Design'),
                                    onSelected: (_) {},
                                  ),
                                  FilterChip(
                                    label: const Text('Comic'),
                                    onSelected: (_) {},
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
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
                                    onSelected: (_) {},
                                  ),
                                  FilterChip(
                                    label: const Text('Borrowed'),
                                    onSelected: (_) {},
                                  ),
                                  FilterChip(
                                    label: const Text('Disable'),
                                    onSelected: (_) {},
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
                                    onPressed: () {},
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
                                        image: AssetImage(
                                          editingBook?['image'] ??
                                              'assets/images/default.png',
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
                                        onPressed: () {},
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
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Title : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: titleController.text),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    const TextSpan(
                                      text: 'Author : ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: authorController.text),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              const Text(
                                'Status :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Row(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: selectedStatus == 'Available',
                                        onChanged: (_) => setState(
                                          () => selectedStatus = 'Available',
                                        ),
                                      ),
                                      const Text('Available'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: selectedStatus == 'Disable',
                                        onChanged: (_) => setState(
                                          () => selectedStatus = 'Disable',
                                        ),
                                      ),
                                      const Text('Disable'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: selectedStatus == 'Borrowed',
                                        onChanged: (_) => setState(
                                          () => selectedStatus = 'Borrowed',
                                        ),
                                      ),
                                      const Text('Borrowed'),
                                    ],
                                  ),
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
                                    onPressed: () {
                                      if (editingBook != null) {
                                        final index = books.indexWhere(
                                          (b) =>
                                              b['title'] ==
                                              editingBook!['title'],
                                        );
                                        if (index != -1) books.removeAt(index);
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
                                    ),
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                                  const SizedBox(width: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.brown[700],
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      'Upload',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Title',
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
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
                              Wrap(
                                spacing: 10,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(value: true, onChanged: (_) {}),
                                      const Text('Available'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(value: false, onChanged: (_) {}),
                                      const Text('Borrowed'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(value: false, onChanged: (_) {}),
                                      const Text('Disable'),
                                    ],
                                  ),
                                ],
                              ),
                              const Text(
                                'Detail :',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
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
                                        setState(() => showAddBook = false),
                                    child: const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        setState(() => showAddBook = false),
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

      // // 🔹 Bottom Navigation
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      //   type: BottomNavigationBarType.fixed,
      //   backgroundColor: const Color(0xFF5E2B2B),
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.dashboard),
      //       label: 'Dashboard',
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Manage'),
      //     BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.assignment_return),
      //       label: 'Get Return',
      //     ),
      //   ],
      // ),
    );
  }
}
