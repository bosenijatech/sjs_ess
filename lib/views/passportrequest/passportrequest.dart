import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:intl/intl.dart';

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

class Passportrequest extends StatefulWidget {
  const Passportrequest({super.key});

  @override
  State<Passportrequest> createState() => _PassportrequestState();
}

class _PassportrequestState extends State<Passportrequest> {
 
  String? selectedclassType;
  String? selectedrequestTypeName;
  String? selectedrequestTypeId;
  String? selectedpurposeName;
  String? selectedpurposeId;
  bool isEndDateEnabled = false;

  bool? check1 = false;
  bool loading = false;
   TextEditingController attachcontroller = TextEditingController();
  TextEditingController remarkscontroller = TextEditingController();
  

TextEditingController placecontroller = TextEditingController();
  TextEditingController expirydatecontroller = TextEditingController();
  TextEditingController requieddatecontroller = TextEditingController();

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
    //  onpostleave(); // your existing next step
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
            text: "Passport Request",
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



              AppUtils.buildNormalText(text: "REQUEST TYPE"),
          const SizedBox(
            height: 5,
          ),
      DropdownSearch<String>(
  selectedItem: selectedrequestTypeName,

  items: const [
    "New",
    "Renewal",
  ],

  popupProps: const PopupProps.menu(
    showSearchBox: true,
  ),

  onChanged: (String? value) {
    setState(() {
      selectedrequestTypeName = value;

      if (value == "New") {
        selectedrequestTypeId = "1";
      } else if (value == "Renewal") {
        selectedrequestTypeId = "2";
      } else {
        selectedrequestTypeId = null;
      }
    
    });
  },

  dropdownDecoratorProps: const DropDownDecoratorProps(
    dropdownSearchDecoration: InputDecoration(
      hintText: 'Request Type *',
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
        

              AppUtils.buildNormalText(text: "PURPOSE"),
          const SizedBox(
            height: 5,
          ),
        DropdownSearch<String>(
  selectedItem: selectedpurposeName,

  items: const [
    "Official",
    "Personal",
  ],

  popupProps: const PopupProps.menu(
    showSearchBox: true,
  ),

  onChanged: (String? value) {
    setState(() {
      selectedpurposeName = value;

      if (value == "Official") {
        selectedpurposeId = "1";
      } else if (value == "Personal") {
        selectedpurposeId = "2";
      } else {
        selectedpurposeId = null;
      }
       
    });
  },

  dropdownDecoratorProps: const DropDownDecoratorProps(
    dropdownSearchDecoration: InputDecoration(
      hintText: 'Purpose *',
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
          AppUtils.buildNormalText(
            text: "PASSPORT EXPIRY DATE (IF RENEWAL)",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: expirydatecontroller,
            style: TextStyle(color: colorScheme.onSurface),
             readOnly: true,
            onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // expiry future date only
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      expirydatecontroller.text =
          DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  },
            decoration: InputDecoration(
              hintText: "Passport Expiry Date (if renewal) *",
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
            text: "REQUIRED DATE",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: requieddatecontroller,
            style: TextStyle(color: colorScheme.onSurface),
                      readOnly: true,
            onTap: () async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(), // expiry future date only
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      requieddatecontroller.text =
          DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  },
            decoration: InputDecoration(
              hintText: "Required Date *",
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
              text: "PLACE OF APPLICATION",
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: placecontroller,

              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                 hintText: "Place of Application *",
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
                  borderSide:
                      BorderSide(color: colorScheme.primary, width: 1.2),
                  borderRadius: BorderRadius.circular(8),
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
               if (!validatePassportForm(context)) return;
              onpassportrequest();
            },
            name: "Apply Passport Request",
            circularvalue: 30,
            fontSize: 16,
          )
        ],
      ),
    );
  }

  void onpassportrequest() async {
    var currentdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var json = {
      // "assetrequestapplicationno":
      //     "MASSET-${Prefs.getEmpID('empID').toString()}-${Prefs.getUserName('username').toString()}-$currentdate",
      "date": ApiService.mobilecurrentdate,
      "requestTypeId": selectedrequestTypeId ?? "",
      "requestTypeName":  selectedrequestTypeName ?? "",
      "purposeId": selectedpurposeId ?? "",
      "purposeName": selectedpurposeName ?? "",
      "remarks": remarkscontroller.text,
      "attachment": attachcontroller.text,
      "passportExpiryDate" : expirydatecontroller.text??"",
      "requiredDate" : requieddatecontroller.text??"",
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
    ApiService.AddPassport(json).then((response) {
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
  bool validatePassportForm(BuildContext context) {
  if (selectedrequestTypeId == null || selectedrequestTypeId!.isEmpty) {
    AppUtils.errorsnackBar("Please select Request Type", context);
    return false;
  }

  if (selectedpurposeId == null || selectedpurposeId!.isEmpty) {
    AppUtils.errorsnackBar("Please select Purpose", context);
    return false;
  }

  // Expiry date only required for Renewal
  if (selectedrequestTypeName == "Renewal" &&
      expirydatecontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar(
        "Please select Passport Expiry Date", context);
    return false;
  }

  if (requieddatecontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("Please select Required Date", context);
    return false;
  }

  if (placecontroller.text.trim().isEmpty) {
    AppUtils.errorsnackBar("Please enter Place of Application", context);
    return false;
  }

  // if (attachlist.isEmpty) {
  //   AppUtils.errorsnackBar("Please attach a document", context);
  //   return false;
  // }

  return true; // ✅ All validations passed
}

}
