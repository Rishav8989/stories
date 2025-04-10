import 'package:pocketbase/pocketbase.dart';

class AccountService {
  final PocketBase pb;

  AccountService(this.pb);

  Future<void> changePassword({
    required String userId,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await pb.collection('users').update(
      userId,
      body: {
        'password': newPassword,
        'passwordConfirm': confirmPassword,
        'oldPassword': oldPassword,
      },
    );
  }

  Future<void> requestEmailChange(String newEmail) async {
    await pb.collection('users').requestEmailChange(newEmail);
  }

  Future<void> requestVerification(String email) async {
    await pb.collection('users').requestVerification(email);
  }

  Future<void> updateProfile({
    required String userId,
    String? name,
    bool? emailVisibility,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (emailVisibility != null) data['emailVisibility'] = emailVisibility;

    await pb.collection('users').update(
      userId,
      body: data,
    );
  }

  Future<RecordModel> getCurrentUser() async {
    return pb.authStore.model;
  }
} 