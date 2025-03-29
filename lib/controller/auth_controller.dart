import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/routes/app_routes.dart';
import 'package:stories/utils/user_service.dart';

class AuthController extends GetxController {
  final PocketBase pb;
  final UserService userService = Get.find<UserService>();

  final RxnString userId = RxnString();
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Constructor that requires PocketBase instance
  AuthController(this.pb);

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
    ever(userId, _handleAuthChange);
  }

  Future<void> _initializeAuth() async {
    isLoading.value = true;
    try {
      final cachedToken = await userService.getAuthToken();
      final cachedUserId = await userService.getUserId();

      if (cachedToken != null) {
        pb.authStore.save(cachedToken, null);
      }
      userId.value = cachedUserId;

      await _checkAuth();
    } catch (e) {
      print('Error during initialization: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _checkAuth() async {
    if (pb.authStore.isValid) {
      try {
        await pb.collection('users').authRefresh();
        userId.value = pb.authStore.model?.id;
        isLoggedIn.value = true;
      } catch (e) {
        await logout();
      }
    } else {
      isLoggedIn.value = false;
    }
  }

  void _handleAuthChange(String? user) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentRoute = Get.currentRoute;
      if (user == null && currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      } else if (user != null && currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final authData = await pb.collection('users').authWithPassword(
        email.trim(),
        password.trim(),
      );

      await userService.setAuthToken(pb.authStore.token);
      await userService.setUserId(authData.record.id);

      userId.value = authData.record.id;
      isLoggedIn.value = true;
    } catch (e) {
      errorMessage.value = 'Login failed. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      pb.authStore.clear();
      await userService.clearAuthToken();
      await userService.clearUserId();

      userId.value = null;
      isLoggedIn.value = false;

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('Error during logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String email, String password, String username) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "passwordConfirm": password,
        "name": username,
      };

      // Call PocketBase API to create a new user
      await pb.collection('users').create(body: body);

      // Show success message
      Get.snackbar(
        'Success',
        'Registration successful! Please log in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Navigate to the login page
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      errorMessage.value = 'Registration failed. Please try again.';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}