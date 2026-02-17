import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import '../../models/yearmodel.dart';
import '../../services/apiservice.dart';
import '../../services/pref.dart';
import '../../utils/app_utils.dart';
import '../../utils/sharedprefconstants.dart';
import 'payslipmodel.dart';
import 'viewpdf.dart';

class ViewPaySlipPage extends StatefulWidget {
  const ViewPaySlipPage({super.key});

  @override
  State<ViewPaySlipPage> createState() => _ViewPaySlipPageState();
}

class _ViewPaySlipPageState extends State<ViewPaySlipPage> {
  final yearKey = GlobalKey<DropdownSearchState<YearModel>>();
  final now = DateTime.now();
  bool loading = false;
  String? selectedYear;
  List<YearModel> _yearList = [];
  PaySlipModel? paySlipModel;
  YearModel? selectedYearModel;
  @override
  void initState() {
    super.initState();
    _loadDefaultYear();
  }

  Future<void> _loadDefaultYear() async {
    try {
      _yearList = await ApiService.getyearModel();

      if (_yearList.isNotEmpty) {
        final String currentYear = DateTime.now().year.toString();
        final YearModel selected = _yearList.firstWhere(
          (y) => y.name == currentYear,
          orElse: () => _yearList.first,
        );

        setState(() {
          selectedYearModel = selected;
          selectedYear = selected.name;
        });

        getPayslip(selectedYear!);
      }
    } catch (e) {
      print("❌ Error loading years: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color:
              Theme.of(context).colorScheme.onSurface, // adapts to dark/light
        ),
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Theme.of(context)
                .colorScheme
                .onSurface, // ✅ fixed (removed const)
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Payslip",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface, // 👈 auto theme color
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🎯 Year Dropdown
                  Text(
                    "Select Year",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 8),

                  yearChoiceChips(context),
                  const SizedBox(height: 20),

                  Expanded(child: buildPaySlipwidget(context)),
                ],
              ),
            ),
    );
  }

  Widget yearChoiceChips(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_yearList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(10),
      child: Wrap(
        spacing: 8,
        runSpacing: 10,
        children: _yearList.map((year) {
          final isSelected = selectedYearModel?.id == year.id;

          return ChoiceChip(
            showCheckmark: false, // Hide default static tick
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  year.name,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withOpacity(0.8),
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(width: 6),

                /// ✅ Animated tick icon (fade + scale)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isSelected
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('selected'),
                          size: 18,
                          color: colorScheme.onPrimary,
                        )
                      : const SizedBox(
                          key: ValueKey('unselected'),
                          width: 18,
                          height: 18,
                        ),
                ),
              ],
            ),
            selected: isSelected,
            selectedColor: colorScheme.primary,
            backgroundColor: colorScheme.surfaceContainerHighest
                .withOpacity(isSelected ? 0.2 : 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            onSelected: (_) {
              setState(() {
                selectedYearModel = year;
                selectedYear = year.name;
              });
              getPayslip(year.name);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget buildPaySlipwidget(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = theme.cardColor;
    if (paySlipModel != null && paySlipModel!.payslips.isNotEmpty) {
      return ListView.separated(
        itemCount: paySlipModel!.payslips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final payslip = paySlipModel!.payslips[index];
          final colors = [
            Colors.orange,
            Colors.green,
            Colors.purple,
            Colors.blue,
            Colors.grey,
            Colors.pink,
            Colors.red
          ];
          final color = colors[index % colors.length];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewPdf(pdfurl: payslip.payslipUrl.toString()),
                ),
              );
            },
            child: Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(Icons.calendar_today, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payslip.payMonth ?? "Unknown Month",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Click to view payslip",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _downloadPdf(payslip.payslipUrl);
                      },
                      icon: Icon(
                        CupertinoIcons.download_circle_fill,
                        color: colorScheme.primary, // 👈 Dynamic accent color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } else {
      return _buildEmptyState(context);
    }
  }

  // 🪫 Empty state
  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.doc_text_search,
              size: 60, color: colorScheme.outline),
          const SizedBox(height: 12),
          Text(
            "No payslips found for $selectedYear",
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🌐 Launch PDF URL
  Future<void> _launchUrl(url, {bool isNewTab = true}) async {
    if (kIsWeb) {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: isNewTab ? '_blank' : '_self',
      )) {
        throw Exception('Could not launch $url');
      }
    } else if (Platform.isAndroid) {
      if (!await launchUrl(url,
          mode: LaunchMode.externalNonBrowserApplication)) {
        throw Exception('Could not launch $url');
      }
    } else if (Platform.isIOS) {
      if (!await launchUrl(
        Uri.parse(url),
      )) {
        throw Exception('Could not launch $url');
      }
    }
  }

  // 💼 Payslip API
  Future<void> getPayslip(String year) async {
    final String employeeId =
        Prefs.getNsID(SharefprefConstants.sharednsid).toString();

    setState(() => loading = true);

    final body = {
      "employeeId": employeeId,
      "payYear": year,
    };

    print("📤 Request Body: ${jsonEncode(body)}");

    try {
      final response = await ApiService.viewPayslip(body);
      print("📥 Raw Response: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          final List<dynamic> payload = jsonResponse['payload'] ?? [];

          final matchedEmployee = payload.firstWhere(
            (e) => e['employeeId'].toString() == employeeId,
            orElse: () => null,
          );

          if (matchedEmployee != null) {
            final List<dynamic> payslipList = matchedEmployee['payslips'] ?? [];

            setState(() {
              paySlipModel = PaySlipModel.fromJson({
                'employeeId': matchedEmployee['employeeId'],
                'employeeName': matchedEmployee['employeeName'],
                'payslips': payslipList,
              });
              loading = false;
            });
          } else {
            print("⚠️ No matching employee found");
            setState(() {
              paySlipModel = null;
              loading = false;
            });
          }
        } else {
          print("⚠️ API returned failure: ${jsonResponse['message']}");
          setState(() {
            paySlipModel = null;
            loading = false;
          });
        }
      } else {
        print("❌ HTTP Error: ${response.statusCode}");
        setState(() => loading = false);
      }
    } catch (e) {
      print("❗ Exception in getPayslip: $e");
      setState(() => loading = false);
    }
  }

  Future<void> _downloadPdf(String url) async {
    try {
      setState(() => loading = true);

      if (Platform.isAndroid) {
        bool granted = await _requestStoragePermissionIfNeeded();
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Storage permission denied")));
          setState(() => loading = false);
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
      if (mounted) setState(() => loading = false);
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
