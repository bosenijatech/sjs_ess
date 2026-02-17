import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

import '../../models/addairticketmodel.dart';
import '../../models/assetnamemodel.dart';
import '../../models/assettypemodel.dart';
import '../../models/filemodel.dart';
import '../../services/apiservice.dart';
import '../../services/filepickerservice.dart';
import '../../services/pref.dart';
import '../../services/uploadservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/custom_button.dart';

class Airticketrequest extends StatefulWidget {
  const Airticketrequest({super.key});

  @override
  State<Airticketrequest> createState() => _AirticketrequestState();
}

class _AirticketrequestState extends State<Airticketrequest> {
  final assetTypekey = GlobalKey<DropdownSearchState<AssetTypeModel>>();
  final assetnamekey = GlobalKey<DropdownSearchState<AssetNameModel>>();

  AddAirTicketModel? selectedAssetType;
  AddAirTicketModel? selectedName;
  String? selectedclassType;
  DateTime? selectedDepartureDate;
  bool isReturnEnabled = false;

  bool? check1 = false;
  bool loading = false;
  TextEditingController attachcontroller = TextEditingController();
  TextEditingController remarkscontroller = TextEditingController();

  TextEditingController purposeoftravelcontroller = TextEditingController();
  TextEditingController fromlocationcontroller = TextEditingController();
  TextEditingController tolocationcontroller = TextEditingController();
  TextEditingController departurecontroller = TextEditingController();
  TextEditingController returndatecontroller = TextEditingController();

  List<AttachModel> attachlist = [];
  final picker = ImagePicker();
  File? imagefile;
  String attachmentID = "";
  String attachmentURL = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    remarkscontroller.clear();
    super.dispose();
  }

  DateTime? startDate;
  DateTime? endDate;

  int noOfDays = 0;

  void calculateDays() {
    if (startDate != null && endDate != null) {
      setState(() {
        noOfDays = endDate!.difference(startDate!).inDays + 1;
      });
    }
  }

  //attachment

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
     
      addticket();
      
    }
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
            text: "Airticket Request",
            color:
                Theme.of(context).colorScheme.onSurface, // 👈 auto theme color
            fontWeight: FontWeight.bold,
            fontSize: 20),
        centerTitle: false,
      ),
      body: !loading
          ? SingleChildScrollView(
              child: Column(
                children: [getdetails()],
              ),
            )
          : const Center(
              child: CupertinoActivityIndicator(
                  radius: 30.0, color: Appcolor.twitterBlue),
            ),
    );
  }

  Widget getdetails() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppUtils.buildNormalText(
            text: "PURPOSE OF TRAVEL",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: purposeoftravelcontroller,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Purpose of Travel*",
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6), // 👈 hint adapts
              ),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(
            text: "FROM LOCATION",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: fromlocationcontroller,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "From Location*",
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6), // 👈 hint adapts
              ),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(
            text: "TO LOCATION",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: tolocationcontroller,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "To Location*",
              hintStyle: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6), // 👈 hint adapts
              ),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(
            text: "DEPARTURE DATE",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: departurecontroller,
            readOnly: true,
            showCursor: false,
            onTap: () async {
              FocusScope.of(context).unfocus();

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  selectedDepartureDate = pickedDate;
                  departurecontroller.text =
                      DateFormat('dd-MM-yyyy').format(pickedDate);

                  // enable return date
                  isReturnEnabled = true;
                  returndatecontroller.clear();
                });
              }
            },
            decoration: InputDecoration(
              hintText: "Departure Date *",
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppUtils.buildNormalText(
            text: "RETURN DATE",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: returndatecontroller,
            readOnly: true,
            showCursor: false,
            onTap: () async {
              if (!isReturnEnabled) return;

              FocusScope.of(context).unfocus();

              if (selectedDepartureDate == null) return;

              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate:
                    selectedDepartureDate!.add(const Duration(days: 1)),
                firstDate: selectedDepartureDate!.add(const Duration(days: 1)),
                lastDate: DateTime(2100),
              );

              if (pickedDate != null) {
                setState(() {
                  returndatecontroller.text =
                      DateFormat('dd-MM-yyyy').format(pickedDate);
                });
              }
            },
            decoration: InputDecoration(
              hintText: "Return Date *",
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
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
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(text: "CLASS"),
          const SizedBox(
            height: 5,
          ),
          DropdownSearch<String>(
            selectedItem: selectedclassType,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
            ),
            items: const [
              "Economy",
              "Business",
            ],
            onChanged: (String? value) {
              setState(() {
                selectedclassType = value;
              });
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Class *',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.black, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(text: "REMARKS"),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.all(4.0),
            child: TextField(
              controller: remarkscontroller,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Enter Remarks",
                hintStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6), // 👈 hint adapts
                ),
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? colorScheme.surfaceContainerHighest // dark mode fill
                    : Colors.white, // 👈 Text color adapts

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.grey, width: 0.5),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.black, width: 0.5),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(text: "ATTACHMENT"),
          const SizedBox(
            height: 10,
          ),
          attachmentPicker(context),
          const SizedBox(height: 30),
          CustomButton(
            onPressed: () {
               if (!validateAirticketForm(context)) return;
              addticket();
            },
            name: "Apply Airticket Request",
            circularvalue: 30,
            fontSize: 16,
          )
        ],
      ),
    );
  }

  void addticket() async {
    var currentdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var json = {
      // "assetrequestapplicationno":
      //     "MASSET-${Prefs.getEmpID('empID').toString()}-${Prefs.getUserName('username').toString()}-$currentdate",
      "date": ApiService.mobilecurrentdate,
      "purposeofTravel": purposeoftravelcontroller.text,
      "fromlocation": fromlocationcontroller.text,
      "tolocation": tolocationcontroller.text,
      "depaturedate": departurecontroller.text,
      "returndate": returndatecontroller.text,
      "prefreenceTime": "",
      "class": selectedclassType ??"",
      "airticketattachment": 'public/${attachcontroller.text.toString()}',
      "remarks": remarkscontroller.text,
      "attachment": attachlist.isEmpty ? "" : attachlist,
      "iscancelled": "N",
      "iscancelledreason": "",
      "iscancelleddate": "",
      "isstatus": "Pending",
      "createdby": Prefs.getNsID('nsid'),
      "createdByEmpName": Prefs.getFullName('Name'),
      "createdDate": ApiService.mobilecurrentdate,
      "toEmpID": Prefs.getNsID('nsid'),
      "toEmpName": Prefs.getFullName('Name'),
      "isSync": 0,
    };
    print(jsonEncode(json));
    setState(() {
      loading = true;
    });
    ApiService.AddAirticket(json).then((response) {
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
          if (!mounted) return;
          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'],
              "Ok",
              onexitpopup,
              AssetsImageWidget.warningimage);
        }
      } else {
        throw Exception(jsonDecode(response.body)['message'].toString());
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

  void onrefreshscreen() {
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }



  //validation
  bool validateAirticketForm(BuildContext context) {
  if (purposeoftravelcontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("Purpose of Travel is required", context);
    return false;
  }

  if (fromlocationcontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("From Location is required", context);
    return false;
  }

  if (tolocationcontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("To Location is required", context);
    return false;
  }

  if (departurecontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("Departure Date is required", context);
    return false;
  }

  if (returndatecontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("Return Date is required", context);
    return false;
  }

  if (selectedclassType == null || selectedclassType!.isEmpty) {
    AppUtils.errorsnackBar("Please select Class", context);
    return false;
  }

  return true; // ✅ all valid
}


}
