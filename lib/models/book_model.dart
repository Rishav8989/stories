class Book {
  final String collectionId;
  final String collectionName;
  final String id;
  final String title;
  final String author;
  final String status;
  final bool isOriginal;
  final String? parentBook;
  final String? bookCover;
  final List<String> genre;
  final String bookType;
  final DateTime created;
  final DateTime updated;
  final Map<String, dynamic>? expand;

  Book({
    required this.collectionId,
    required this.collectionName,
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.isOriginal,
    this.parentBook,
    this.bookCover,
    required this.genre,
    required this.bookType,
    required this.created,
    required this.updated,
    this.expand,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      collectionId: json['collectionId'],
      collectionName: json['collectionName'],
      id: json['id'],
      title: json['title'],
      author: json['author'],
      status: json['status'],
      isOriginal: json['is_orignal'],
      parentBook: json['parent_book'],
      bookCover: json['book_cover'],
      genre: List<String>.from(json['Genre']),
      bookType: json['book_type'],
      created: DateTime.parse(json['created']),
      updated: DateTime.parse(json['updated']),
      expand: json['expand'] as Map<String, dynamic>?,
    );
  }
}