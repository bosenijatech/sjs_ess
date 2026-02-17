import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraImageService {
  CameraImageService._();
  static final CameraImageService instance = CameraImageService._();

  final ImagePicker _picker = ImagePicker();

  /// 📷 Camera image pick
  Future<File?> getImageFromCamera() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      return null;
    }

    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera);

    if (image == null) return null;
    return File(image.path);
  }

  /// 🖼 Gallery image pick (Android 8 → 14 safe)
  Future<File?> getImageFromGallery() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!status.isGranted) {
      return null;
    }

    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;
    return File(image.path);
  }
}
