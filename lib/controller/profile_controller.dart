import 'dart:convert';
import 'package:get/get.dart';
import '../utils/user_service.dart';
import 'package:http/http.dart' as http;

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
}
