class BookModel {
  final String id;
  final String collectionId;
  final String collectionName;
  final String title;
  final String description;
  final String author;
  final String coverImage;
  final String? bookCover;
  final String status;
  final bool isOriginal;
  final String? parentBook;
  final List<String> genre;
  final String bookType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? expand;

  BookModel({
    this.id = '',
    this.collectionId = '',
    this.collectionName = '',
    this.title = '',
    this.description = '',
    this.author = '',
    this.coverImage = '',
    this.bookCover,
    this.status = 'draft',
    this.isOriginal = true,
    this.parentBook,
    this.genre = const [],
    this.bookType = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.expand,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] ?? '',
      collectionId: json['collectionId'] ?? '',
      collectionName: json['collectionName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      coverImage: json['cover_image'] ?? '',
      bookCover: json['book_cover'],
      status: json['status'] ?? 'draft',
      isOriginal: json['is_original'] ?? true,
      parentBook: json['parent_book'],
      genre: List<String>.from(json['Genre'] ?? []),
      bookType: json['book_type'] ?? '',
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
      expand: json['expand'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionId': collectionId,
      'collectionName': collectionName,
      'title': title,
      'description': description,
      'author': author,
      'cover_image': coverImage,
      'book_cover': bookCover,
      'status': status,
      'is_original': isOriginal,
      'parent_book': parentBook,
      'Genre': genre,
      'book_type': bookType,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt.toIso8601String(),
      'expand': expand,
    };
  }
}