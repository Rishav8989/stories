import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart';
import 'package:stories/utils/translation/language_selector.dart';
import 'package:stories/utils/translation/locale_controller.dart';
import 'package:stories/utils/translation/translation_service.dart';
import 'package:stories/widgets/logout_button.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LocaleController localeController = Get.put(LocaleController());

    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('view_profile'.tr),
            onTap: () {
              // Navigate to profile page
            },
          ),
          ListTile(
            leading: const Icon(Icons.security),
            title: Text('account_security'.tr),
            onTap: () {
              // Navigate to account security page
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Select Language'.tr),
            onTap: () {
              Get.to(() => const LanguageSelectionPage());
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text('About This Project'.tr),
            onTap: () {
              // Navigate to about page
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('Logout'.tr),
            onTap: () {
              LogoutService.performLogout(authController);
            },
          ),
        ],
      ),
    );
  }
}
