import 'package:pocketbase/pocketbase.dart';
import '../models/discussion_message.dart';
import '../models/discussion_rules.dart';

class DiscussionService {
  static const String _baseUrl = 'https://rishav.pockethost.io';
  final PocketBase _pb = PocketBase(_baseUrl);

  Future<List<DiscussionMessage>> getMessages(String bookId) async {
    try {
      final result = await _pb.collection('discussion_room').getList(
        page: 1,
        perPage: 50,
        filter: 'book = "$bookId"',
        sort: '-created',
        expand: 'user',
      );
      
      return result.items.map((item) {
        final user = item.expand?['user'] as RecordModel?;
        return DiscussionMessage.fromJson({
          ...item.toJson(),
          'user_name': user?.getStringValue('name') ?? 'Unknown User',
          'user_avatar': user?.getStringValue('avatar'),
        });
      }).toList();
    } catch (e) {
      print('Error fetching messages: $e');
      return [];
    }
  }

  Future<DiscussionMessage> sendMessage(String userId, String bookId, String message) async {
    try {
      final data = {
        'user': userId,
        'book': bookId,
        'message': message,
      };

      final record = await _pb.collection('discussion_room').create(body: data);
      
      // Try to get user info, but don't fail if user not found
      String userName = 'Unknown User';
      String? userAvatar;
      try {
        final user = await _pb.collection('users').getOne(userId);
        userName = user.getStringValue('name') ?? 'Unknown User';
        userAvatar = user.getStringValue('avatar');
      } catch (e) {
        print('Error fetching user info: $e');
      }
      
      return DiscussionMessage.fromJson({
        ...record.toJson(),
        'user_name': userName,
        'user_avatar': userAvatar,
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

  void subscribeToMessages(String bookId, Function(DiscussionMessage) onNewMessage) {
    _pb.collection('discussion_room').subscribe('*', (e) async {
      if (e.action == 'create' && e.record?.getStringValue('book') == bookId) {
        String userName = 'Unknown User';
        String? userAvatar;
        try {
          final user = await _pb.collection('users').getOne(e.record!.getStringValue('user'));
          userName = user.getStringValue('name') ?? 'Unknown User';
          userAvatar = user.getStringValue('avatar');
        } catch (e) {
          print('Error fetching user info: $e');
        }
        
        onNewMessage(DiscussionMessage.fromJson({
          ...e.record!.toJson(),
          'user_name': userName,
          'user_avatar': userAvatar,
        }));
      }
    }, filter: 'book = "$bookId"');
  }

  void unsubscribe() {
    _pb.collection('discussion_room').unsubscribe();
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