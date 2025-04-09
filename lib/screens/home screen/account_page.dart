import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/auth_controller.dart';
import 'package:stories/controller/font_controller.dart';
import 'package:stories/screens/home screen/theme_selector_page.dart';
import 'package:stories/utils/translation/language_selector.dart';
import 'package:stories/utils/translation/locale_controller.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/widgets/logout_button.dart';
import 'package:stories/widgets/view_profile_widget.dart';
import 'package:stories/widgets/font_selector.dart';
import 'package:stories/screens/home screen/font_selector_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LocaleController localeController = Get.put(LocaleController());
    final ThemeController themeController = Get.find<ThemeController>();
    final FontController fontController = Get.put(FontController());
    const double maxWidth = 400.0;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Account Settings'.tr)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildListTile(
                context: context,
                icon: Icons.person,
                text: 'View Profile'.tr,
                onTap: () {
                  Get.to(() => const ProfileLandingPage());
                },
              ),
              _buildListTile(
                context: context,
                icon: Icons.security,
                text: 'Account Security'.tr,
                onTap: () {},
              ),
              _buildListTile(
                context: context,
                icon: Icons.language,
                text: 'Select Language'.tr,
                onTap: () => Get.to(() => const LanguageSelectionPage()),
              ),
              _buildListTile(
                context: context,
                icon: Icons.palette,
                text: 'Theme'.tr,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSelectorPage(),
                    ),
                  );
                },
              ),
              _buildListTile(
                context: context,
                icon: Icons.font_download,
                text: 'Font'.tr,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FontSelectorPage(),
                    ),
                  );
                },
              ),
              _buildListTile(
                context: context,
                icon: Icons.info,
                text: 'About This Project'.tr,
                onTap: () {},
              ),
              _buildLogoutButton(context, authController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Icon(icon, size: 32, color: Theme.of(context).iconTheme.color),
        title: Text(
          text,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    AuthController authController,
  ) {
    return Center(
      child: SizedBox(
        width: 240,
        child: Card(
          color: Colors.red,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: InkWell(
            onTap: () => LogoutService.performLogout(authController),
            borderRadius: BorderRadius.circular(20.0),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout,
                    color: Theme.of(context).iconTheme.color,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Logout'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
