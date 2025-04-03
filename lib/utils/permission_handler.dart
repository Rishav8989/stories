import 'package:permission_handler/permission_handler.dart';

class PermissionHandlerService {
  // Request storage permissions with handling for permanent denial [[5]][[7]]
  Future<bool> requestStoragePermissions() async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // Open app settings if permission is permanently denied [[8]]
      await openAppSettings();
      return false;
    }

    // Request permission [[1]][[4]]
    final requestStatus = await Permission.storage.request();
    return requestStatus.isGranted;
  }

  // Request all required permissions [[6]]
  Future<bool> requestAllPermissions() async {
    bool storageGranted = await requestStoragePermissions();
    return storageGranted;
  }

  // Open app settings [[8]]
  Future<void> openAppSettings() async {
    await openAppSettings();
  }
}