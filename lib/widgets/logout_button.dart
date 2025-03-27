import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stories/auth_controller.dart';

class LogoutService {
  static Future<void> performLogout(AuthController authController) async {
    bool? confirmLogout = await _showLogoutConfirmation();

    if (confirmLogout == true) {
      // Show loading indicator during logout
      authController.isLoading.value = true;

      try {
        // Call the logout method from AuthController
        await authController.logout();

        // Notify user of successful logout
        Get.snackbar(
          'Logout Successful',
          'You have been logged out.',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error during logout: $e');
        Get.snackbar(
          'Logout Failed',
          'An error occurred while logging out.',
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        authController.isLoading.value = false;
      }
    } else if (confirmLogout == false) {
      print('Logout cancelled');
      Get.snackbar(
        'Logout Cancelled',
        'Logout action was cancelled',
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      print('Logout dialog dismissed without choice');
    }
  }

  static Future<bool?> _showLogoutConfirmation() async {
    return await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("Yes"),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}