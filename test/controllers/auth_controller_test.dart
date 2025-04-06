import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:stories/controller/auth_controller.dart';
import 'package:pocketbase/pocketbase.dart';

@GenerateNiceMocks([
  MockSpec<PocketBase>(),
  MockSpec<RecordService>(),
  MockSpec<RecordAuth>(),
  MockSpec<AuthStore>(),
  MockSpec<RecordModel>(), // Changed from Record to RecordModel
])
import 'auth_controller_test.mocks.dart';

void main() {
  late AuthController authController;
  late MockPocketBase mockPb;
  late MockRecordService mockRecordService;
  late MockRecordAuth mockRecordAuth;
  late MockRecordModel mockRecord; // Changed from MockRecord to MockRecordModel
  late MockAuthStore mockAuthStore;

  setUp(() {
    mockPb = MockPocketBase();
    mockRecordService = MockRecordService();
    mockRecordAuth = MockRecordAuth();
    mockRecord = MockRecordModel(); // Changed from MockRecord to MockRecordModel
    mockAuthStore = MockAuthStore();
    
    // Setup mock chain
    when(mockPb.collection(any)).thenReturn(mockRecordService);
    when(mockPb.authStore).thenReturn(mockAuthStore);
    when(mockRecordService.authWithPassword(any, any))
        .thenAnswer((_) async => mockRecordAuth);
    when(mockRecordAuth.record).thenReturn(mockRecord);
    when(mockRecord.id).thenReturn('test_id');
    when(mockRecord.data).thenReturn({
      'email': 'test@email.com',
      'id': 'test_id'
    });
    
    authController = AuthController(mockPb);
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController Tests', () {
    test('initial values should be correct', () {
      expect(authController.isLoggedIn.value, false);
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');
    });

    test('login should update state correctly', () async {
      when(mockRecordAuth.token).thenReturn('test_token');

      await authController.login('test@email.com', 'password');
      
      expect(authController.isLoggedIn.value, true);
      expect(authController.errorMessage.value, '');
      expect(authController.userId.value, 'test_id');
    });

    test('login should handle errors', () async {
      when(mockRecordService.authWithPassword(any, any))
          .thenThrow(ClientException(
            url: Uri.parse('http://example.com'),
            statusCode: 400,
            response: {'message': 'Invalid credentials'},
            isAbort: false,
          ));

      await authController.login('test@email.com', 'wrong_password');
      
      expect(authController.isLoggedIn.value, false);
      expect(authController.errorMessage.value, isNotEmpty);
    });

    test('logout should clear auth state', () async {
      authController.isLoggedIn.value = true;
      authController.userId.value = 'test_id';
      
      await authController.logout();
      
      expect(authController.isLoggedIn.value, false);
      expect(authController.userId.value, null);
      verify(mockAuthStore.clear()).called(1);
    });
  });
}