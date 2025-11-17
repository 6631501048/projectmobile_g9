import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.49.1:3000';

class Book {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final String status;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.status,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final img = (json['image'] as String?)?.trim();
    return Book(
      id: json['id'],
      title: json['title'] ?? '-',
      author: json['author'] ?? '-',
      imageUrl: img == null || img.isEmpty
          ? '$baseUrl/images/default.png'
          : '$baseUrl/images/$img',
      status: json['status'] ?? 'available',
    );
  }
}

class BorrowRequest {
  final int id;
  final int bookId;
  final String borrower;
  final String fromDate;
  final String toDate;
  final String status;
  final String rejectReason; 

  BorrowRequest({
    required this.id,
    required this.bookId,
    required this.borrower,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.rejectReason, 
  });

  factory BorrowRequest.fromJson(Map<String, dynamic> json) {
    return BorrowRequest(
      id: json['id'] ?? json['borrow_id'],
      bookId: json['book_id'] ?? 0,
      borrower: json['borrower'] ?? '-',
      fromDate: json['from'] ?? json['borrow_date'] ?? '-',
      toDate: json['to'] ?? json['return_date'] ?? '-',
      status: json['status'] ?? 'pending',
      rejectReason: json['reject_reason'] ?? '-',
    );
  }
}
