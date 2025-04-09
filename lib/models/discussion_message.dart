class DiscussionMessage {
  final String id;
  final String userId;
  final String bookId;
  final String message;
  final DateTime createdAt;
  final String userName;
  final String? userAvatar;
  final String? replyTo;
  final String? replyToUserName;
  final String? replyToMessage;

  DiscussionMessage({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.message,
    required this.createdAt,
    required this.userName,
    this.userAvatar,
    this.replyTo,
    this.replyToUserName,
    this.replyToMessage,
  });

  factory DiscussionMessage.fromJson(Map<String, dynamic> json) {
    return DiscussionMessage(
      id: json['id'] as String,
      userId: json['user'] as String,
      bookId: json['book'] as String,
      message: json['message'] as String,
      createdAt: DateTime.parse(json['created'] as String),
      userName: json['user_name'] as String? ?? 'Unknown User',
      userAvatar: json['user_avatar'] as String?,
      replyTo: json['reply_to'] as String?,
      replyToUserName: json['reply_to_user_name'] as String?,
      replyToMessage: json['reply_to_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': userId,
      'book': bookId,
      'message': message,
      'user_name': userName,
      'user_avatar': userAvatar,
      'reply_to': replyTo,
      'reply_to_user_name': replyToUserName,
      'reply_to_message': replyToMessage,
    };
  }
} 