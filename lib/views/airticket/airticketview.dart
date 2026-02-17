import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../models/viewairticketmodel.dart';

import '../../routenames.dart';
import '../../services/apiservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../../utils/custom_indicatoronly.dart';
import '../payslip/viewallfiles.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/colorstatus.dart';
import '../widgets/custom_button.dart';
import 'airticketdetailview.dart';

class Airticketview extends StatefulWidget {
  const Airticketview({super.key});

  @override
  State<Airticketview> createState() => _AirticketviewState();
}

class _AirticketviewState extends State<Airticketview> {
  bool loading = false;
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  ViewAirTicketModel viewModel = ViewAirTicketModel();
  List<AirTicketData> filteredList = [];

  @override
  void initState() {
    super.initState();
    getdetailsdata();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: colorScheme.onSurface),
          onPressed: () {
            if (isSearching) {
              setState(() {
                isSearching = false;
                searchController.clear();
                filteredList = viewModel.data ?? [];
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: !isSearching
            ? Text(
                "Airticket View",
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              )
            : TextField(
                controller: searchController,
                autofocus: true,
                onChanged: onSearchTextChanged,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: "Search asset...",
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredList = viewModel.data ?? [];
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: !loading
          ? (filteredList.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(children: [airticketDetailsList(context)]))
              : Center(
                  child: Text(
                    "No airticket requests found!",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ))
          : const CustomIndicator(),
      persistentFooterButtons: [
        CustomButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteNames.airticketrequest).then((_) {
              setState(() {
                getdetailsdata();
              });
            });
          },
          name: "Click to Apply Airticket Request",
          fontSize: 14,
          circularvalue: 30,
        )
      ],
    );
  }

  // 🔍 Real-time search logic
  void onSearchTextChanged(String query) {
    if (query.isEmpty) {
      setState(() => filteredList = viewModel.data ?? []);
      return;
    }

    final q = query.toLowerCase();
    setState(() {
      filteredList = (viewModel.data ?? []).where((data) {
        bool match(String? text) => text?.toLowerCase().contains(q) ?? false;
        return match(data.purposeOfTravel) ||
            match(data.fromLocation) ||
            match(data.toLocation.toString()) ||
            match(data.departureDate) ||
            match(data.returnDate) ||
            match(data.internalId) ||
            match(data.date);
      }).toList();
    });
  }

