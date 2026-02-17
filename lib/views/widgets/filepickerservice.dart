import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class FilePickerService {
  FilePickerService._();
  static final FilePickerService instance = FilePickerService._();

  Future<File?> pickFile() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      status = await Permission.photos.request();
    } else {
      status = await Permission.photos.request();
    }

    if (!status.isGranted) {
      return null;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }
}
