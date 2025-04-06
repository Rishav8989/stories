import 'dart:convert';
import 'package:get/get.dart';
import '../utils/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;
  final String baseUrl = dotenv.get('POCKETBASE_URL');

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      isLoading.value = true;
      final userService = Get.find<UserService>();
      final token = await userService.getAuthToken();

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final url = Uri.parse(
        '$baseUrl/api/collections/users/records',
      );
      final headers = {'Authorization': token};

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        userData.value = json.decode(response.body);
        error.value = '';
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String? getProfileImageUrl(String? avatarName) {
    if (avatarName == null || avatarName.isEmpty) return null;
    final userId = userData.value['id'];
    if (userId == null) return null;
    
    return '$baseUrl/api/files/_pb_users_auth_/$userId/$avatarName';
  }

  Future<void> uploadUserProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile == null) return;

      isLoading.value = true;
      final userService = Get.find<UserService>();
      final token = await userService.getAuthToken();
      final userId = await userService.getUserId();

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$baseUrl/api/collections/users/records/$userId'),
      )
        ..headers['Authorization'] = token
        ..files.add(
          await http.MultipartFile.fromPath('avatar', pickedFile.path),
        );

      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        await fetchUserData();
      } else {
        throw Exception(
          'Failed to upload image: ${response.statusCode}\n$responseStr',
        );
      }
    } catch (e) {
      error.value = 'Upload failed: ${e.toString()}';
      // debugPrint('Upload error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
