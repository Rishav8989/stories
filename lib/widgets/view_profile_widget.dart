import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/profile_controller.dart';

class ProfileLandingPage extends StatelessWidget {
  const ProfileLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize the controller if it's not already initialized
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

        final userData =
            profileController.userData.value['items'] as List<dynamic>;
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
                  Container(

                    child: Center(
                      child: user['avatar'] != null && user['avatar'].isNotEmpty
                          ? CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(
                                'http://rishavpocket.duckdns.org/api/files/${user['collectionId']}/${user['id']}/${user['avatar']}',
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
                            // Custom ListTile with subtitle on top
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

                            // Custom ListTile with subtitle on top
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

                            // Custom ListTile with subtitle on top
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

                            // Custom ListTile with subtitle on top
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