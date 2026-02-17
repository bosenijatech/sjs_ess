
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:developer' as log;

import '../../models/checkcompoffmodel.dart';
import '../../models/error_model.dart';
import '../../models/filemodel.dart';
import '../../models/leavebalancemodel copy.dart';
import '../../models/leavetypemodel.dart';
import '../../services/apiservice.dart';
import '../../services/filepickerservice.dart';
import '../../services/pref.dart';
import '../../services/uploadservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../../utils/constants.dart';
import '../../utils/sharedprefconstants.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_daterange_picker.dart';

class LeaveApplyPage extends StatefulWidget {
  const LeaveApplyPage({super.key});

  @override
  State<LeaveApplyPage> createState() => _LeaveApplyPageState();
}

class _LeaveApplyPageState extends State<LeaveApplyPage> {
  final leaveTypekey = GlobalKey<DropdownSearchState<LeaveTypeModel>>();
  final balancekey = GlobalKey<DropdownSearchState<LeaveBalanceModel>>();

  LeaveTypeModel? selectedLeaveType;
  LeaveBalanceModel? selectedLeavebalance;

  List<LeaveBalanceModel> leaveBalances = [];
  //List<LeaveTypeModel> leaveTypes = [];

  double? noofdays = 0.00;
  bool? check1 = false;
  bool loading = false;
  ErrorModelNetSuite errormodel = ErrorModelNetSuite();
  GetCountCompOffModel chekcount = GetCountCompOffModel();
  List<String> leavetypelist = [];

  String? alterleavetypecode = "";
  String? alterleavetypename = "";
  double? balancetakenleave = 0;
  String? isairticketrequired = "No";

  DateFormat customdateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  TextEditingController frmdatecontroller = TextEditingController();
  TextEditingController todatecontroller = TextEditingController();

  TextEditingController subfrmdatecontroller = TextEditingController();
  TextEditingController subtodatecontroller = TextEditingController();

  TextEditingController attachcontroller = TextEditingController();
  TextEditingController airticketamountcontroller = TextEditingController();
  TextEditingController reasoncontroller = TextEditingController();
  TextEditingController airticketattachmentcontroller = TextEditingController();

  String? selectedValue;
  final TextEditingController textEditingController = TextEditingController();
  final picker = ImagePicker();
  File? imagefile;
  int? selection = 0;

  DateTime? startDate;
  DateTime? endDate;
  List<AttachModel> attachlist = [];

  String attachmentID = "";
  String attachmentURL = "";
  bool isHalfday = false;
  bool isAmPm = false;
  bool isEditable = true;
  String iscompoffid = "";

  bool isValidatefailed = false;
  bool isEndDateEnabled = false;

  @override
  void initState() {
   

    super.initState();
  }

