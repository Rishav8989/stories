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
      );
      
      return result.items.map((item) => DiscussionMessage.fromJson(item.toJson())).toList();
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
      return DiscussionMessage.fromJson(record.toJson());
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
    _pb.collection('discussion_room').subscribe('*', (e) {
      if (e.action == 'create' && e.record?.getStringValue('book') == bookId) {
        onNewMessage(DiscussionMessage.fromJson(e.record!.toJson()));
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