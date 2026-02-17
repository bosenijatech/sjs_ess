import 'dart:convert';
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/classmodel.dart';
import '../../models/curremcymodel.dart';
import '../../models/deptmodel.dart';
import '../../models/expcatmodel.dart';
import '../../models/expenseamuntmodel.dart';
import '../../models/filemodel.dart';
import '../../models/multiAttachModel.dart';
import '../../models/paycompmodel.dart';
import '../../models/subsidiarymodel.dart';
import '../../models/taxcodemodel.dart';
import '../../services/apiservice.dart';
import '../../services/filepickerservice.dart';
import '../../services/pref.dart';
import '../../utils/app_utils.dart';
import '../../utils/sharedprefconstants.dart';
import '../widgets/assets_image_widget.dart';

class ReimbursementApplyPage extends StatefulWidget {
  const ReimbursementApplyPage({super.key});

  @override
  State<ReimbursementApplyPage> createState() =>
      _ReimbursementApplyPagePageState();
}

class _ReimbursementApplyPagePageState extends State<ReimbursementApplyPage>
    with SingleTickerProviderStateMixin {
  final expcatKey = GlobalKey<DropdownSearchState<ExpCatModel>>();
  List<ExpenseRow> rows = [ExpenseRow()];
  final formKey = GlobalKey<FormState>();
  String getdeptId = "";
  String getdeptName = "";
  String payrollcomponentid = "";
  String payrollcomponentname = "";
  String getclassId = "";
  String getclassName = "";
  String getheaderSubId = "";
  String getheaderSubName = "";
  bool loading = false;
  late TabController _tabController;
  DeptModel? selectedDept;
  ClassModel? selectedclass;
  PayCompModel? selectedpayModel;
  SubsidiaryModel? selectSubsidiary;
  ExpCatModel? selectCategory;

  ExpAmountModel? selectedExpAmount;

  CurrencyModel? selectedCurrency;
  TaxModel? selectedTax;
  static const int maxAttachments = 5;
  List<AttachModel> attachments = [];

  List<MultiAttachModel> uploadedAttachments = [];
  void addRow() {
    setState(() {
      selectCategory = null;
      selectedExpAmount = null;
      selectedCurrency = null;
      selectedTax = null;

      rows.add(ExpenseRow());
    });
  }

  void removeRow(int index) {
    setState(() => rows.removeAt(index));
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    if (Prefs.getSubSidiaryId(SharefprefConstants.subsidiaryId) != null &&
        Prefs.getSubSidiaryName(SharefprefConstants.subsidiaryName) != null) {
      selectSubsidiary = SubsidiaryModel(
        id: _getSubsidiaryId(),
        name: Prefs.getSubSidiaryName(SharefprefConstants.subsidiaryName)
            .toString(),
        inactive: false,
      );
    } else {
      // Fallback if pref values are null or empty
      selectSubsidiary = null; // or assign a default model
    }
    _setDefaultPayrollComponent();
    super.initState();
  }

  int _getSubsidiaryId() {
    final rawId = Prefs.getSubSidiaryId(SharefprefConstants.subsidiaryId);
    if (rawId == null ||
        rawId.toString() == "null" ||
        rawId.toString().isEmpty) {
      return 0;
    }
    return int.tryParse(rawId.toString()) ?? 0;
  }

  void _setDefaultPayrollComponent() async {
    setState(() {
      loading = true;
    });
    List<PayCompModel> list = await ApiService.paycomponentlist(filter: "");
    if (list.isNotEmpty) {
      setState(() {
        selectedpayModel = list[0];
        payrollcomponentid = list[0].id.toString();
        payrollcomponentname = list[0].name.toString();
      });
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Example: you can call an API or pass data back
        Navigator.pop(context, true); // send result to previous screen
        return false; // prevent default pop, since we already did it manually
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color:
                Theme.of(context).colorScheme.onSurface, // adapts to dark/light
          ),
          title: Text("Expense Entry",
              style: TextStyle(
                  color:
                      Theme.of(context).colorScheme.onSurface) // fontSize: 16),
              ),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Expense"),
              Tab(text: "Attachments"),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Call calculate again in case some fields changed
                    for (var row in rows) {
                      row.calculate();
                    }

                    List<Map<String, dynamic>> jsonList =
                        rows.map((row) => row.toJson()).toList();

                    if (selectedDept == null) {
                      AppUtils.showSingleDialogPopup(context,
                          "Please Choose Department", "Ok", onexitpopup, null);
                    } else if (payrollcomponentid.toString().isEmpty) {
                      AppUtils.showSingleDialogPopup(
                          context,
                          "Please Choose Payroll Component",
                          "Ok",
                          onexitpopup,
                          null);
                    } else if (attachments.isEmpty) {
                      postParentRecord();
                    } else {
                      uploadAttachments();
                    }
                  }
                },
                icon: const Icon(Icons.save))
          ],
        ),
        body: !loading
            ? TabBarView(
                controller: _tabController,
                children: [
                  buildExpenseTab(),
                  buildAttachmentTab(),
                ],
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  Widget buildExpenseTab() {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerwidget(),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return buildrows(index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget buildAttachmentTab() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: const Text("Add Attachment"),
              onPressed: showAttachmentOptions),
          const SizedBox(height: 16),
          Expanded(
            child: attachments.isEmpty
                ? const Center(child: Text("No attachments added"))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: attachments.length,
                    itemBuilder: (_, index) {
                      final file = attachments[index];
                      return ListTile(
                        leading: Icon(
                          file.fileType == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                        ),
                        title: Text(file.fileName.toString()),
                        subtitle: Text("${file.fileSize} MB"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              attachments.removeAt(index);
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void showAttachmentOptions() {
    if (attachments.length >= maxAttachments) {
      AppUtils.showSingleDialogPopup(context, "Maximum $maxAttachments only",
          "ok", () => Navigator.pop(context), null);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _captureCameraImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text("File Picker"),
              onTap: () {
                Navigator.pop(context);
                pickMultiImage();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _captureCameraImage() async {
    if (attachments.length >= maxAttachments) {
      AppUtils.showSingleDialogPopup(context, "Maximum $maxAttachments only",
          "ok", () => Navigator.pop(context), null);

      return;
    }

    final attach = await CameraImageService.instance.getImageFromCamera();

    if (attach != null) {
      setState(() {
        attachments.add(attach); // ✅ ADD TO LIST
      });
    }
  }

  Future<void> pickImage() async {
    if (attachments.length >= maxAttachments) {
      AppUtils.showSingleDialogPopup(context, "Maximum $maxAttachments only",
          "ok", () => Navigator.pop(context), null);
      return;
    }

    final file = await CameraImageService.instance.pickFile();
    if (file == null) return;

    setState(() {
      attachments.add(file);
    });
  }

  Future<void> pickMultiImage() async {
    if (attachments.length >= maxAttachments) {
      AppUtils.showSingleDialogPopup(
        context,
        "Maximum $maxAttachments only",
        "Ok",
        () => Navigator.pop(context),
        null,
      );
      return;
    }

    final files = await CameraImageService.instance.pickMultipleFiles(
      remaining: maxAttachments - attachments.length,
    );

    // 🔴 IMPORTANT: Check empty list
    if (files.isEmpty) {
      print("No files selected");
      return;
    }

    setState(() {
      attachments.addAll(files); // ✅ ADD ALL
    });
  }

  Widget headerwidget() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shadowColor: theme.shadowColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              "Department",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            DropdownSearch<DeptModel>(
              selectedItem: selectedDept,
              validator: (value) =>
                  value == null ? 'Please select department' : null,
              asyncItems: (String filter) =>
                  ApiService.getDepartmentList(filter: filter),
              itemAsString: (DeptModel item) => item.name,
              onChanged: (value) {
                if (value != null) {
                  getdeptId = value.id.toString();
                  getdeptName = value.name.toString();
                  selectedDept =
                      DeptModel(id: int.parse(getdeptId), name: getdeptName);
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Select Department",
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? colorScheme.surfaceContainerHighest
                      : Colors.white, // 👈 dynamic fill color
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                searchFieldProps: TextFieldProps(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? colorScheme.surfaceContainerHighest
                        : Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                itemBuilder: (context, item, isSelected) => ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              "Payroll Component",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // 🟨 Payroll Dropdown
            DropdownSearch<PayCompModel>(
              selectedItem: selectedpayModel,
              validator: (value) =>
                  value == null ? 'Please select payroll component' : null,
              asyncItems: (String filter) =>
                  ApiService.paycomponentlist(filter: filter),
              itemAsString: (PayCompModel item) => item.name,
              onChanged: (value) {
                if (value != null) {
                  payrollcomponentid = value.id.toString();
                  payrollcomponentname = value.name.toString();
                  selectedpayModel = PayCompModel(
                    id: value.id,
                    name: value.name,
                    paygrpinpayrollcomp: value.paygrpinpayrollcomp,
                  );
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  hintText: "Select Payroll Component",
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? colorScheme.surfaceContainerHighest
                      : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  labelStyle: TextStyle(color: colorScheme.onSurface),
                  hintStyle:
                      TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.4),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                itemBuilder: (context, item, isSelected) => ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> postParentRecord() async {
    setState(() {
      loading = true;
    });

    try {
      DateTime now = DateTime.now();
      int currentYear = now.year;
      String currentMonthName = DateFormat('MMMM').format(now);

      final body = {
        "data": {
          "empid": Prefs.getNsID(SharefprefConstants.sharednsid),
          "empname": Prefs.getFullName(SharefprefConstants.shareFullName),
          "exchangerate": "1.00",
          "approvalstatus": "2",
          "approvaluserrole": "1059",
          "expensecurrency": "1",
          "departmentid": getdeptId,
          "departmentname": getdeptName,
          "paymonth": currentMonthName,
          "payyear": currentYear,
          "classid": getclassId,
          "classname": getclassName,
          "date": DateFormat('dd/MM/yyyy').format(now),
          "paygroupid":
              Prefs.getPayGroupId(SharefprefConstants.sharedpaygroupid),
          "paygroupname":
              Prefs.getPayGroupName(SharefprefConstants.sharedpaygroupname),
          "totalamt": rows
              .fold(0.0, (sum, row) => sum + row.grossAmount)
              .toStringAsFixed(2),
          "subsidiary": selectSubsidiary!.id.toString(),
          "payrollcomponentid": payrollcomponentid,
          "payrollcomponentname": payrollcomponentname,
          "uploadedAttachments":
              uploadedAttachments.map((e) => e.toJson()).toList(),
        }
      };

      log("Header : ${jsonEncode(body)}");

      final response = await ApiService.postexpparent(body);

      setState(() {
        loading = false;
      });

      final resJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (resJson['status'].toString() == "true") {
          final parentId = resJson['parentId'].toString();
          await postLineItems(parentId);
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            resJson['message'],
            "Ok",
            onexitpopup,
            AssetsImageWidget.warningimage,
          );
        }
      } else {
        throw Exception(resJson['message']);
      }
    } catch (e) {
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

  Future<void> uploadAttachments() async {
    setState(() {
      loading = true;
    });

    try {
      final payload = {
        "attachment": attachments
            .map((e) => {
                  "FileData": e.fileData.toString(),
                  "FileType": e.fileType.toString(),
                  "FileName": e.fileName.toString(),
                })
            .toList(),
      };

      final response = await ApiService.postmultitattachment(payload);
      final resJson = jsonDecode(response.body);

      if (resJson['status'] == true) {
        final List<MultiAttachModel> files = (resJson['files'] as List)
            .map((e) => MultiAttachModel.fromJson(e))
            .toList();

        setState(() {
          uploadedAttachments.clear();
          uploadedAttachments.addAll(files); // ✅ APPEND
          attachments.clear();
        });

        //print(uploadedAttachments.map((e) => e.toJson()).toList());
        postParentRecord();
      } else {
        throw Exception(resJson['message']);
      }
    } catch (e) {
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void onexitpopup() {
    AppUtils.pop(context);
  }

  void onrefreshscreen() {
    AppUtils.pop(context);
    AppUtils.pop(context);
  }

  Future<void> postLineItems(String parentId) async {
    setState(() {
      loading = true;
    });

    try {
      final now = DateTime.now();
      final formatter = DateFormat('dd/MM/yyyy');

      List<Map<String, dynamic>> lineItems = rows.map((row) {
        row.calculate();
        return {
          "parentid": parentId,
          "data": {
            "date": formatter.format(now),
            "expensecategory": row.category,
            "subsidiary": selectSubsidiary!.id.toString(),
            "class": getclassId ?? "",
            "department": getdeptId ?? "",
            "amount": row.amount.toStringAsFixed(2),
            "currency": row.currency ?? "",
            "exchangerate": row.exchangeRate.toStringAsFixed(2),
            "forignamount": row.foreignAmount.toStringAsFixed(2),
            "taxcode": row.taxCode ?? "",
            "taxrate": "${(row.taxRate).toStringAsFixed(2)}%",
            "grossamount": row.grossAmount.toStringAsFixed(2),
            "account": row.account ?? "",
            "taxamount": row.taxAmount.toStringAsFixed(2),
          }
        };
      }).toList();

      log("details ${jsonEncode(lineItems)}");

      final response = await ApiService.postexpdetails(lineItems);

      setState(() {
        loading = false;
      });

      final resJson = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (resJson['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
            context,
            resJson['message'],
            "Ok",
            refreshscreen,
            AssetsImageWidget.warningimage,
          );
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            resJson['message'],
            "Ok",
            onexitpopup,
            AssetsImageWidget.warningimage,
          );
        }
      } else {
        throw Exception(resJson['message'].toString());
      }
    } catch (e) {
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

  void refreshscreen() {
    AppUtils.pop(context);
    Navigator.pop(context, true);
  }

  Widget buildrows(int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: theme.cardColor,
      elevation: 3,
      shadowColor: theme.shadowColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🧾 Header Row
            Row(
              children: [
                Text(
                  "Expense #${index + 1}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => addRow(),
                  icon: Icon(
                    CupertinoIcons.add_circled,
                    color: colorScheme.primary,
                  ),
                ),
                if (rows.length > 1)
                  IconButton(
                    onPressed: () => removeRow(index),
                    icon: Icon(
                      CupertinoIcons.clear_circled,
                      color: colorScheme.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // 🟢 Category
            AppUtils.buildNormalText(
              text: "Select Category",
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            DropdownSearch<ExpCatModel>(
              selectedItem: rows[index].selectedCategory,
              validator: (value) =>
                  value == null ? 'Please select a category' : null,
              asyncItems: (String filter) =>
                  ApiService.getCategoryList(filter: filter),
              itemAsString: (ExpCatModel item) => item.name,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    rows[index].category = value.id.toString();
                  });
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? colorScheme.surfaceContainerHighest
                      : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 1.3),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                itemBuilder: (context, item, isSelected) => ListTile(
                  title: Text(
                    item.name,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 🟡 Expense Account
            AppUtils.buildNormalText(
              text: "Select Expense Account",
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            DropdownSearch<ExpAmountModel>(
              selectedItem: selectedExpAmount,
              asyncItems: (String filter) =>
                  ApiService.getexpenseAccount(filter: filter),
              itemAsString: (ExpAmountModel item) => item.acctName,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    rows[index].account = value.id.toString();
                    rows[index].selectedExpAmount = value;
                  });
                }
              },
              dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? colorScheme.surfaceContainerHighest
                      : Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: colorScheme.primary, width: 1.3),
                  ),
                ),
              ),
              popupProps: PopupProps.menu(
                showSearchBox: true,
                itemBuilder: (context, item, isSelected) => ListTile(
                  title: Text(
                    item.acctName,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 💰 Foreign Amount
            AppUtils.buildNormalText(
              text: "Foreign Amount",
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: rows[index].foreignAmountControllrt,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                rows[index].calculate();
              },
            ),

            const SizedBox(height: 10),

            // 🧾 Currency and Tax Code
            Row(
              children: [
                Expanded(
                  child: AppUtils.buildNormalText(
                      text: "Currency",
                      color: colorScheme.onSurface.withOpacity(0.8)),
                ),
                Expanded(
                  child: AppUtils.buildNormalText(
                      text: "Tax Code",
                      color: colorScheme.onSurface.withOpacity(0.8)),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownSearch<CurrencyModel>(
                    selectedItem: selectedCurrency,
                    asyncItems: (String filter) =>
                        ApiService.getCurrencyList(filter: filter),
                    itemAsString: (CurrencyModel item) => item.name,
                    onChanged: (value) async {
                      if (value != null) {
                        final rate = await ApiService.getExchangeRate(
                          baseCurrencyId: "1",
                          transactionCurrencyId: value.id.toString(),
                        );
                        setState(() {
                          rows[index].selectedCurrency = value;
                          rows[index].currency = value.id.toString();
                          rows[index].exchangeRate =
                              double.tryParse(rate ?? '0') ?? 0.0;
                          rows[index].calculate();
                        });
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? colorScheme.surfaceContainerHighest
                            : Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorScheme.primary, width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: DropdownSearch<TaxModel>(
                    selectedItem: selectedTax,
                    asyncItems: (String filter) =>
                        ApiService.getTaxCodeList(filter: filter),
                    itemAsString: (TaxModel item) =>
                        "${item.taxocode} ${item.rate}",
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          rows[index].selectedTax = value;
                          double parsedTaxRate = 0.0;
                          if (value.rate.contains('%')) {
                            final cleaned =
                                value.rate.replaceAll('%', '').trim();
                            parsedTaxRate = double.tryParse(cleaned) ?? 0.0;
                          }
                          rows[index].taxRate = parsedTaxRate;
                          rows[index].taxCode = value.id;
                          rows[index].calculate();
                        });
                      }
                    },
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        filled: true,
                        fillColor: theme.brightness == Brightness.dark
                            ? colorScheme.surfaceContainerHighest
                            : Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorScheme.outline.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: colorScheme.primary, width: 1.2),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📝 Memo
            AppUtils.buildNormalText(
              text: "Memo",
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: rows[index].memoController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest
                    : Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🧮 Totals
            Divider(color: colorScheme.outline.withOpacity(0.2)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Exchange Rate: ${rows[index].exchangeRate.toStringAsFixed(2)}",
                    style: theme.textTheme.bodySmall),
                Text("Amount: ${rows[index].amount.toStringAsFixed(2)}",
                    style: theme.textTheme.bodySmall),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tax Rate: ${rows[index].taxRate.toStringAsFixed(2)}",
                    style: theme.textTheme.bodySmall),
                Text("Tax Amount: ${rows[index].taxAmount.toStringAsFixed(2)}",
                    style: theme.textTheme.bodySmall),
              ],
            ),
            Text("Gross Amount: ${rows[index].grossAmount.toStringAsFixed(2)}",
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class ExpenseRow {
  String? category;
  String? account;
  String? subsidiary;
  String? currency;
  String? taxCode;

  ExpCatModel? selectedCategory;
  ExpAmountModel? selectedExpAmount;
  CurrencyModel? selectedCurrency;
  TaxModel? selectedTax;

  final TextEditingController foreignAmountControllrt = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  // Calculated fields
  double exchangeRate = 0.0;
  double amount = 0.0;
  double taxRate = 0; // Default 18%
  double taxAmount = 0.0;
  double grossAmount = 0.0;

  double get foreignAmount =>
      double.tryParse(foreignAmountControllrt.text) ?? 0;

  String? get memo => memoController.text;

  void calculate() {
    final double foreignAmountVal = foreignAmount;

    if (foreignAmountVal > 0 && exchangeRate > 0) {
      amount = foreignAmountVal * exchangeRate;
      taxAmount = amount * taxRate / 100;
      grossAmount = amount + taxAmount;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'expensecategory': category,
      'account': account,
      'foreignAmount': foreignAmount,
      'subsidiary': subsidiary,
      'currency': currency,
      'exchangeRate': exchangeRate,
      'amount': amount,
      'taxCode': taxCode,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'grossAmount': grossAmount,
      'memo': memo,
    };
  }
}
