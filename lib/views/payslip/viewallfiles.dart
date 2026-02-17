import 'dart:io';


import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../utils/app_utils.dart';

class ViewFiles extends StatefulWidget {
  final String fileUrl;
  final String fileName;
  final String? mimeType;
  const ViewFiles(
      {super.key,
      required this.fileUrl,
      required this.fileName,
      required this.mimeType});

  @override
  State<ViewFiles> createState() => _ViewFilesState();
}

class _ViewFilesState extends State<ViewFiles> {
  bool downloading = false;
  String? mimeType;

  @override
  void initState() {
    super.initState();
    if (widget.mimeType != null) {
      mimeType = widget.mimeType;
    } else {
      _fetchMimeType(); // fallback if not provided
    }
  }

  Future<void> _fetchMimeType() async {
    try {
      final response = await http.get(Uri.parse(widget.fileUrl));
      if (response.statusCode == 200) {
        setState(() {
          mimeType = response.headers['content-type'];
        });
      }
    } catch (e) {
      debugPrint("Failed to detect MIME type: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget viewer = const Center(
        child: CircularProgressIndicator(
      color: Colors.amber,
    ));

    if (mimeType != null) {
      if (mimeType!.contains('pdf')) {
        viewer = SfPdfViewer.network(widget.fileUrl);
      } else if (mimeType!.contains('image')) {
        viewer = InteractiveViewer(child: Image.network(widget.fileUrl));
      } else if (mimeType!.contains('text')) {
        viewer = FutureBuilder<String>(
          future: http.read(Uri.parse(widget.fileUrl)),
          builder: (_, snapshot) => snapshot.hasData
              ? SingleChildScrollView(child: Text(snapshot.data!))
              : const Center(child: CircularProgressIndicator()),
        );
      } else {
        viewer = const Center(
            child: Text("Preview not supported. Download to view."));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        actions: [
          IconButton(
            icon: downloading
                ? const CupertinoActivityIndicator()
                : const Icon(CupertinoIcons.download_circle),
            onPressed: downloading
                ? null
                : () => _downloadPdf(widget.fileUrl, widget.fileName),
          )
        ],
      ),
      body: viewer,
    );
  }

  Future<void> _downloadPdf(String url, String fileName) async {
    try {
      setState(() => downloading = true);

      if (Platform.isAndroid) {
        bool granted = await _requestStoragePermissionIfNeeded();
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Storage permission denied")));
          setState(() => downloading = false);
          return;
        }
      }

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) throw Exception('Download failed');

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir =
            Directory('/storage/emulated/0/Download/alsaqr/files');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${downloadsDir.path}/alsaqr/files');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      }

      // ✅ Use safe file extension
      String getFileExtension(String mimeType) {
        if (mimeType.contains('pdf')) return 'pdf';
        if (mimeType.contains('csv')) return 'csv';
        if (mimeType.contains('text')) return 'txt';
        if (mimeType.contains('jpeg') || mimeType.contains('jpg')) return 'jpg';
        if (mimeType.contains('png')) return 'png';
        if (mimeType.contains('zip')) return 'zip';
        return 'bin';
      }

      final extension = getFileExtension(mimeType ?? '');
      final safeFileName =
          "${fileName}_${DateTime.now().millisecondsSinceEpoch}.$extension";

      final file = File('${downloadsDir!.path}/$safeFileName');
      await file.writeAsBytes(response.bodyBytes);
      print('Exists? ${await file.exists()}');
      await _refreshMediaStore(file.path);

      AppUtils.showSingleDialogPopup(
        context,
        "✅ File saved to:\nDownload/alsaqr/files/",
        "OK",
        () => onexitpopup(file.path),
        null,
      );
    } catch (e) {
      debugPrint("❌ Error downloading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => downloading = false);
    }
  }

  Future<bool> _requestStoragePermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt <= 29) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }

    // Android 11+ (Scoped Storage) → permission not required
    return true;
  }

  /// ✅ Optional: Refresh MediaStore so file appears in “Files” app
  Future<void> _refreshMediaStore(String filePath) async {
    try {
      await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath',
      ]);
      print("📢 MediaStore refreshed for: $filePath");
    } catch (e) {
      print("⚠️ MediaStore refresh failed: $e");
    }
  }

  void onexitpopup(String filePath) async {
    Navigator.of(context).pop();
    await OpenFilex.open(filePath);
  }
}
