import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
  @override
  Future<bool> requestAllPermissions() async {
    bool storageGranted = await requestStoragePermissions();
    bool hasInternet = await checkInternetConnectivity();
    return storageGranted && hasInternet;
  }

  // Open app settings [[8]]
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<bool> checkInternetConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }
}