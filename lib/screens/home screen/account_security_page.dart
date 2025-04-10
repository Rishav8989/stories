import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:stories/services/account_service.dart';
import 'package:stories/utils/user_service.dart';

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({Key? key}) : super(key: key);

  static const double maxWidth = 600.0;
  static const double maxDialogWidth = 600.0;

  @override
  Widget build(BuildContext context) {
    final accountService = Get.find<AccountService>();
    const double maxWidth = 400.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Security'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildListTile(
                context: context,
                icon: Icons.lock,
                text: 'Change Password',
                onTap: () => _showChangePasswordDialog(context, accountService),
              ),
              _buildListTile(
                context: context,
                icon: Icons.email,
                text: 'Change Email',
                onTap: () => _showChangeEmailDialog(context, accountService),
              ),
              _buildListTile(
                context: context,
                icon: Icons.verified_user,
                text: 'Verify Email',
                onTap: () => _showVerifyEmailDialog(context, accountService),
              ),
              _buildListTile(
                context: context,
                icon: Icons.person,
                text: 'Update Profile',
                onTap: () => _showUpdateProfileDialog(context, accountService),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Function() onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        leading: Icon(icon, size: 32, color: Theme.of(context).iconTheme.color),
        title: Text(
          text,
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context, AccountService accountService) async {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxDialogWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Change Password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        if (newPasswordController.text != confirmPasswordController.text) {
                          Get.snackbar('Error', 'Passwords do not match');
                          return;
                        }
                        try {
                          final userId = await Get.find<UserService>().getUserId();
                          await accountService.changePassword(
                            userId: userId!,
                            oldPassword: oldPasswordController.text,
                            newPassword: newPasswordController.text,
                            confirmPassword: confirmPasswordController.text,
                          );
                          Get.snackbar('Success', 'Password updated successfully');
                          Navigator.of(context).pop();
                        } catch (e) {
                          Get.snackbar('Error', e.toString());
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showChangeEmailDialog(BuildContext context, AccountService accountService) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxDialogWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Change Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'New Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        try {
                          await accountService.requestEmailChange(emailController.text);
                          Get.snackbar('Success', 'Email change request sent. Please check your new email.');
                          Navigator.of(context).pop();
                        } catch (e) {
                          Get.snackbar('Error', e.toString());
                        }
                      },
                      child: const Text('Request Change'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showVerifyEmailDialog(BuildContext context, AccountService accountService) async {
    final currentUser = await accountService.getCurrentUser();
    final emailController = TextEditingController(text: currentUser.data['email']);

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxDialogWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Verify Email', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        try {
                          await accountService.requestVerification(emailController.text);
                          Get.snackbar('Success', 'Verification email sent. Please check your inbox.');
                          Navigator.of(context).pop();
                        } catch (e) {
                          Get.snackbar('Error', e.toString());
                        }
                      },
                      child: const Text('Send Verification'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showUpdateProfileDialog(BuildContext context, AccountService accountService) async {
    final nameController = TextEditingController();
    final emailVisibility = true.obs;

    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxDialogWidth),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Update Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Obx(() => SwitchListTile(
                  title: const Text('Email Visibility'),
                  value: emailVisibility.value,
                  onChanged: (value) => emailVisibility.value = value,
                )),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () async {
                        try {
                          final userId = await Get.find<UserService>().getUserId();
                          await accountService.updateProfile(
                            userId: userId!,
                            name: nameController.text,
                            emailVisibility: emailVisibility.value,
                          );
                          Get.snackbar('Success', 'Profile updated successfully');
                          Navigator.of(context).pop();
                        } catch (e) {
                          Get.snackbar('Error', e.toString());
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 