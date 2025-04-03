// home.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:stories/utils/create_new_book.dart';

class CreatePage extends StatelessWidget {
  const CreatePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Use GetX for navigation instead of Navigator.push
            Get.to(() => const CreateNewBookPage());
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          child: const Text('Create Book'),
        ),
      ),
    );
  }
}