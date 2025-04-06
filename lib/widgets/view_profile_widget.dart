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
                  profileController.buildAvatarWidget(context, user),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 1,  // Reduced from 2
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context: context,
                              icon: Icons.person,
                              label: 'Name',
                              value: user['name'] ?? 'Unknown',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: Icons.email,
                              label: 'Email',
                              value: user['email'] ?? 'Unknown',
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: Icons.calendar_today,
                              label: 'Date Joined',
                              value: DateTime.parse(user['created'])
                                  .toLocal()
                                  .toString()
                                  .split('.')
                                  .first,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              context: context,
                              icon: user['verified'] == true
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              iconColor: user['verified'] == true
                                  ? Colors.green
                                  : Colors.red,
                              label: 'Account Status',
                              value: user['verified'] == true
                                  ? 'Verified'
                                  : 'Not Verified',
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

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 28,  // Reduced from 32
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }
}