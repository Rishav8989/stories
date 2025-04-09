class DiscussionMessage {
  final String id;
  final String userId;
  final String bookId;
  final String message;
  final DateTime createdAt;

  DiscussionMessage({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.message,
    required this.createdAt,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'] as String,
      userId: json['user'] as String,
      bookId: json['book'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'book': bookId,
      'message': message,
    };
  }
} 