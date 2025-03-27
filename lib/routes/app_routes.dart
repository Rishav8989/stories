import 'package:get/get.dart';
import 'package:stories/screens/home_page.dart';
import 'package:stories/screens/login_page.dart';
import 'package:stories/screens/registration_page.dart';

class AppRoutes {
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';

  static List<GetPage> get pages => [
        GetPage(
          name: home,
          page: () => const HomePage(),
        ),
        GetPage(
          name: login,
          page: () => const LoginPage(),
        ),
        GetPage(
          name: register,
          page: () => const RegisterPage(),
        ),
      ];
}