import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../models/viewlettermodel.dart';
import '../../routenames.dart';
import '../../services/apiservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../../utils/custom_indicatoronly.dart';
import '../payslip/viewallfiles.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/colorstatus.dart';
import '../widgets/custom_button.dart';

class ViewLetterDetailsPage extends StatefulWidget {
  const ViewLetterDetailsPage({super.key});

  @override
  State<ViewLetterDetailsPage> createState() => _ViewLetterDetailsPageState();
}

class _ViewLetterDetailsPageState extends State<ViewLetterDetailsPage> {
  bool loading = false;
  bool isSearching = false; // ✅ search mode toggle
  TextEditingController searchController = TextEditingController();
  int _page = 1;
  final int _limit = 10; // items per page
  bool _hasMore = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  ViewletterModel lettermodel = ViewletterModel();
  List<Message> filteredList = [];

  @override
  void initState() {
    getdetailsdata();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadingMore &&
          _hasMore) {
        _loadMoreData();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface), // ← icons adapt
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface, // ← text adapts
              fontWeight: FontWeight.bold,
            ),
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            if (isSearching) {
              setState(() {
                isSearching = false;
                searchController.clear();
                filteredList = List.from(lettermodel.message ?? []);
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: !isSearching
            ? Text(
                "Letter Details",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              )
            : TextField(
                controller: searchController,
                autofocus: true,
                onChanged: (value) => onSearchTextChanged(value),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  hintText: "Search letter...",
                  hintStyle: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6), // softer in dark mode
                  ),
                  border: InputBorder.none,
                ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  searchController.clear();
                  filteredList = lettermodel.message ?? [];
                }
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      // 🔹 Body
      body: loading
          ? const CustomIndicator()
          : (filteredList.isNotEmpty
              ? SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      letterDetails(),
                    ],
                  ),
                )
              : Center(
                  child: Text(
                    'No Letter Request Found!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7), // 👈 adapts to light/dark
                        ),
                  ),
                )),

      // 🔹 Footer Button
      persistentFooterButtons: [
        CustomButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteNames.addletter).then((_) {
              setState(() {
                getdetailsdata();
              });
            });
          },
          name: "Click to Apply Letter Request",
          fontSize: 14,
          circularvalue: 30,
        )
      ],
    );
  }

  // 🔍 Search logic
  void onSearchTextChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        filteredList = List.from(lettermodel.message ?? []);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();

    setState(() {
      filteredList = (lettermodel.message ?? []).where((msg) {
        return (msg.lettertypename ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.letteraddresstoname ?? "")
                .toLowerCase()
                .contains(lowerQuery) ||
            (msg.toEmpName ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.isstatus ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.internalid ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.copyTypeName ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.createdDate ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.purpose ?? "").toLowerCase().contains(lowerQuery) ||
            (msg.letteraddresstocode ?? "")
                .toLowerCase()
                .contains(lowerQuery) ||
            (msg.purpose ?? "").toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  Widget letterDetails() {
    return ListView.builder(
      controller: _scrollController, // 👈 for infinite scrolling
      itemCount:
          filteredList.length + (_isLoadingMore ? 1 : 0), // 👈 loader row
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index < filteredList.length) {
          return getWidget(context, index);
        } else {
          // 🔄 loader shown when fetching more data
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CupertinoActivityIndicator()),
          );
        }
      },
    );
  }

  Widget getWidget(BuildContext context, int index) {
    final theme = Theme.of(context);
    final item = filteredList[index];
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4, // ⬆ increase elevation slightly
      shadowColor: theme.shadowColor.withOpacity(0.2),
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧍 Header Row (Icon + ID + Date + Status)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConstants.containercolorArray[
                                index % AppConstants.containercolorArray.length]
                            .withOpacity(0.15),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        CupertinoIcons.person_crop_circle,
                        size: 30,
                        color: AppConstants.containercolorArray[
                            index % AppConstants.containercolorArray.length],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.internalid ?? "-",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          AppConstants.changeddmmyyformat(item.createdDate
                                  .toString()
                                  .substring(0, 10)) ??
                              "",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                statusPendingColor(text: item.isstatus.toString()),
              ],
            ),

            const SizedBox(height: 10),
            Divider(color: theme.dividerColor.withOpacity(0.3)),

            const SizedBox(height: 8),
            _infoRow(context, "Letter Type", item.lettertypename ?? "-"),
            _infoRow(context, "Address To", item.letteraddresstoname ?? "-"),
            _infoRow(context, "Copy To", item.copyTypeName ?? "-"),

            if (item.purpose != null && item.purpose!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                "Purpose",
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.purpose!.toUpperCase(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],

            const SizedBox(height: 8),

            /// 📎 Attachment
            if (item.attachment != null &&
                item.attachment != "null" &&
                item.attachment!.isNotEmpty)
              GestureDetector(
                onTap: () async {
                  final mime = await AppConstants.getMimeType(item.attachment!);
                  final ext = AppConstants.getExtensionFromMime(mime);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ViewFiles(
                        fileUrl: item.attachment!,
                        fileName: 'file.$ext',
                        mimeType: mime,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.attachment,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      "View Attachment",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Helper for label + value rows
  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void showSheet(context, index) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                AppUtils.gethanger(context),
                ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        lettermodel.message![index].approvalHistory!.length,
                    itemBuilder: (BuildContext context, int index1) {
                      return Container(
                        padding: const EdgeInsets.only(
                            left: 10, right: 10, bottom: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade50,
                            width: 0.5,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                appovalPending(
                                    text: lettermodel.message![index]
                                        .approvalHistory![index1].status
                                        .toString()),
                                const SizedBox(width: 10),
                                AppUtils.buildNormalText(
                                    text: lettermodel.message![index]
                                                .approvalHistory![index1].status
                                                .toString() ==
                                            "Approved"
                                        ? "Approved By"
                                        : lettermodel
                                                    .message![index]
                                                    .approvalHistory![index1]
                                                    .status
                                                    .toString() ==
                                                "Rejected"
                                            ? "Rejected"
                                            : "Pending"),
                                const SizedBox(width: 10),
                                AppUtils.buildNormalText(
                                    text: lettermodel.message![index]
                                        .approvalHistory![index1].approvername
                                        .toString(),
                                    fontSize: 14),
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            AppUtils.buildNormalText(
                                text: lettermodel.message![index]
                                    .approvalHistory![index1].approveddate
                                    .toString()),
                            const SizedBox(
                              height: 10,
                            ),
                            AppUtils.buildNormalText(
                                text: lettermodel.message![index]
                                    .approvalHistory![index1].remarks
                                    .toString()),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          );
        });
  }

  void getdetailsdata({bool isLoadMore = false}) async {
    if (!mounted) return;
    if (isLoadMore) {
      setState(() => _isLoadingMore = true);
    } else {
      setState(() => loading = true);
      _page = 1;
      _hasMore = true;
      filteredList.clear();
    }

    try {
      final response =
          await ApiService.getletterrequest(page: _page, limit: _limit);
      if (!mounted) return;
      setState(() => loading = false);

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);

        if (jsonBody['status'].toString() == "true") {
          final newModel = ViewletterModel.fromJson(jsonBody);

          final newItems = newModel.message ?? [];
          if (newItems.isEmpty || newItems.length < _limit) {
            _hasMore = false;
          }

          setState(() {
            if (isLoadMore) {
              filteredList.addAll(newItems);
            } else {
              lettermodel = newModel;
              filteredList = newItems;
            }
          });
        } else {
          _hasMore = false;
        }
      } else {
        throw Exception("Server returned ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        loading = false;
        _isLoadingMore = false;
        _hasMore = false;
      });
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }

  Future<void> _loadMoreData() async {
    if (!_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    _page++;
    getdetailsdata(isLoadMore: true);
  }
}
