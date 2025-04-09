import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/font_controller.dart';

class FontSelector extends StatelessWidget {
  final FontController fontController;

  const FontSelector({
    Key? key,
    required this.fontController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: const Icon(Icons.font_download, size: 32),
        title: Text(
          'Select Font'.tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Obx(() => Text(
          fontController.selectedFont,
          style: Theme.of(context).textTheme.bodyMedium,
        )),
        onTap: () => _showFontSelectionDialog(context),
      ),
    );
  }

  void _showFontSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Font'.tr),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: fontController.availableFonts.length,
            itemBuilder: (context, index) {
              final font = fontController.availableFonts[index];
              return ListTile(
                title: Text(
                  font,
                  style: TextStyle(
                    fontFamily: font,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  fontController.changeFont(font);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
} 