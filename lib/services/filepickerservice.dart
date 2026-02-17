// import 'dart:convert';
// import 'dart:io';
// import 'dart:math';
// import 'package:alsaqr/models/filemodel.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CameraImageService {
//   CameraImageService._privateConstructor();
//   static final CameraImageService _instance =
//       CameraImageService._privateConstructor();
//   static CameraImageService get instance => _instance;

//   final ImagePicker _picker = ImagePicker();

//   /// 🔹 Request camera permission
//   Future<bool> _requestCameraPermission() async {
//     final status = await Permission.camera.request();
//     return status.isGranted;
//   }

//   /// 🔹 Request storage permission (for file picker)
//   Future<bool> _requestStoragePermission() async {
//     if (Platform.isAndroid) {
//       // Android 13+ (API level 33) uses new photo/video permissions
//       if (await Permission.photos.isGranted) return true;

//       if (await Permission.photos.request().isGranted) {
//         return true;
//       } else {
//         print('Photos permission denied');
//         return false;
//       }
//     } else {
//       // iOS
//       if (await Permission.photos.request().isGranted) return true;
//       print('Photos permission denied (iOS)');
//       return false;
//     }
//   }

//   /// 📸 Capture image and return AttachModel
//   Future<AttachModel?> getImageFromCamera() async {
//     final granted = await _requestCameraPermission();
//     if (!granted) {
//       print('Camera permission denied');
//       return null;
//     }

//     final XFile? pickedFile =
//         await _picker.pickImage(source: ImageSource.camera);
//     if (pickedFile == null) {
//       print('No image selected.');
//       return null;
//     }

//     final file = File(pickedFile.path);
//     return _convertToAttachModel(file);
//   }

//   /// 📂 Pick file (image, pdf, doc, etc.) and return AttachModel
//   Future<AttachModel?> pickFile({bool image = false}) async {
//     final granted = await _requestStoragePermission();
//     if (!granted) {
//       print('Storage permission denied');
//       return null;
//     }

//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       allowCompression: true,
//       type: FileType.custom,
//       allowedExtensions: image
//           ? ['jpg', 'jpeg', 'png']
//           : ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls'],
//       //allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xls'],
//     );

//     if (result != null && result.files.single.path != null) {
//       final file = File(result.files.single.path!);
//       return _convertToAttachModel(file);
//     } else {
//       print('No file selected.');
//       return null;
//     }
//   }

//   Future<AttachModel> _convertToAttachModel(File file) async {
//     final bytes = await file.readAsBytes();
//     final base64String = base64Encode(bytes);

//     final fileSizeMB = (bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(3);
//     final fileName = file.path.split("/").last;
//     final fileType = _getFileExtension(fileName);
//     final random = Random().nextInt(100).toString();

//     return AttachModel(
//       random,
//       base64String,
//       fileType,
//       fileName,
//       fileSizeMB,
//     );
//   }

//   /// 🔹 Utility: extract file extension
//   String _getFileExtension(String filePath) {
//     String ext = filePath.split('.').last.toLowerCase();
//     return ext;
//   }
// }
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '../models/filemodel.dart';

class CameraImageService {
  CameraImageService._privateConstructor();
  static final CameraImageService _instance =
      CameraImageService._privateConstructor();
  static CameraImageService get instance => _instance;

  final ImagePicker _picker = ImagePicker();

  /// Allow camera only
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Pick image from camera
  Future<AttachModel?> getImageFromCamera() async {
    try {
      final granted = await _requestCameraPermission();
      if (!granted) return null;

      final XFile? pickedFile =
          await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile == null) return null;

      return _convertToAttachModel(File(pickedFile.path));
    } catch (e) {
      print("Camera error: $e");
      return null;
    }
  }

  /// Pick any file — NO PERMISSION NEEDED
  Future<AttachModel?> pickFile({bool image = false}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        allowCompression: true,
        type: FileType.custom,
        allowedExtensions:
            image ? ['jpg', 'jpeg', 'png'] : ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null || result.files.single.path == null) {
        return null;
      }

      return _convertToAttachModel(File(result.files.single.path!));
    } catch (e) {
      print("File picker error: $e");
      return null;
    }
  }

  /// Convert to model
  Future<AttachModel> _convertToAttachModel(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);

    return AttachModel(
      Random().nextInt(99999).toString(),
      base64String,
      _getFileExtension(file.path),
      p.basename(file.path),
      (bytes.lengthInBytes / 1024 / 1024).toStringAsFixed(2),
    );
  }

  String _getFileExtension(String filePath) {
    return p.extension(filePath).replaceAll('.', '').toLowerCase();
  }

  Future<List<AttachModel>> pickMultipleFiles({
    required int remaining,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowCompression: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result == null) return [];

      List<AttachModel> files = [];

      for (final picked in result.files.take(remaining)) {
        if (picked.path == null) continue;

        final file = File(picked.path!);
        files.add(await _convertToAttachModel(file));
      }

      return files;
    } catch (e) {
      print("Multi file picker error: $e");
      return [];
    }
  }
}
