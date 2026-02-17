import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class ImagePickerService {
  ImagePickerService._privateConstructor();
  static final ImagePickerService _instance =
      ImagePickerService._privateConstructor();

  static ImagePickerService get instance => _instance;

  final ImagePicker _picker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check Android version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final info = await _deviceInfo.androidInfo;
      return info.version.sdkInt;
    }
    return 0;
  }

  /// Request permissions (Only for Android ≤12)
  Future<bool> _requestGalleryPermission() async {
    int sdk = await _getAndroidVersion();

    // Android 13+ → No permission needed
    if (sdk >= 33) {
      return true;
    }

    // Android 7–12 → Need storage permission
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Camera permission
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Capture image from camera
  Future<File?> captureFromCamera() async {
    final granted = await _requestCameraPermission();
    if (!granted) return null;

    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);

    return picked != null ? File(picked.path) : null;
  }

  /// Pick image from gallery (Android 7–15)
  Future<File?> pickFromGallery() async {
    final sdk = await _getAndroidVersion();

    // Android 13+ → Photo Picker, no permission
    if (sdk >= 33) {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        requestFullMetadata: false,
      );
      return picked != null ? File(picked.path) : null;
    }

    // Android 7–12 → Need storage permission
    final granted = await _requestGalleryPermission();
    if (!granted) return null;

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    return picked != null ? File(picked.path) : null;
  }
}
