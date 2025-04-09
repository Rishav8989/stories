import 'package:pocketbase/pocketbase.dart';

class UserService {
  final PocketBase pb;

  UserService(this.pb);

  Future<RecordModel> getCurrentUser() async {
    return pb.authStore.model;
  }

  Future<bool> isAuthenticated() async {
    return pb.authStore.isValid;
  }
} 