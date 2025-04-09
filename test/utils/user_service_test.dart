import 'package:flutter_test/flutter_test.dart';
import 'package:stories/utils/user_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late UserService userService;
  late PocketBase pocketBase;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pocketBase = PocketBase('http://test.example.com');
    userService = UserService(pocketBase);
  });

  group('UserService Tests', () {
    test('getUserId should return null when not set', () async {
      final result = await userService.getUserId();
      expect(result, isNull);
    });

    test('setUserId should store the user ID', () async {
      await userService.setUserId('test_user_id');
      final result = await userService.getUserId();
      expect(result, equals('test_user_id'));
    });

    test('clearUserId should remove the stored user ID', () async {
      await userService.setUserId('test_user_id');
      await userService.clearUserId();
      final result = await userService.getUserId();
      expect(result, isNull);
    });

    test('getAuthToken should return null when not set', () async {
      final result = await userService.getAuthToken();
      expect(result, isNull);
    });

    test('setAuthToken should store the auth token', () async {
      await userService.setAuthToken('test_token');
      final result = await userService.getAuthToken();
      expect(result, equals('test_token'));
    });

    test('clearAuthToken should remove the stored auth token', () async {
      await userService.setAuthToken('test_token');
      await userService.clearAuthToken();
      final result = await userService.getAuthToken();
      expect(result, isNull);
    });

    test('logout should clear both user ID and auth token', () async {
      await userService.setUserId('test_user_id');
      await userService.setAuthToken('test_token');
      
      await userService.logout();
      
      final userId = await userService.getUserId();
      final authToken = await userService.getAuthToken();
      expect(userId, isNull);
      expect(authToken, isNull);
    });
  });
} 