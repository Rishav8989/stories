import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart';
import 'package:stories/widgets/logout_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the AuthController using Get.find()
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              LogoutService.performLogout(authController);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              if (authController.isLoading.value) {
                return const CircularProgressIndicator();
              } else if (authController.isLoggedIn.value) {
                return Text(
                  'Welcome, User ID: ${authController.userId.value ?? 'N/A'}',
                  style: const TextStyle(fontSize: 18),
                );
              } else {
                return const Text('Not logged in.');
              }
            }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final authController = Get.find<AuthController>();
                LogoutService.performLogout(authController);
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}
