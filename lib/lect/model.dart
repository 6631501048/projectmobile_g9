class Book {
  final String id;
  final String title;
  final String imageUrl;
  final String author;

  Book({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.author,
  });
}

class BorrowRequest {
  final String id;
  final String bookId;
  final String userName;
  final String fromDate;
  final String toDate;
  String status; // Not final, can be changed

  BorrowRequest({
    required this.id,
    required this.bookId,
    required this.userName,
    required this.fromDate,
    required this.toDate,
    required this.status,
  });
}

// --- Mock Data ---

final List<Book> mockBooks = [
  Book(
    id: 'b1',
    title: 'เรือนแรกสีแดง (The Red House Mystery)',
    author: 'A. A. Milne',
    imageUrl:
        'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1388214848i/78182.jpg',
  ),
  Book(
    id: 'b2',
    title: 'Learning Python',
    author: 'Mark Lutz',
    imageUrl: 'https://i.ebayimg.com/images/g/glsAAOSw~HFg~p~D/s-l1600.jpg',
  ),
  Book(
    id: 'b3',
    title: 'Flutter พัฒนาแอปพลิเคชัน',
    author: 'Tech Course',
    imageUrl:
        'https://storage.naiin.com/system/application/bookstore/resource/product/202206/554900/1000277329_front_xxl.jpg?v=1655092040',
  ),
  Book(
    id: 'b4',
    title: 'Clean Architecture in Flutter',
    author: 'Code With Andrea',
    imageUrl:
        'https://m.media-amazon.com/images/I/71k4q3y4g6L._AC_UF1000,1000_QL80_.jpg',
  ),
  Book(
    id: 'b5',
    title: 'Dart Programming',
    author: 'Google',
    imageUrl:
        'https://static.packt-cdn.com/products/9781783989910/cover/smaller',
  ),
];

final List<BorrowRequest> mockRequests = [
  BorrowRequest(
    id: 'r1',
    bookId: 'b1',
    userName: 'Kwan',
    fromDate: '5/10/2025',
    toDate: '12/10/2025',
    status: 'pending',
  ),
  BorrowRequest(
    id: 'r2',
    bookId: 'b1',
    userName: 'Somchai',
    fromDate: '13/10/2025',
    toDate: '20/10/2025',
    status: 'pending',
  ),
  BorrowRequest(
    id: 'r3',
    bookId: 'b2',
    userName: 'Jane',
    fromDate: '8/10/2025',
    toDate: '15/10/2025',
    status: 'pending',
  ),
  BorrowRequest(
    id: 'r4',
    bookId: 'b3',
    userName: 'นาย A (Lecturer)',
    fromDate: '10/10/2025',
    toDate: '19 ต.ค.',
    status: 'pending',
  ),
  BorrowRequest(
    id: 'r5',
    bookId: 'b4',
    userName: 'นางสาว B (Staff)',
    fromDate: '11/10/2025',
    toDate: '18 ต.ค.',
    status: 'pending',
  ),
  BorrowRequest(
    id: 'r6',
    bookId: 'b5',
    userName: 'Peter',
    fromDate: '1/10/2025',
    toDate: '8/10/2025',
    status: 'approved',
  ),
];