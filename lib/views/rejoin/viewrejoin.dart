import 'dart:convert';
import 'package:flutter/material.dart';


import '../../models/error_model.dart';
import '../../models/viewrejoinmodel.dart';
import '../../services/apiservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/custom_indicatoronly.dart';
import '../widgets/assets_image_widget.dart';

class ViewRejoin extends StatefulWidget {
  const ViewRejoin({super.key});

  @override
  State<ViewRejoin> createState() => _ViewRejoinState();
}

class _ViewRejoinState extends State<ViewRejoin> {
  ViewRejoinModel historymodel = ViewRejoinModel();
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
          ? historymodel.message != null
              ? SingleChildScrollView(
                  child: Column(children: [getdetails()]),
                )
              : const Center(child: Text('No Data!'))
          : const CustomIndicator(),
    );
  }

  Widget getdetails() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (historymodel.message == null || historymodel.message!.isEmpty) {
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
      itemCount: historymodel.message!.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = historymodel.message![index];

        return Container(
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 3),
          decoration: BoxDecoration(
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              width: 0.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: theme.cardColor, // 👈 uses theme card color
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Left Column
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.buildNormalText(
                              text: "Expected Resume Date",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text: item.expectedresumebackdate?.toString() ??
                                  "-",
                              fontSize: 14,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 15),
                            AppUtils.buildNormalText(
                              text: "Work Resume",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text: item.isworkresume?.toString() ?? "-",
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(height: 15),
                            AppUtils.buildNormalText(
                              text: "Is Leave Extended?",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text: item.isleaveextended?.toString() ?? "-",
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(height: 15),
                          ],
                        ),
                      ),

                      // 🔹 Right Column
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.buildNormalText(
                              text: "Act Total Resume Delay Date",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text: item.noofdaysdelay?.toString() ?? "-",
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(height: 15),
                            AppUtils.buildNormalText(
                              text: "Work Resumption Done?",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text: item.isworkresume?.toString() ?? "-",
                              fontSize: 14,
                              color: colorScheme.onSurface,
                            ),
                            const SizedBox(height: 15),
                            AppUtils.buildNormalText(
                              text: "Act. Work Resume Date",
                              fontSize: 12,
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                              text:
                                  item.actualworkresumedate?.toString() ?? "-",
                              fontSize: 14,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              color: colorScheme.onSurface,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void getdetailsdata() async {
    setState(() {
      loading = true;
    });
    ApiService.viewrejoin().then((response) {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          historymodel = ViewRejoinModel.fromJson(jsonDecode(response.body));
        } else {
          // AppUtils.showSingleDialogPopup(
          //     context, jsonDecode(response.body)['message'], "Ok", onexitpopup);
        }
      } else {
        throw Exception(jsonDecode(response.body).toString()).toString();
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(context, e.toString(), "Ok", onexitpopup,
          AssetsImageWidget.errorimage);
    });
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }
}
