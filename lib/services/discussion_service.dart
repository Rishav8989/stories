import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/discussion_message.dart';
import '../models/discussion_rules.dart';

class DiscussionService {
  late final PocketBase _pb;
  bool _isSubscribed = false;
  String? _currentBookId;
  Function(DiscussionMessage)? _onNewMessage;
  Function(DiscussionMessage)? _onMessageUpdate;
  Function(DiscussionMessage)? _onMessageDelete;

  DiscussionService() {
    _pb = Get.find<PocketBase>();
  }

  Future<List<DiscussionMessage>> getMessages(
    String bookId, {
    int limit = 50,
    String? beforeMessageId,
  }) async {
    try {
      print('Fetching messages for book: $bookId');
      final result = await _pb.collection('discussion_room').getFullList(
        filter: 'book = "$bookId"',
        sort: '-created',
        expand: 'user',
      );
      
      print('Found ${result.length} messages');
      
      final messages = result.map((item) {
        final user = item.expand?['user'] as List<dynamic>?;
        final userName = user?.isNotEmpty == true 
            ? (user![0] as RecordModel).getStringValue('name') ?? 'Unknown User'
            : 'Unknown User';
        final userAvatar = user?.isNotEmpty == true 
            ? (user![0] as RecordModel).getStringValue('avatar')
            : null;
            
        final message = DiscussionMessage.fromJson({
          ...item.toJson(),
          'user_name': userName,
          'user_avatar': userAvatar,
        });
        print('Message: ${message.id} - ${message.message} - ${message.createdAt}');
        return message;
      }).toList();
      
      print('Successfully converted ${messages.length} messages');
      return messages;
    } catch (e) {
      print('Error fetching messages: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<DiscussionMessage> sendMessage(
    String userId,
    String bookId,
    String message, {
    String? replyTo,
  }) async {
    try {
      final data = {
        'user': userId,
        'book': bookId,
        'message': message,
        if (replyTo != null) 'reply_to': replyTo,
      };

      final record = await _pb.collection('discussion_room').create(body: data);
      
      // Try to get user info, but don't fail if user not found
      String userName = 'Unknown User';
      String? userAvatar;
      String? replyToUserName;
      String? replyToMessage;
      
      try {
        final user = await _pb.collection('users').getOne(userId);
        userName = user.getStringValue('name') ?? 'Unknown User';
        userAvatar = user.getStringValue('avatar');

        if (replyTo != null) {
          try {
            final replyToRecord = await _pb.collection('discussion_room').getOne(replyTo);
            final replyToUser = await _pb.collection('users').getOne(replyToRecord.getStringValue('user'));
            replyToUserName = replyToUser.getStringValue('name') ?? 'Unknown User';
            replyToMessage = replyToRecord.getStringValue('message');
          } catch (e) {
            print('Error fetching reply info: $e');
          }
        }
      } catch (e) {
        print('Error fetching user info: $e');
      }
      
      return DiscussionMessage.fromJson({
        ...record.toJson(),
        'user_name': userName,
        'user_avatar': userAvatar,
        'reply_to_user_name': replyToUserName,
        'reply_to_message': replyToMessage,
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _pb.collection('discussion_room').delete(messageId);
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  void subscribeToMessages(
    String bookId, {
    required Function(DiscussionMessage) onNewMessage,
    Function(DiscussionMessage)? onMessageUpdate,
    Function(DiscussionMessage)? onMessageDelete,
  }) {
    if (_isSubscribed && _currentBookId == bookId) {
      return; // Already subscribed to this book
    }

    // Unsubscribe from previous subscription if exists
    unsubscribe();

    _currentBookId = bookId;
    _onNewMessage = onNewMessage;
    _onMessageUpdate = onMessageUpdate;
    _onMessageDelete = onMessageDelete;
    _isSubscribed = true;

    // Subscribe to all changes in the discussion_room collection
    _pb.collection('discussion_room').subscribe('*', (e) async {
      if (e.record?.getStringValue('book') != bookId) return;

      try {
        String userName = 'Unknown User';
        String? userAvatar;
        String? replyToUserName;
        String? replyToMessage;

        try {
          final user = await _pb.collection('users').getOne(e.record!.getStringValue('user'));
          userName = user.getStringValue('name') ?? 'Unknown User';
          userAvatar = user.getStringValue('avatar');

          if (e.record!.getStringValue('reply_to') != null) {
            try {
              final replyToRecord = await _pb.collection('discussion_room').getOne(e.record!.getStringValue('reply_to'));
              final replyToUser = await _pb.collection('users').getOne(replyToRecord.getStringValue('user'));
              replyToUserName = replyToUser.getStringValue('name') ?? 'Unknown User';
              replyToMessage = replyToRecord.getStringValue('message');
            } catch (e) {
              print('Error fetching reply info: $e');
            }
          }
        } catch (e) {
          print('Error fetching user info: $e');
        }

        final message = DiscussionMessage.fromJson({
          ...e.record!.toJson(),
          'user_name': userName,
          'user_avatar': userAvatar,
          'reply_to_user_name': replyToUserName,
          'reply_to_message': replyToMessage,
        });

        switch (e.action) {
          case 'create':
            _onNewMessage?.call(message);
            break;
          case 'update':
            _onMessageUpdate?.call(message);
            break;
          case 'delete':
            _onMessageDelete?.call(message);
            break;
        }
      } catch (e) {
        print('Error processing real-time update: $e');
      }
    }, filter: 'book = "$bookId"');
  }

  void unsubscribe() {
    if (_isSubscribed) {
      _pb.collection('discussion_room').unsubscribe();
      _isSubscribed = false;
      _currentBookId = null;
      _onNewMessage = null;
      _onMessageUpdate = null;
      _onMessageDelete = null;
    }
  }

  Future<DiscussionRules?> getDiscussionRules(String bookId) async {
    try {
      final record = await _pb.collection('discussion_rules').getFirstListItem('book="$bookId"');
      return DiscussionRules.fromJson(record.toJson());
    } catch (e) {
      print('Error fetching discussion rules: $e');
      return null;
    }
  }

  Future<void> createOrUpdateDiscussionRules(String bookId, String userId, String rules) async {
    try {
      final data = {
        'user': userId,
        'book': bookId,
        'rules': rules,
      };

      final existingRecord = await getDiscussionRules(bookId);
      if (existingRecord != null) {
        await _pb.collection('discussion_rules').update(existingRecord.id, body: data);
      } else {
        await _pb.collection('discussion_rules').create(body: data);
      }
    } catch (e) {
      print('Error creating/updating discussion rules: $e');
      rethrow;
    }
  }
} 