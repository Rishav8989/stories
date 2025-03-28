import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart';
import 'package:stories/utils/translation/language_selector.dart';
import 'package:stories/utils/translation/locale_controller.dart';
import 'package:stories/utils/theme/theme_controller.dart';
import 'package:stories/utils/translation/translation_service.dart';
import 'package:stories/widgets/logout_button.dart';
import 'package:stories/widgets/view_profile_widget.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LocaleController localeController = Get.put(LocaleController());
    final ThemeController themeController = Get.find<ThemeController>();
    final RxBool showThemeOptions = false.obs;
    const double maxWidth = 400.0;

    return Scaffold(
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
              _buildThemeSelection(context, themeController, showThemeOptions),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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

  Widget _buildThemeSelection(
    BuildContext context,
    ThemeController themeController,
    RxBool showThemeOptions,
  ) {
    return Column(
      children: [
        _buildListTile(
          context: context,
          icon: Icons.color_lens,
          text: 'Select Theme'.tr,
          onTap: () async {
            showThemeOptions.value = !showThemeOptions.value;
            if (showThemeOptions.value) {
              await Future.delayed(const Duration(milliseconds: 300));
            }
          },
        ),
        Obx(() {
          return AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: showThemeOptions.value
                ? Card(
                    margin: const EdgeInsets.all(16.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildThemeOption(
                          context: context,
                          icon: Icons.light_mode,
                          text: 'Light Mode',
                          isSelected:
                              themeController.currentTheme == AppTheme.light,
                          onTap: () {
                            themeController.switchToLightTheme();
                            showThemeOptions.value = false;
                          },
                        ),
                        _buildThemeOption(
                          context: context,
                          icon: Icons.dark_mode,
                          text: 'Dark Mode',
                          isSelected:
                              themeController.currentTheme == AppTheme.dark,
                          onTap: () {
                            themeController.switchToDarkTheme();
                            showThemeOptions.value = false;
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          );
        }),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isSelected,
    required Function() onTap,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? Colors.blue : Theme.of(context).iconTheme.color,
          size: 28),
      title: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.blue, size: 24)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthController authController) {
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
                    style: TextStyle(
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
