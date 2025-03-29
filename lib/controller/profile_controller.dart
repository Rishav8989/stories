import 'dart:convert';
import 'package:get/get.dart';
import '../utils/user_service.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart'; // For image picking [[4]]

class ProfileController extends GetxController {
  final Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({});
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

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
        'http://rishavpocket.duckdns.org/api/collections/users/records',
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

  // New avatar upload method [[4]][[9]]
Future<void> uploadUserProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final userService = Get.find<UserService>();
      final token = await userService.getAuthToken();
      final userId = await userService.getUserId();

      if (token == null || userId == null) {
        throw Exception('Authentication token or user ID not found');
      }

      // First, get the user's current record
      final getUserUrl = Uri.parse(
        'http://rishavpocket.duckdns.org/api/collections/users/records/$userId',
      );
      final userResponse = await http.get(
        getUserUrl,
        headers: {'Authorization': token},
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to get user record');
      }

      final userData = json.decode(userResponse.body);
      final collectionId = userData['collectionId'];

      // Then, upload the avatar using the correct endpoint
      final uploadUrl = Uri.parse(
        'http://rishavpocket.duckdns.org/api/collections/$collectionId/records/$userId',
      );

      var request = http.MultipartRequest('PATCH', uploadUrl)
        ..headers['Authorization'] = token
        ..files.add(await http.MultipartFile.fromPath('avatar', pickedFile.path));

      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        await fetchUserData(); // Refresh data after update
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}\n$responseStr');
      }
    } catch (e) {
      error.value = 'Upload failed: ${e.toString()}';
      print('Upload error: $e'); // For debugging
    }
  }
}