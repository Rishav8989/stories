class ChapterModel {
  final String id;
  final String title;
  final String content;
  final String book;
  final String type;
  final String status;
  final int orderNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterModel({
    this.id = '',
    this.title = '',
    this.content = '',
    this.book = '',
    this.type = 'content',
    this.status = 'draft',
    this.orderNumber = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      book: json['book'] ?? '',
      type: json['type'] ?? 'content',
      status: json['status'] ?? 'draft',
      orderNumber: json['order_number'] ?? 0,
      createdAt: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'book': book,
      'type': type,
      'status': status,
      'order_number': orderNumber,
      'created': createdAt.toIso8601String(),
      'updated': updatedAt.toIso8601String(),
    };
  }
} 