import 'package:flutter/material.dart';

class Returnbook extends StatefulWidget {
  const Returnbook({super.key});

  @override
  State<Returnbook> createState() => _ReturnbookState();
}

enum ReturnTab { pending, borrowed, available }

class _ReturnbookState extends State<Returnbook> {
  ReturnTab current = ReturnTab.pending;
  int bottomIndex = 3;

  // mock data สำหรับเดโม
  final items = List.generate(8, (i) {
    return {
      'borrower': 'Kwan',
      'book': 'เรื่องแรมสีแดง',
      'from': '5/10/2025',
      'to': '12/10/2025',
    };
  });

  @override
  Widget build(BuildContext context) {
    const maroon = Color(0xFF7B2020);
    const gold = Color(0xFFB38820);
    const chipText = TextStyle(fontWeight: FontWeight.w700, fontSize: 12);

    return Scaffold(
      backgroundColor: const Color(0xFFF7EFF0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: maroon,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        centerTitle: true,
        title: const Text(
          'Get Return',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
      ),

      // เนื้อหา
      body: Column(
        children: [
          const SizedBox(height: 10),

          // แถบตัวเลือก 3 อัน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _Segment(
                  label: 'Pending\nreturn',
                  selected: current == ReturnTab.pending,
                  fillColor: gold,
                  borderColor: gold,
                  textStyle: chipText,
                  onTap: () => setState(() => current = ReturnTab.pending),
                ),
                const SizedBox(width: 10),
                _Segment(
                  label: 'Borrowed',
                  selected: current == ReturnTab.borrowed,
                  fillColor: Colors.transparent,
                  borderColor: Colors.blueGrey,
                  textStyle: chipText.copyWith(color: Colors.blueGrey),
                  onTap: () => setState(() => current = ReturnTab.borrowed),
                ),
                const SizedBox(width: 10),
                _Segment(
                  label: 'Available',
                  selected: current == ReturnTab.available,
                  fillColor: Colors.transparent,
                  borderColor: Colors.green,
                  textStyle: chipText.copyWith(color: Colors.green),
                  onTap: () => setState(() => current = ReturnTab.available),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // รายการบัตร
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final it = items[i];
                return _ReturnCard(
                  borrower: it['borrower']!,
                  book: it['book']!,
                  from: it['from']!,
                  to: it['to']!,
                  status: current == ReturnTab.pending
                      ? 'Pending return'
                      : current == ReturnTab.borrowed
                          ? 'Borrowed'
                          : 'Available',
                  statusColor: current == ReturnTab.pending
                      ? gold
                      : current == ReturnTab.borrowed
                          ? Colors.blueGrey
                          : Colors.green,
                  onAction: () {
                    // TODO: กด Get Return แล้วทำอะไรต่อ
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Get Return clicked')),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // แถบล่าง
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: bottomIndex,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.white70,
      //   backgroundColor: maroon,
      //   type: BottomNavigationBarType.fixed,
      //   onTap: (i) => setState(() => bottomIndex = i),
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home_outlined),
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.dashboard_customize_outlined),
      //       label: 'Dashboard',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.edit_note_outlined),
      //       label: 'Manage',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.history),
      //       label: 'History',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.assignment_return_outlined),
      //       label: 'Get Return',
      //     ),
      //   ],
      // ),
    );
  }
}


/// ปุ่ม segment ด้านบน
class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.fillColor,
    required this.borderColor,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color fillColor;
  final Color borderColor;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? fillColor : Colors.transparent,
                border: Border.all(color: borderColor, width: 1.8),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textStyle.copyWith(
                  color: selected ? Colors.white : textStyle.color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


/// การ์ด 1 ใบในลิสต์
class _ReturnCard extends StatelessWidget {
  const _ReturnCard({
    required this.borrower,
    required this.book,
    required this.from,
    required this.to,
    required this.status,
    required this.statusColor,
    required this.onAction,
  });

  final String borrower;
  final String book;
  final String from;
  final String to;
  final String status;
  final Color statusColor;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black87, width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // ข้อมูลฝั่งซ้าย
          Expanded(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13.5,
                height: 1.35,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line('Borrower : ', borrower),
                  _line('Book : ', book),
                  _line('From : ', from),
                  _line('To : ', to),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Status :  ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 160,
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEDE9E8),
                        side: const BorderSide(color: Colors.black87, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: onAction,
                      child: const Text(
                        'Get Return',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          const SizedBox(width: 12),

          // รูปหนังสือฝั่งขวา
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'Picture/Book.png', // << ใช้ path ที่ให้มา
              width: 80,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 80,
                height: 110,
                color: const Color(0xFFE5E5E5),
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
