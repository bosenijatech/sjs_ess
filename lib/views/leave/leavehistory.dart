import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';

import '../../models/approveleavemodel.dart';
import '../../models/error_model.dart';
import '../../services/apiservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../../utils/custom_indicatoronly.dart';
import '../rejoin/dutyresumptionapply.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/colorstatus.dart';


class LeaveandHistoryPage extends StatefulWidget {
  const LeaveandHistoryPage({super.key});

  @override
  State<LeaveandHistoryPage> createState() => _LeaveandHistoryPageState();
}

class _LeaveandHistoryPageState extends State<LeaveandHistoryPage> {
  ViewLeaveApproveModel historymodel = ViewLeaveApproveModel();
  ErrorModelNetSuite errormodel = ErrorModelNetSuite();
  bool loading = true;
  @override
  void initState() {
    getdetailsdata();
    super.initState();
  }

  @override
  void dispose() {
    loading = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: !loading
          ? historymodel.data != null
              ? SingleChildScrollView(
                  child: Column(children: [getDetails()]),
                )
              : const Center(child: Text('No Data!'))
          : const CustomIndicator(),
    );
  }

  Widget getDetails() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (historymodel.data == null || historymodel.data!.isEmpty) {
      return Center(
        child: Text(
          'No Data!',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: historymodel.data!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemBuilder: (context, index) {
        final item = historymodel.data![index];
        final color = AppConstants
            .colorArray[index.remainder(AppConstants.colorArray.length)];

        return Card(
          color: theme.cardColor,
          elevation: 3,
          shadowColor: color.withOpacity(0.25),
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 ID + Status + Menu in one row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left part: ID
                    Row(
                      children: [
                        Icon(Icons.tag, color: color, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          "ID: ${item.internalid.toString()}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    // Right part: Status + Menu icon
                    Row(
                      children: [
                        statusPendingColor(
                          text: item.isstatus.toString(),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => showCancel(context, index),
                          child: Icon(
                            Icons.more_vert,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 🔹 Date
                Row(
                  children: [
                    Icon(Icons.date_range_rounded, color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      AppConstants.convertdateformat(
                        item.date.toString().substring(0, 10),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // 🔹 Duration
                Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded,
                        color: color, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '(${AppConstants.changeddmmyyformat(item.fromdate.toString())} → ${AppConstants.changeddmmyyformat(item.todate.toString())})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${item.totalNoOfDays} ${item.totalNoOfDays == 1 ? "day" : "days"}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(
                  color: colorScheme.outline.withOpacity(0.2),
                  height: 1,
                ),
                const SizedBox(height: 10),

                // 🔹 Leave type
                Text(
                  item.leavetypename.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void showCancel(BuildContext context, int index) {
    if (!mounted) return; // ✅ Safety check before doing anything

    showModalBottomSheet(
      context: context,
      isDismissible: true, // ✅ Let user swipe down to close
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Apply Rejoin Request'),
                onTap: () async {
                  Navigator.pop(sheetContext); // ✅ Close sheet safely

                  // ✅ Wait a tick to ensure bottom sheet fully closes
                  await Future.delayed(const Duration(milliseconds: 150));

                  if (!mounted) return; // ✅ Ensure widget still in tree
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DutyResumption(
                          model: historymodel,
                          position: index,
                        ),
                      ),
                    ).then((value) {
                      // This runs after the DutyResumption page is popped
                      getdetailsdata();
                    });
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Cancel Dialog'),
                onTap: () {
                  if (Navigator.canPop(sheetContext)) {
                    Navigator.pop(sheetContext);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void getdetailsdata() async {
    if (!mounted) return; // ✅ safety check before setState
    setState(() {
      loading = true;
    });

    try {
      final response = await ApiService.viewapprovedleave();

      if (!mounted) return; // ✅ widget might be disposed before response
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        log(jsonEncode(data));
        if (data['success'] == true && data['data'] != null) {
          historymodel = ViewLeaveApproveModel.fromJson(data);
        } else {
          historymodel.data = [];
        }
      } else {
        throw Exception(jsonDecode(response.body).toString());
      }
    } catch (e) {
      if (!mounted) return; // ✅ ensure widget still active
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }
}
