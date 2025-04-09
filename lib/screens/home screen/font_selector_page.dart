import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/font_controller.dart';

class FontSelectorPage extends StatelessWidget {
  const FontSelectorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final fontController = Get.find<FontController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Font'.tr),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFontListTile(
              context,
              'Roboto',
              'Default system font',
              fontController.switchToRoboto,
              fontController.selectedFont.value == 'Roboto',
            ),
            _buildFontListTile(
              context,
              'Open Sans',
              'Clean and modern',
              fontController.switchToOpenSans,
              fontController.selectedFont.value == 'Open Sans',
            ),
            _buildFontListTile(
              context,
              'Lato',
              'Professional and elegant',
              fontController.switchToLato,
              fontController.selectedFont.value == 'Lato',
            ),
            _buildFontListTile(
              context,
              'Merriweather',
              'Classic serif font',
              fontController.switchToMerriweather,
              fontController.selectedFont.value == 'Merriweather',
            ),
            _buildFontListTile(
              context,
              'Noto Sans',
              'Great for multiple languages',
              fontController.switchToNotoSans,
              fontController.selectedFont.value == 'Noto Sans',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontListTile(
    BuildContext context,
    String title,
    String subtitle,
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
          isSelected ? Icons.check_circle : Icons.font_download,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: title,
              ),
        ),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
} 