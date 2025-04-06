import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:stories/utils/app_initializer.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';

@GenerateNiceMocks([MockSpec<ThemeController>()])
import 'app_initializer_test.mocks.dart';

void main() {
  late MockThemeController mockThemeController;
  
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockThemeController = MockThemeController();
    when(mockThemeController.initialized).thenReturn(true);
    when(mockThemeController.isClosed).thenReturn(false);
    when(mockThemeController.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(mockThemeController.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(mockThemeController.onInit()).thenAnswer((_) async {});
    
    Get.put<ThemeController>(mockThemeController);

    // Mock plugin channels
    const MethodChannel('dev.fluttercommunity.plus/connectivity')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'check') {
        return 1; // ConnectivityResult.wifi.index
      }
      return null;
    });
    
    const MethodChannel('plugins.flutter.io/shared_preferences')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return <String, dynamic>{};
      }
      return null;
    });
  });

  tearDown(() {
    Get.reset();
  });

  group('AppInitializer Tests', () {
    test('init should initialize required dependencies', () async {
      await AppInitializer.init();
      expect(Get.find<ThemeController>(), isNotNull);
    });

    test('should handle initialization errors gracefully', () async {
      try {
        await AppInitializer.init();
      } catch (e) {
        fail('Should not throw: $e');
      }
    });
  });
}