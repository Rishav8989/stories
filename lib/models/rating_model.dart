class RatingModel {
  final String id;
  final String user;
  final String book;
  final int rating;
  final String? reviewComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatingModel({
    this.id = '',
    required this.user,
    required this.book,
    required this.rating,
    this.reviewComment,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] ?? '',
      user: json['user'] ?? '',
      book: json['book'] ?? '',
      rating: int.parse(json['rating'] ?? '0'),
      reviewComment: json['review_comment'],
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'book': book,
      'rating': rating.toString(),
      'review_comment': reviewComment,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt.toIso8601String(),
    };
  }
} 