  @override
  void dispose() {
    frmdatecontroller.clear();
    textEditingController.clear();
    todatecontroller.clear();
    attachcontroller.clear();
    subfrmdatecontroller.clear();
    subtodatecontroller.clear();
    airticketamountcontroller.clear();
    airticketattachmentcontroller.clear();
    reasoncontroller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? colorScheme.surfaceContainerHighest // nice dark container
          : Colors.white,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 2,
        shadowColor: Colors.black54,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppUtils.buildNormalText(
            text: "Leave Application",
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context)
                .colorScheme
                .onSurface), // 👈 auto theme color fontSize: 20),
        centerTitle: true,
      ),
      body: !loading
          ? SingleChildScrollView(
              child: Column(
                children: [getdetails(context)],
              ),
            )
          : Center(
              child: CupertinoActivityIndicator(
                radius: 30.0,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
    );
  }

  Widget getdetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surfaceContainerHighest // nice dark container
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text(
            "LEAVE TYPE",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),

          DropdownSearch<LeaveTypeModel>(
            key: leaveTypekey,
            selectedItem: selectedLeaveType,
            popupProps: const PopupProps.menu(showSearchBox: true),
            asyncItems: (String filter) => ApiService.getleaveType(
                filter: filter, excludeLeaveTypeId: "4"),
            itemAsString: (LeaveTypeModel item) =>
                item.leaveTypeName.toString(),
            onChanged: (LeaveTypeModel? item) async {
              selectedLeaveType = item;
              setState(() => loading = true);
              leaveBalances = await ApiService.getleavebalance();
              setState(() {
                loading = false;
                checkLeaveBalanceSection();
              });
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Leave Type *',
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest // dark mode fill
                    : Colors.white,
                hintStyle:
                    TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
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
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              selectedLeaveType != null
                  ? '${balancetakenleave!.toStringAsFixed(2)} days Available'
                  : "0 days Available",
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    balancetakenleave! > 0 ? Colors.green : colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Date Pickers Row ---
          Row(
            children: [
              Expanded(
                flex: 4,
                child: TextField(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      frmdatecontroller.text =
                          DateFormat("dd/MM/yyyy").format(pickedDate);
                      subfrmdatecontroller.text = formattedDate;
                      setState(() => isEndDateEnabled = true);
                      validatedate(
                          subfrmdatecontroller.text, subtodatecontroller.text);
                    }
                  },
                  controller: frmdatecontroller,
                  readOnly: true,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'START DATE',
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? colorScheme.surfaceContainerHighest // dark mode fill
                        : Colors.white,
                    labelStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      "${noofdays.toString()} ${noofdays == 1.00 ? "day" : "days"}",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: TextField(
                  onTap: () async {
                    if (!isEndDateEnabled) {
                      AppUtils.showSingleDialogPopup(
                          context,
                          "Please choose Start Date first",
                          "Ok",
                          onexitpopup,
                          AssetsImageWidget.warningimage);
                      return;
                    }
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                      todatecontroller.text =
                          DateFormat("dd/MM/yyyy").format(pickedDate);
                      subtodatecontroller.text = formattedDate;
                      validatedate(
                          subfrmdatecontroller.text, subtodatecontroller.text);
                    }
                  },
                  controller: todatecontroller,
                  readOnly: true,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'END DATE',
                    filled: true,
                    fillColor: theme.brightness == Brightness.dark
                        ? colorScheme.surfaceContainerHighest // dark mode fill
                        : Colors.white,
                    labelStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: colorScheme.primary, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // --- Half Day & AM/PM Switches ---
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CupertinoSwitch(
                  value: isHalfday,
                  activeTrackColor: colorScheme.primary,
                  onChanged: isEditable
                      ? (value) {
                          setState(() {
                            if (noofdays! > 1.0 && value) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "You cannot select half day for more than one day leave",
                                  "Ok",
                                  onexitpopup,
                                  AssetsImageWidget.warningimage);
                              return;
                            }
                            isHalfday = value;
                            noofdays = value ? 0.5 : 1.0;
                          });
                        }
                      : null,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text("Half day",
                    style: TextStyle(color: colorScheme.onSurface)),
              ),
              Expanded(
                flex: 2,
                child: CupertinoSwitch(
                  value: isAmPm,
                  activeTrackColor: colorScheme.primary,
                  onChanged: isEditable
                      ? (value) => setState(() => isAmPm = value)
                      : null,
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  isAmPm ? "Forenoon" : "Afternoon",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (isValidatefailed)
            Text(
              'You cannot request leave for holidays or weekly offs.',
              style: TextStyle(
                color: colorScheme.error,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),

          const SizedBox(height: 10),

          // --- Leave Reason ---
          Text("Leave Reason",
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: reasoncontroller,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Enter Reason",
              hintStyle:
                  TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest // dark mode fill
                  : Colors.white,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: colorScheme.outline.withOpacity(0.4)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- Attachment ---
          Text("Attachment",
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // TextField(
          //   readOnly: true,
          //   controller: attachcontroller,
          //   style: TextStyle(color: colorScheme.onSurface),
          //   decoration: InputDecoration(
          //     hintText: "Click here to Attach file (Max 2 MB)",
          //     hintStyle:
          //         TextStyle(color: colorScheme.onSurface.withOpacity(0.5)),
          //     suffixIcon: IconButton(
          //       icon: Icon(Icons.attach_file, color: colorScheme.primary),
          //       onPressed: () {
          //         AppUtils.showBottomCupertinoDialog(context,
          //             title: "Choose any one option", btn1function: () async {
          //           AppUtils.pop(context);
          //           _captureCameraImage();
          //         }, btn2function: () {
          //           AppUtils.pop(context);
          //           _pickFile();
          //         });
          //       },
          //     ),
          //   ),
          // ),
          attachmentPicker(context),
          const SizedBox(height: 30),

          // --- Submit Button ---
          CustomButton(
            onPressed: () {
              if (noofdays == 0 || noofdays == null) {
                AppUtils.showSingleDialogPopup(
                    context,
                    "No of Days cannot be zero",
                    "Ok",
                    onexitpopup,
                    AssetsImageWidget.warningimage);
              } else if (alterleavetypecode!.isEmpty) {
                AppUtils.showSingleDialogPopup(
                    context,
                    "Please Select Leave Type",
                    "Ok",
                    onexitpopup,
                    AssetsImageWidget.warningimage);
              } else if (frmdatecontroller.text.isEmpty) {
                AppUtils.showSingleDialogPopup(
                    context,
                    "Please Choose From Date",
                    "Ok",
                    onexitpopup,
                    AssetsImageWidget.warningimage);
              } else if (todatecontroller.text.isEmpty) {
                AppUtils.showSingleDialogPopup(context, "Please Choose To Date",
                    "Ok", onexitpopup, AssetsImageWidget.warningimage);
              } else if (reasoncontroller.text.isEmpty) {
                AppUtils.showSingleDialogPopup(context, "Please Enter Reason",
                    "Ok", onexitpopup, AssetsImageWidget.warningimage);
              } else if (alterleavetypecode.toString() == "2" &&
                  noofdays! >= 2 &&
                  attachlist.isEmpty) {
                AppUtils.showSingleDialogPopup(
                    context,
                    "While apply Sick Leave More than 2 two days Attchment is Mandatory!",
                    "Ok",
                    onexitpopup,
                    AssetsImageWidget.warningimage);
              } else if (attachlist.isEmpty) {
                attachlist.clear();
                onpostleave();
              } else {
                onUpload();
              }
            },
            name: "Submit",
            circularvalue: 30,
            fontSize: 14,
          )
        ],
      ),
    );
  }

  Future<void> _captureCameraImage() async {
    final attach = await CameraImageService.instance.getImageFromCamera();
    if (attach != null) {
      setState(() {
        attachlist.clear();
        attachlist.add(attach);
        attachcontroller.text = attach.fileName ?? '';
      });
      //upload
    }
  }

  Future<void> _pickFile() async {
    final attach = await CameraImageService.instance.pickFile();
    if (attach != null) {
      setState(() {
        attachlist.clear();
        attachlist.add(attach);
        attachcontroller.text = attach.fileName ?? '';
      });
    }
  }

  void onUpload() async {
    setState(() => loading = true);

    final result =
        await UploadService.instance.uploadAttachment(context, attachlist);

    setState(() => loading = false);

    if (result != null && result['status'] == true) {
      attachmentID = result['fileId'];
      attachmentURL = result['url'];
      onpostleave(); // your existing next step
    }
  }

  void showdaterange() {
    showCustomDateRangePicker(
      context,
      dismissible: true,
      minimumDate: DateTime.now(),
      //maximumDate: DateTime.now().add(const Duration(days: 90)),
      maximumDate: DateTime(DateTime.now().year, 12, 31),
      endDate: endDate,
      startDate: startDate,
      backgroundColor: Colors.white,
      primaryColor: Appcolor.black,
      onApplyClick: (start, end) {
        setState(() {
          endDate = end;
          startDate = start;
          frmdatecontroller.text = "";
          todatecontroller.text = "";
          subfrmdatecontroller.text = "";
          subtodatecontroller.text = "";

          String formattedDate = DateFormat('yyyy-MM-dd').format(start);
          var dateFormate =
              DateFormat("dd-MM-yyyy").format(DateTime.parse(formattedDate));
          frmdatecontroller.text = dateFormate;
          subfrmdatecontroller.text = formattedDate;

          String formattedDate1 = DateFormat('yyyy-MM-dd').format(end);
          var dateFormate1 =
              DateFormat("dd-MM-yyyy").format(DateTime.parse(formattedDate1));
          todatecontroller.text = dateFormate1;
          subtodatecontroller.text = formattedDate1;
          validatedate(subfrmdatecontroller.text, subtodatecontroller.text);
          setState(() {
            selection = 3;
          });
        });
      },
      onCancelClick: () {
        setState(() {
          endDate = null;
          startDate = null;
        });
      },
    );
  }

  Widget attachmentPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        AppUtils.showBottomCupertinoDialog(context,
            title: "Choose any one option", btn1function: () async {
          AppUtils.pop(context);
          _captureCameraImage();
        }, btn2function: () {
          AppUtils.pop(context);
          _pickFile();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? colorScheme.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.4),
            width: 1,
          ),
          boxShadow: theme.brightness == Brightness.dark
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  Icon(Icons.attach_file, color: colorScheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                attachcontroller.text.isEmpty
                    ? "Click to attach file (Max 2 MB)"
                    : attachcontroller.text,
                style: TextStyle(
                  color: attachcontroller.text.isEmpty
                      ? colorScheme.onSurface.withOpacity(0.6)
                      : colorScheme.onSurface,
                  fontWeight: attachcontroller.text.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (attachcontroller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.error, size: 20),
                onPressed: () {
                  setState(() {
                    attachcontroller.clear();
                    attachlist.clear();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void validatedate(from, to) {
    if (from.toString().isNotEmpty && to.toString().isNotEmpty) {
      String concatefrom = '${subfrmdatecontroller.text} 00:00:00';
      String concateto = '${subtodatecontroller.text} 00:00:00';

      DateTime dt1 = DateTime.parse(concatefrom);
      DateTime dt2 = DateTime.parse(concateto);

      Duration diff = dt2.difference(dt1);

      if (diff.inDays >= 0) {
        print(from);
        print(to);
        if (alterleavetypecode.toString().isNotEmpty &&
            from.toString().isNotEmpty &&
            to.toString().isNotEmpty) {
          validationfromandtodate(
              AppConstants.formatDateleave(from),
              AppConstants.formatDateleave(to),
              alterleavetypecode!.toString(),
              Prefs.getEmpID(SharefprefConstants.sharednsid).toString());
        }
      } else {
        frmdatecontroller.clear();
        todatecontroller.clear();
        subfrmdatecontroller.clear();
        subtodatecontroller.clear();
        from = "";
        to = "";
        AppUtils.showSingleDialogPopup(
            context,
            'From date and To Date is Mismatched!',
            "Ok",
            onexitpopup,
            AssetsImageWidget.errorimage);
      }
    } else {}
  }

  void oncleardate() {
    AppUtils.pop(context);
    frmdatecontroller.clear();
    todatecontroller.clear();
    subfrmdatecontroller.clear();
    subtodatecontroller.clear();

    frmdatecontroller.text = "";
    todatecontroller.text = "";
    subfrmdatecontroller.text = "";
    subtodatecontroller.text = "";
    noofdays = 0;
    selection = 0;
    startDate = null;
    endDate = null;
    setState(() {});
  }

  void onexitpopup() {
    Navigator.of(context).pop();
  }

  void checkLeaveBalanceSection() {
    final item = selectedLeaveType;

    if (item == null) return;

    /// ✅ Half-day allowed?
    isEditable = item.allowhalfday == "T";

    /// ✅ Match leave balance for that type
    final match = leaveBalances.firstWhere(
      (e) => e.leaveTypeId.toString() == item.leaveTypeId.toString(),
      orElse: () => LeaveBalanceModel(
        internalId: "",
        empId: "",
        employeeName: "",
        leaveTypeId: "",
        leaveTypeName: "",
        yearlyLeaveBalance: "0",
        leaveBalanceCredited: "0",
        leaveBalanceTaken: "0",
        totalAppliedDays: "0",
        availableLeaveBalance: "0",
      ),
    );

    balancetakenleave = double.tryParse(match.availableLeaveBalance) ?? 0;

    alterleavetypecode = item.leaveTypeId.toString();
    alterleavetypename = item.leaveTypeName.toString();

    /// ✅ Clear date fields
    frmdatecontroller.clear();
    todatecontroller.clear();
    subfrmdatecontroller.clear();
    subtodatecontroller.clear();
  }

  

  void onrefreshscreen() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void onpostleave() async {
    var currentyear = DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now());
    var json = {
      "leaveapplicationno":
          "${"Mob"}-Leave-${Prefs.getEmpID('empID').toString()}-$currentyear",
      "date": ApiService.mobilecurrentdate,
      "leavetypecode": alterleavetypecode,
      "leavetypename": alterleavetypename,
      "leavebalance": balancetakenleave,
      "fromdate": subfrmdatecontroller.text,
      "todate": subtodatecontroller.text,
      "total_no_of_days": noofdays ?? "0",
      "halfday": isHalfday ? "Y" : "N",
      "halfdaysession": isAmPm ? "AN" : "FN",
      "attachment": attachlist.isEmpty ? "" : attachlist,
      "reason": reasoncontroller.text,
      "airticketrequired": isairticketrequired,
      "airticketamount": airticketamountcontroller.text.isEmpty
          ? 0
          : airticketamountcontroller.text,
      "airticketattachment": airticketattachmentcontroller.text.isEmpty
          ? ""
          : 'public/${attachcontroller.text.toString()}',
      "iscancelled": "N",
      "iscancelledreason": "",
      "iscancelleddate": "",
      "isstatus": "Pending Approval",
      "createdby": Prefs.getNsID('nsid'),
      "createdByEmpName": Prefs.getFullName('Name'),
      "createdDate": ApiService.mobilecurrentdate,
      "toEmpID": Prefs.getNsID('nsid'),
      "toEmpCode": Prefs.getEmpID(
        SharefprefConstants.sharedempId,
      ),
      "toEmpName": Prefs.getFullName('Name'),
      "isSync": 0,
      "NetsuiteRefNo": "",
      "NetsuiteRemarks": "",
      "Source": "Mob",
      "attachDocument": attachlist.isEmpty ? "F" : "T",
      "imageUrl": attachmentURL,
      "supervisorId": "",
      "linemanagerId": "",
      "hodId": "",
    };
    log.log('data: ${jsonEncode(json)}');
    setState(() {
      loading = true;
    });
    ApiService.postleave(json).then((response) {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'],
              "Ok",
              onrefreshscreen,
              AssetsImageWidget.successimage);

          setState(() {});
        } else {
          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'],
              "Ok",
              onexitpopup,
              AssetsImageWidget.warningimage);
        }
      } else {
        AppUtils.showSingleDialogPopup(
            context,
            jsonDecode(response.body)['message'],
            "Ok",
            onexitpopup,
            AssetsImageWidget.warningimage);
      }
    }).catchError((e) {
      setState(() {
        loading = false;
      });
      AppUtils.showSingleDialogPopup(context, e.toString(), "Ok", onexitpopup,
          AssetsImageWidget.errorimage);
    });
  }

  void validationfromandtodate(
      String fromdate, String todate, String leavetypeId, String nsId) async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final response =
          await ApiService.validatedate(fromdate, todate, leavetypeId, nsId);

      setState(() => loading = false);

      if (response.statusCode != 200) {
        throw Exception("Server Error");
      }

      final responseBody = jsonDecode(response.body);
      print("🟢 VALIDATION RESPONSE: $responseBody");

      // ✔ correct success check
      if (responseBody['success'] != true) {
        AppUtils.showSingleDialogPopup(
          context,
          responseBody['message'] ?? "Validation failed",
          "Ok",
          onexitpopup,
          AssetsImageWidget.errorimage,
        );
        return;
      }

      // ✔ correct list key = payload
      final messages = responseBody["payload"];
      List<String> msgList = [];

      if (messages is List) {
        msgList = messages.map((e) => e.toString()).toList();
      }

      print("📌 Parsed Messages = $msgList");

      // If no messages
      if (msgList.isEmpty) {
        setState(() {
          noofdays = (responseBody['finaldays'] ?? 0).toDouble();
          isValidatefailed = false;
        });
        return;
      }

      // Extract statuses
      String? fromStatus;
      String? toStatus;

      for (var line in msgList) {
        if (line.startsWith(fromdate)) {
          fromStatus = line.split(" - ").last.trim().toLowerCase();
        }
        if (line.startsWith(todate)) {
          toStatus = line.split(" - ").last.trim().toLowerCase();
        }
      }

      fromStatus ??= "invalid";
      toStatus ??= "invalid";

      print("FROM = $fromStatus, TO = $toStatus");

      // ❌ If either FROM or TO is weekly-off/holiday
      if (fromStatus != "normal" || toStatus != "normal") {
        setState(() {
          noofdays = 0.0;
          isValidatefailed = true;
        });

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Leave Validation"),
            content:
                const Text("You cannot apply leave on Week-off / Holiday."),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              )
            ],
          ),
        );

        return;
      }

      // ✔ success → set finaldays
      setState(() {
        noofdays = (responseBody['finaldays'] ?? 0).toDouble();
        isValidatefailed = false;
      });

      print("🎯 FINAL DAYS SET = $noofdays");
    } catch (e) {
      if (mounted) {
        setState(() => loading = false);
        AppUtils.showSingleDialogPopup(
          context,
          e.toString(),
          "Ok",
          clearfromandtodate,
          AssetsImageWidget.errorimage,
        );
      }
    }
  }

  void clearfromandtodate() {
    Navigator.of(context).pop();
    frmdatecontroller.clear();

    todatecontroller.clear();
    subfrmdatecontroller.clear();
    subtodatecontroller.clear();
    frmdatecontroller.text = "";
    todatecontroller.text = "";
    subfrmdatecontroller.text = "";
    subtodatecontroller.text = "";
    noofdays = 0;
    setState(() {});
  }

  void exitalert() {
    Navigator.of(context).pop();
  }
}
