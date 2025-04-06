import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      appBar: AppBar(
        title: Text('View Profile'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (profileController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (profileController.error.value.isNotEmpty) {
          return Center(child: Text('Error: ${profileController.error.value}'));
        } else if (profileController.userData.value.isEmpty) {
          return const Center(child: Text('No user data available.'));
        }

        final userData = profileController.userData.value['items'] as List<dynamic>;
        final user = userData.isNotEmpty ? userData.first : null;

        if (user == null) {
          return const Center(child: Text('No user data found.'));
        }

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector( // [[1]]
                    onTap: () async {
                      await profileController.uploadUserProfilePicture();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: Stack(
                        children: [
                          Center(
                            child: user['avatar'] != null && user['avatar'].isNotEmpty
                                ? CircleAvatar(
                                    radius: 60,
                                    backgroundImage: NetworkImage(
                                      '${dotenv.get('POCKETBASE_URL')}/api/files/${user['collectionId']}/${user['id']}/${user['avatar']}?thumb=200x200',
                                    ),
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(
                                      Icons.account_circle,
                                      size: 120,
                                      color: Colors.blue,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person, color: Colors.blue, size: 32),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Name', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      user['name'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.email, color: Colors.blue, size: 32),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Email', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      user['email'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.blue, size: 32),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date Joined', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      DateTime.parse(user['created'])
                                          .toLocal()
                                          .toString()
                                          .split('.')
                                          .first,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Icon(
                                  user['verified'] == true
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: user['verified'] == true
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Account Status', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      user['verified'] == true
                                          ? 'Verified'
                                          : 'Not Verified',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}