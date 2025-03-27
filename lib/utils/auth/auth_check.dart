// auth_check.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart'; // Import AuthController

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize AuthController if it's not already initialized
    Get.put(AuthController());

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show loading indicator while checking auth
      ),
    );
  }
}