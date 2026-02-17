import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_utils.dart';

class ViewPdf extends StatefulWidget {
  final String pdfurl;
  const ViewPdf({super.key, required this.pdfurl});

  @override
  State<ViewPdf> createState() => _ViewPdfState();
}

class _ViewPdfState extends State<ViewPdf> {
  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color:
              Theme.of(context).colorScheme.onSurface, // adapts to dark/light
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppUtils.buildNormalText(
          text: "View Payslip",
          fontSize: 20,
          color: Theme.of(context).colorScheme.onSurface, // 👈 auto theme color
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: downloading
                ? null
                : () async {
                    await _downloadPdf(widget.pdfurl);
                  },
            icon: downloading
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CupertinoActivityIndicator(),
                  )
                : Icon(
                    CupertinoIcons.download_circle,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 24,
                  ),
          )
        ],
      ),
      body: widget.pdfurl.isNotEmpty
          ? SfPdfViewer.network(
              widget.pdfurl,
              canShowPageLoadingIndicator: true,
            )
          : const Center(
              child: Text("Invalid PDF URL"),
            ),
    );
  }

  Future<void> _downloadPdf(String url) async {
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
            Directory('/storage/emulated/0/Download/alsaqr/Payslip');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
        downloadsDir = Directory('${downloadsDir.path}/alsaqr/Payslip');
        if (!await downloadsDir.exists()) {
          await downloadsDir.create(recursive: true);
        }
      }

      final fileName = "Payslip_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File('${downloadsDir!.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      await _refreshMediaStore(file.path);

      AppUtils.showSingleDialogPopup(
        context,
        "Saved to:\n${"Download/alsaqr/Payslip/"} Folder ",
        "OK",
         () => onexitpopup(file.path),
        null,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
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