  Widget airticketDetailsList(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      itemCount: filteredList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final item = filteredList[index];
        final theme = Theme.of(context);
        final textColor = theme.colorScheme.onSurface;
        final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
        final cardColor = theme.cardColor;
        return GestureDetector(
                onTap: () {
            Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AirticketDetailview(ticketData: item,),
      ),
    );
          },
          child: Card(
            elevation: 2,
            color: cardColor,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.person_circle_fill,
                        size: 40,
                        color: AppConstants.containercolorArray[
                            index % AppConstants.containercolorArray.length],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.internalId ?? '',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                )),
                            const SizedBox(height: 2),
                            Text(
                              AppConstants.convertdateformat(
                                  item.createdAt.toString() ?? ''),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      statusPendingColor(text: item.isStatus ?? ''),
                    ],
                  ),
          
                  const SizedBox(height: 12),
                  // 🔹 location
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.buildNormalText(
                                text: "FROM LOCATION",
                                color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(height: 5),
                            Text(item.fromLocation ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                )),
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppUtils.buildNormalText(
                                text: "TO LOCATION",
                                color: colorScheme.onSurface.withOpacity(0.6)),
                            const SizedBox(height: 5),
                            Text(item.toLocation ?? '',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                )),
                          ]),
                    ],
                  ),
                  // const SizedBox(height: 12),
                  // // 🔹 date
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           AppUtils.buildNormalText(
                  //               text: "DEPATUR EDATE",
                  //               color: colorScheme.onSurface.withOpacity(0.6)),
                  //           const SizedBox(height: 5),
                  //           Text(item.departureDate ?? '',
                  //               style: theme.textTheme.bodyMedium?.copyWith(
                  //                 color: colorScheme.onSurface,
                  //                 fontWeight: FontWeight.bold,
                  //               )),
                  //         ]),
                  //     Column(
                  //         crossAxisAlignment: CrossAxisAlignment.end,
                  //         children: [
                  //           AppUtils.buildNormalText(
                  //               text: "RETURN DATE",
                  //               color: colorScheme.onSurface.withOpacity(0.6)),
                  //           const SizedBox(height: 5),
                  //           Text(item.returnDate ?? '',
                  //               style: theme.textTheme.bodyMedium?.copyWith(
                  //                 color: colorScheme.onSurface,
                  //                 fontWeight: FontWeight.bold,
                  //               )),
                  //         ]),
                  //   ],
                  // ),
          
                  // const SizedBox(height: 6),
          
                  // Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  //   AppUtils.buildNormalText(
                  //       text: "REMARK",
                  //       color: colorScheme.onSurface.withOpacity(0.6)),
                  //   const SizedBox(height: 5),
                  //   Text(item.remark ?? '',
                  //       style: theme.textTheme.bodyMedium?.copyWith(
                  //         color: colorScheme.onSurface,
                  //         fontWeight: FontWeight.bold,
                  //       )),
                  // ]),
          
                  // Divider(
                  //     height: 0.5, color: colorScheme.outline.withOpacity(0.3)),
          
                  // // 🔹 Remarks
                  // if (item.remark != null && item.remark!.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 4),
                  //     child: Text(
                  //       item.remark!.toUpperCase(),
                  //       style: theme.textTheme.bodySmall?.copyWith(
                  //         color: colorScheme.onSurface,
                  //       ),
                  //       maxLines: 3,
                  //       overflow: TextOverflow.ellipsis,
                  //     ),
                  //   ),
                  // const SizedBox(height: 12),
                  // GestureDetector(
                  //   onTap: () async {
                  //     if (item.airTicketAttachment!.isEmpty) return;
          
                  //     final mime = await AppConstants.getMimeType(
                  //         item.airTicketAttachment!);
                  //     final ext = AppConstants.getExtensionFromMime(mime);
          
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (_) => ViewFiles(
                  //           fileUrl: item.airTicketAttachment!,
                  //           fileName: 'file.$ext',
                  //           mimeType: mime,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  //   child: Row(
                  //     children: [
                  //       Icon(Icons.attachment,
                  //           size: 16, color: colorScheme.primary),
                  //       const SizedBox(width: 5),
                  //       Text("View Attachment",
                  //           style: theme.textTheme.bodySmall?.copyWith(
                  //             color: colorScheme.primary,
                  //             fontWeight: FontWeight.w500,
                  //           )),
                  //     ],
                  //   ),
                  // ),
          
                  // const SizedBox(height: 5),
          
                  // // 🔹 Approval History
                  // if (item.approvalHistory?.isNotEmpty ?? false) ...[
                  //   const SizedBox(height: 5),
                  //   Divider(color: colorScheme.outline.withOpacity(0.3)),
                  //   ListTile(
                  //     dense: true,
                  //     contentPadding: EdgeInsets.zero,
                  //     onTap: () => showSheet(context, index),
                  //     trailing:
                  //         Icon(Icons.remove_red_eye, color: colorScheme.primary),
                  //     title: Text("Approval History",
                  //         style: theme.textTheme.bodySmall?.copyWith(
                  //             color: colorScheme.onSurface,
                  //             fontWeight: FontWeight.w500)),
                  //   )
                  // ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showSheet(BuildContext context, int index) {
    final item = filteredList[index];
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
        context: context,
        backgroundColor: colorScheme.surface,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                AppUtils.gethanger(context),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: item.approvalHistory?.length ?? 0,
                    itemBuilder: (context, index1) {
                      final hist = item.approvalHistory![index1];
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                appovalPending(text: hist.status ?? ''),
                                const SizedBox(width: 10),
                                Text(
                                  hist.status == "Approved"
                                      ? "Approved By"
                                      : hist.status == "Rejected"
                                          ? "Rejected"
                                          : "Pending",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(hist.approvername ?? '',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface)),
                              ]),
                              const SizedBox(height: 6),
                              Text(hist.approveddate ?? '',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.7))),
                              const SizedBox(height: 6),
                              Text(hist.remarks ?? '',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: colorScheme.onSurface)),
                              Divider(
                                  color: colorScheme.outline.withOpacity(0.2)),
                            ]),
                      );
                    }),
              ],
            ),
          );
        });
  }

  void getdetailsdata() async {
    setState(() => loading = true);
    ApiService.viewairticket().then((response) {
      setState(() => loading = false);
      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody['status'].toString() == "true") {
          viewModel = ViewAirTicketModel.fromJson(jsonBody);
          filteredList = viewModel.data ?? [];
        } else {
          viewModel.data = [];
          filteredList = [];
        }
      }
    }).catchError((e) {
      setState(() => loading = false);
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    });
  }

  void onexitpopup() => Navigator.of(context).pop();
}
