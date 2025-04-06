import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:stories/main.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@GenerateNiceMocks([MockSpec<ThemeController>()])
import 'app_test.mocks.dart';

void main() {
  late MockThemeController mockThemeController;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env.test");
    Get.testMode = true;
  });

  setUp(() {
    mockThemeController = MockThemeController();
    
    // Mock all required methods
    when(mockThemeController.themeMode).thenReturn(ThemeMode.light);
    when(mockThemeController.initialized).thenReturn(true);
    when(mockThemeController.isClosed).thenReturn(false);
    when(mockThemeController.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(mockThemeController.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(mockThemeController.onInit()).thenAnswer((_) async {});
    
    Get.put<ThemeController>(mockThemeController, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  group('MyApp Widget Tests', () {
    testWidgets('MyApp should initialize with correct theme', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      expect(find.text('Stories App'), findsOneWidget);
    });

    testWidgets('MyApp should use light theme by default', (tester) async {
      when(mockThemeController.themeMode).thenReturn(ThemeMode.light);
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      expect(Theme.of(context).brightness, equals(Brightness.light));
    });

    testWidgets('MyApp should handle dark theme', (tester) async {
      when(mockThemeController.themeMode).thenReturn(ThemeMode.dark);
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      expect(Theme.of(context).brightness, equals(Brightness.dark));
    });

    testWidgets('MyApp should use system locale', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      expect(Localizations.localeOf(context), isNotNull);
    });

    testWidgets('MyApp should handle theme changes', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      when(mockThemeController.themeMode).thenReturn(ThemeMode.dark);
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(MaterialApp));
      expect(Theme.of(context).brightness, equals(Brightness.dark));
    });

    testWidgets('MyApp should initialize with correct routes', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final app = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(app.initialRoute, isNotNull);
      expect(app.getPages, isNotNull);
    });

    testWidgets('MyApp should handle system theme mode', (tester) async {
      when(mockThemeController.themeMode).thenReturn(ThemeMode.system);
      
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final app = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(app.themeMode, equals(ThemeMode.system));
    });

    testWidgets('MyApp should not show debug banner', (tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      final app = tester.widget<GetMaterialApp>(find.byType(GetMaterialApp));
      expect(app.debugShowCheckedModeBanner, isFalse);
    });
  });
}