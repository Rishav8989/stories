import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/utils/theme/theme_controller.dart';

class ThemeSelectorPage extends StatelessWidget {
  const ThemeSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Theme'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildThemeListTile(
              context,
              'Light Reading'.tr,
              'Optimized for daytime reading'.tr,
              Icons.light_mode,
              themeController.switchToLightReadingTheme,
              themeController.selectedTheme == AppTheme.lightReading,
            ),
            _buildThemeListTile(
              context,
              'Sepia'.tr,
              'Warm, eye-friendly reading mode'.tr,
              Icons.filter_vintage,
              themeController.switchToSepiaTheme,
              themeController.selectedTheme == AppTheme.sepia,
            ),
            _buildThemeListTile(
              context,
              'Dark Reading'.tr,
              'Optimized for nighttime reading'.tr,
              Icons.dark_mode,
              themeController.switchToDarkReadingTheme,
              themeController.selectedTheme == AppTheme.darkReading,
            ),
            _buildThemeListTile(
              context,
              'AMOLED Dark'.tr,
              'True black for AMOLED screens'.tr,
              Icons.brightness_2,
              themeController.switchToAmoledDarkTheme,
              themeController.selectedTheme == AppTheme.amoledDark,
            ),
            _buildThemeListTile(
              context,
              'High Contrast'.tr,
              'Enhanced readability'.tr,
              Icons.contrast,
              themeController.switchToHighContrastTheme,
              themeController.selectedTheme == AppTheme.highContrast,
            ),
            _buildThemeListTile(
              context,
              'Paper White'.tr,
              'Natural paper-like reading experience'.tr,
              Icons.description,
              themeController.switchToPaperWhiteTheme,
              themeController.selectedTheme == AppTheme.paperWhite,
            ),
            _buildThemeListTile(
              context,
              'Night Light'.tr,
              'Reduced blue light for night reading'.tr,
              Icons.nightlight_round,
              themeController.switchToNightLightTheme,
              themeController.selectedTheme == AppTheme.nightLight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeListTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Function() onTap,
    bool isSelected,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Icon(
          isSelected ? Icons.check_circle : icon,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
} 