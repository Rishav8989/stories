import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/controller/auth_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the AuthController
    Get.find<AuthController>();
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
