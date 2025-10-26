import 'package:flutter/material.dart';

class StaffManage extends StatefulWidget {
  const StaffManage({super.key});

  @override
  State<StaffManage> createState() => _StaffManageState();
}

class _StaffManageState extends State<StaffManage> {
  bool showFilter = false;
  bool showAddBook = false;
  int _selectedIndex = 2;

  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
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
          onPressed: () {},
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
      body: Stack(
        children: [
          // พื้นหลังหลัก — ให้ขยายเต็มจอจริง ๆ
          SizedBox.expand(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('📚 Book list will appear here'),
                    ),
                  ],
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
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

      floatingActionButton: (!showAddBook && !showFilter)
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

      // 🔹 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF5E2B2B),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Manage'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Get Return',
          ),
        ],
      ),
    );
  }
}
