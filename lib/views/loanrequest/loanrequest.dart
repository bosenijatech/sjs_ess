// import 'dart:convert';
// import 'dart:io';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// import 'package:intl/intl.dart';

// import '../../models/filemodel.dart';
// import '../../services/apiservice.dart';
// import '../../services/filepickerservice.dart';
// import '../../services/pref.dart';
// import '../../services/uploadservice.dart';
// import '../../utils/app_utils.dart';
// import '../../utils/appcolor.dart';
// import '../widgets/assets_image_widget.dart';
// import '../widgets/custom_button.dart';

// class Loanrequest extends StatefulWidget {
//   const Loanrequest({super.key});

//   @override
//   State<Loanrequest> createState() => _LoanrequestState();
// }

// class _LoanrequestState extends State<Loanrequest> {
//   String? selectedloanTypeName;
//   String? selectedloanTypeId;
//   String? selectedpurpose;
//   bool isEndDateEnabled = false;

//   bool? check1 = false;
//   bool loading = false;
//   TextEditingController attachcontroller = TextEditingController();
//   TextEditingController remarkscontroller = TextEditingController();

//   TextEditingController subjectcontroller = TextEditingController();
//   TextEditingController repaycontroller = TextEditingController();
//   TextEditingController loanamountcontroller = TextEditingController();
//   TextEditingController reasoncontroller = TextEditingController();
//   TextEditingController emicontroller = TextEditingController();

//   TextEditingController requireddatecontroller = TextEditingController();

//   List<AttachModel> attachlist = [];
//   final picker = ImagePicker();
//   File? imagefile;
//   String attachmentID = "";
//   String attachmentURL = "";

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     remarkscontroller.clear();
//     super.dispose();
//   }

//   //attachment

//   Future<void> _captureCameraImage() async {
//     final attach = await CameraImageService.instance.getImageFromCamera();
//     if (attach != null) {
//       setState(() {
//         attachlist.clear();
//         attachlist.add(attach);
//         attachcontroller.text = attach.fileName ?? '';
//       });
//       //upload
//     }
//   }

//   Future<void> _pickFile() async {
//     final attach = await CameraImageService.instance.pickFile();
//     if (attach != null) {
//       setState(() {
//         attachlist.clear();
//         attachlist.add(attach);
//         attachcontroller.text = attach.fileName ?? '';
//       });
//     }
//   }

//   void onUpload() async {
//     setState(() => loading = true);

//     final result =
//         await UploadService.instance.uploadAttachment(context, attachlist);

//     setState(() => loading = false);

//     if (result != null && result['status'] == true) {
//       attachmentID = result['fileId'];
//       attachmentURL = result['url'];
//    onloanrequest();
//     }
//   }

//   Widget attachmentPicker(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return GestureDetector(
//       onTap: () {
//         AppUtils.showBottomCupertinoDialog(context,
//             title: "Choose any one option", btn1function: () async {
//           AppUtils.pop(context);
//           _captureCameraImage();
//         }, btn2function: () {
//           AppUtils.pop(context);
//           _pickFile();
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.only(top: 8),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: theme.brightness == Brightness.dark
//               ? colorScheme.surfaceContainerHighest
//               : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: colorScheme.outline.withOpacity(0.4),
//             width: 1,
//           ),
//           boxShadow: theme.brightness == Brightness.dark
//               ? []
//               : [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: colorScheme.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child:
//                   Icon(Icons.attach_file, color: colorScheme.primary, size: 22),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 attachcontroller.text.isEmpty
//                     ? "Click to attach file (Max 2 MB)"
//                     : attachcontroller.text,
//                 style: TextStyle(
//                   color: attachcontroller.text.isEmpty
//                       ? colorScheme.onSurface.withOpacity(0.6)
//                       : colorScheme.onSurface,
//                   fontWeight: attachcontroller.text.isEmpty
//                       ? FontWeight.normal
//                       : FontWeight.w500,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//             if (attachcontroller.text.isNotEmpty)
//               IconButton(
//                 icon: Icon(Icons.close, color: colorScheme.error, size: 20),
//                 onPressed: () {
//                   setState(() {
//                     attachcontroller.clear();
//                     attachlist.clear();
//                   });
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         iconTheme: IconThemeData(
//           color:
//               Theme.of(context).colorScheme.onSurface, // adapts to dark/light
//         ),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(CupertinoIcons.back,
//               color: Theme.of(context).colorScheme.onSurface),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: AppUtils.buildNormalText(
//             text: "Loan Request",
//             color:
//                 Theme.of(context).colorScheme.onSurface, // 👈 auto theme color
//             fontWeight: FontWeight.bold,
//             fontSize: 20),
//         centerTitle: false,
//       ),
//       body: !loading
//           ? SingleChildScrollView(
//               child: Column(
//                 children: [getdetails()],
//               ),
//             )
//           : const Center(
//               child: CupertinoActivityIndicator(
//                   radius: 30.0, color: Appcolor.twitterBlue),
//             ),
//     );
//   }

//   Widget getdetails() {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;
//     return Container(
//       padding: const EdgeInsets.all(10),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AppUtils.buildNormalText(text: "LOAN TYPE"),
//           const SizedBox(
//             height: 5,
//           ),
//           DropdownSearch<String>(
//             selectedItem: selectedloanTypeName,
//             items: const [
//               "Personal",
//               "Emergency",
//               "Education",
//               "Medical",
//             ],
//             popupProps: const PopupProps.menu(
//               showSearchBox: true,
//             ),
//             onChanged: (String? value) {
//               setState(() {
//                 selectedloanTypeName = value;

//                 if (value == "Personal") {
//                   selectedloanTypeId = "1";
//                 } else if (value == "Emergency") {
//                   selectedloanTypeId = "2";
//                 } else if (value == "Education") {
//                   selectedloanTypeId = "3";
//                 } else if (value == "Medical") {
//                   selectedloanTypeId = "4";
//                 } else {
//                   selectedloanTypeId = null;
//                 }
//               });
//             },
//             dropdownDecoratorProps: const DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 hintText: 'Loan Type *',
//                 contentPadding:
//                     EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.zero,
//                   borderSide: BorderSide(color: Colors.grey, width: 1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.zero,
//                   borderSide: BorderSide(color: Colors.black, width: 1.2),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(
//             text: "LOAN AMOUNT",
//             color: colorScheme.onSurface.withOpacity(0.8),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: loanamountcontroller,
//             style: TextStyle(color: colorScheme.onSurface),
//             decoration: InputDecoration(
//               hintText: "Loan Amount *",
//               hintStyle: TextStyle(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.6), // 👈 hint adapts
//               ),
//               filled: true,
//               fillColor: theme.brightness == Brightness.dark
//                   ? colorScheme.surfaceContainerHighest
//                   : Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: colorScheme.outline.withOpacity(0.4)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(
//             text: "REPAYMENT PERIOD (MONTHS)",
//             color: colorScheme.onSurface.withOpacity(0.8),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: repaycontroller,
//             keyboardType: TextInputType.number,
//             style: TextStyle(color: colorScheme.onSurface),
//             decoration: InputDecoration(
//               hintText: "Repayment Period (Months) *",
//               hintStyle: TextStyle(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.6), // 👈 hint adapts
//               ),
//               filled: true,
//               fillColor: theme.brightness == Brightness.dark
//                   ? colorScheme.surfaceContainerHighest
//                   : Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: colorScheme.outline.withOpacity(0.4)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(
//             text: "EMI AMOUNT",
//             color: colorScheme.onSurface.withOpacity(0.8),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: emicontroller,
//             keyboardType: TextInputType.number,
//             style: TextStyle(color: colorScheme.onSurface),
//             decoration: InputDecoration(
//               hintText: "EMI Amount *",
//               hintStyle: TextStyle(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.6), // 👈 hint adapts
//               ),
//               filled: true,
//               fillColor: theme.brightness == Brightness.dark
//                   ? colorScheme.surfaceContainerHighest
//                   : Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: colorScheme.outline.withOpacity(0.4)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(text: "REASON FOR LOAN"),
//           const SizedBox(
//             height: 10,
//           ),
//           Container(
//             padding: const EdgeInsets.all(4.0),
//             child: TextField(
//               controller: reasoncontroller,
//               keyboardType: TextInputType.multiline,
//               maxLines: 4,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//               decoration: InputDecoration(
//                 hintText: "Reason for Loan",
//                 hintStyle: TextStyle(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .onSurface
//                       .withOpacity(0.6), // 👈 hint adapts
//                 ),
//                 filled: true,
//                 fillColor: theme.brightness == Brightness.dark
//                     ? colorScheme.surfaceContainerHighest // dark mode fill
//                     : Colors.white, // 👈 Text color adapts

//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.zero, // <-- No curve
//                   borderSide: BorderSide(color: Colors.grey, width: 0.5),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.zero, // <-- No curve
//                   borderSide: BorderSide(color: Colors.black, width: 0.5),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(
//             text: "REQUIRED DATE",
//             color: colorScheme.onSurface.withOpacity(0.8),
//           ),
//           const SizedBox(height: 5),
//           TextFormField(
//             controller: requireddatecontroller,
//             style: TextStyle(color: colorScheme.onSurface),
//             readOnly: true,
//             onTap: () async {
//               DateTime? pickedDate = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now(),
//                 firstDate: DateTime.now(), // expiry future date only
//                 lastDate: DateTime(2100),
//               );

//               if (pickedDate != null) {
//                 requireddatecontroller.text =
//                     DateFormat('dd-MM-yyyy').format(pickedDate);
//               }
//             },
//             decoration: InputDecoration(
//               hintText: "Required Date *",
//               hintStyle: TextStyle(
//                 color: Theme.of(context)
//                     .colorScheme
//                     .onSurface
//                     .withOpacity(0.6), // 👈 hint adapts
//               ),
//               filled: true,
//               fillColor: theme.brightness == Brightness.dark
//                   ? colorScheme.surfaceContainerHighest
//                   : Colors.white,
//               enabledBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: colorScheme.outline.withOpacity(0.4)),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(text: "REMARKS"),
//           const SizedBox(
//             height: 10,
//           ),
//           Container(
//             padding: const EdgeInsets.all(4.0),
//             child: TextField(
//               controller: remarkscontroller,
//               keyboardType: TextInputType.multiline,
//               maxLines: 4,
//               style: TextStyle(
//                 color: Theme.of(context).colorScheme.onSurface,
//               ),
//               decoration: InputDecoration(
//                 hintText: "Enter Remarks",
//                 hintStyle: TextStyle(
//                   color: Theme.of(context)
//                       .colorScheme
//                       .onSurface
//                       .withOpacity(0.6), // 👈 hint adapts
//                 ),
//                 filled: true,
//                 fillColor: theme.brightness == Brightness.dark
//                     ? colorScheme.surfaceContainerHighest // dark mode fill
//                     : Colors.white, // 👈 Text color adapts

//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 enabledBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.zero, // <-- No curve
//                   borderSide: BorderSide(color: Colors.grey, width: 0.5),
//                 ),
//                 focusedBorder: const OutlineInputBorder(
//                   borderRadius: BorderRadius.zero, // <-- No curve
//                   borderSide: BorderSide(color: Colors.black, width: 0.5),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           AppUtils.buildNormalText(text: "ATTACHMENT"),
//           const SizedBox(
//             height: 10,
//           ),
//           attachmentPicker(context),
//           const SizedBox(height: 30),
//           CustomButton(
            
//             onPressed: () {
//                 if (!validateLoanForm(context)) return;
//               onloanrequest();
//             },
//             name: "Apply Loan Request",
//             circularvalue: 30,
//             fontSize: 16,
//           )
//         ],
//       ),
//     );
//   }

//   void onloanrequest() async {
//     var currentdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
//     List<Map<String, dynamic>> attachmentJson =
//       attachlist.map((e) => e.toJson()).toList();
//     var json = {
//       // "assetrequestapplicationno":
//       //     "MASSET-${Prefs.getEmpID('empID').toString()}-${Prefs.getUserName('username').toString()}-$currentdate",
//       "date": ApiService.mobilecurrentdate,
//       "assettypecode": selectedloanTypeId ?? "",
//       "assettypename": selectedloanTypeName ?? "",
//       "loanAmount": loanamountcontroller.text ?? "",
//       "repaymentMonth": repaycontroller.text ?? "",
//       "emiAmount": emicontroller.text?? "",
//       "reasonforLoan": reasoncontroller.text ?? "",
//       "requiredDate": requireddatecontroller.text ?? "",
//       "remarks": remarkscontroller.text ?? "",
//       "attachment": attachmentJson,
//       "iscancelled": "N",
//       "iscancelledreason": "",
//       "iscancelleddate": "",
//       "isstatus": "Pending",
//       "createdby": Prefs.getNsID('nsid'),
//       "createdByEmpName": Prefs.getFullName('Name'),
//       "createdDate": ApiService.mobilecurrentdate,
//       "toEmpID": Prefs.getNsID('nsid'),
//       "toEmpName": Prefs.getFullName('Name'),
//       "isSync": 0,
//     };
//     print(jsonEncode(json));
//     setState(() {
//       loading = true;
//     });
//     ApiService.AddLoan(json).then((response) {
//       setState(() {
//         loading = false;
//       });
//       if (response.statusCode == 200) {
//         if (jsonDecode(response.body)['status'].toString() == "true") {
//           AppUtils.showSingleDialogPopup(
//               context,
//               jsonDecode(response.body)['message'],
//               "Ok",
//               onrefreshscreen,
//               AssetsImageWidget.successimage);

//           setState(() {});
//         } else {
//           if (!mounted) return;
//           AppUtils.showSingleDialogPopup(
//               context,
//               jsonDecode(response.body)['message'],
//               "Ok",
//               onexitpopup,
//               AssetsImageWidget.warningimage);
//         }
//       } else {
//         throw Exception(jsonDecode(response.body)['message'].toString());
//       }
//     }).catchError((e) {
//       setState(() {
//         loading = false;
//       });
//       AppUtils.showSingleDialogPopup(context, e.toString(), "Ok", onexitpopup,
//           AssetsImageWidget.errorimage);
//     });
//   }

//   void onexitpopup() {
//     Navigator.of(context).pop();
//   }

//   void onrefreshscreen() {
//     Navigator.of(context).pop();
//     Navigator.of(context).pop();
//   }



//   //validation
// bool validateLoanForm(BuildContext context) {
//   if (selectedloanTypeId == null || selectedloanTypeId!.isEmpty) {
//     AppUtils.errorsnackBar("Please select loan type", context);
//     return false;
//   }

//   if (loanamountcontroller.text.trim().isEmpty) {
//     AppUtils.errorsnackBar("Please enter loan amount", context);
//     return false;
//   }

//   if (repaycontroller.text.trim().isEmpty) {
//     AppUtils.errorsnackBar("Please enter repayment period", context);
//     return false;
//   }

//   if (emicontroller.text.trim().isEmpty) {
//     AppUtils.errorsnackBar("Please enter EMI amount", context);
//     return false;
//   }

//   if (reasoncontroller.text.trim().isEmpty) {
//     AppUtils.errorsnackBar("Please enter reason for loan", context);
//     return false;
//   }

//   if (requireddatecontroller.text.trim().isEmpty) {
//     AppUtils.errorsnackBar("Please select required date", context);
//     return false;
//   }

//   return true; // ✅ all valid
// }




// }



import 'dart:convert';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/filemodel.dart';
import '../../services/apiservice.dart';
import '../../services/filepickerservice.dart';
import '../../services/pref.dart';
import '../../services/uploadservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/custom_button.dart';

class Loanrequest extends StatefulWidget {
  const Loanrequest({super.key});

  @override
  State<Loanrequest> createState() => _LoanrequestState();
}

class _LoanrequestState extends State<Loanrequest> {
  String? selectedloanTypeName;
  String? selectedloanTypeId;

  bool loading = false;

  TextEditingController attachcontroller = TextEditingController();
  TextEditingController remarkscontroller = TextEditingController();
  TextEditingController loanamountcontroller = TextEditingController();
  TextEditingController repaycontroller = TextEditingController();
  TextEditingController emicontroller = TextEditingController();
  TextEditingController reasoncontroller = TextEditingController();
  TextEditingController requireddatecontroller = TextEditingController();

  List<AttachModel> attachlist = [];

  final picker = ImagePicker();
  File? imagefile;

  String attachmentID = "";
  String attachmentURL = "";

  @override
  void dispose() {
    remarkscontroller.clear();
    super.dispose();
  }

  // ------------------- Attachment -------------------
  Future<void> _captureCameraImage() async {
    final attach = await CameraImageService.instance.getImageFromCamera();
    if (attach != null) {
      setState(() {
        attachlist.clear();
        attachlist.add(attach);
        attachcontroller.text = attach.fileName ?? '';
      });
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

  Future<void> onUpload() async {
    setState(() => loading = true);
    final result = await UploadService.instance.uploadAttachment(context, attachlist);
    setState(() => loading = false);

    if (result != null && result['status'] == true) {
      attachmentID = result['fileId'];
      attachmentURL = result['url'];
      await onloanrequest(); // call loan request after successful upload
    }
  }

  


  Widget attachmentPicker(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        AppUtils.showBottomCupertinoDialog(
          context,
          title: "Choose any one option",
          btn1function: () async {
            AppUtils.pop(context);
            _captureCameraImage();
          },
          btn2function: () {
            AppUtils.pop(context);
            _pickFile();
          },
        );
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
              child: Icon(Icons.attach_file, color: colorScheme.primary, size: 22),
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

  // ------------------- Build UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: AppUtils.buildNormalText(
          text: "Loan Request",
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      body: loading
          ? const Center(
              child: CupertinoActivityIndicator(radius: 30.0, color: Appcolor.twitterBlue),
            )
          : SingleChildScrollView(child: getDetails()),
    );
  }

  Widget getDetails() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Loan Type
          AppUtils.buildNormalText(text: "LOAN TYPE"),
          const SizedBox(height: 5),
          DropdownSearch<String>(
            selectedItem: selectedloanTypeName,
            items: const ["Personal", "Emergency", "Education", "Medical"],
            popupProps: const PopupProps.menu(showSearchBox: true),
            onChanged: (value) {
              setState(() {
                selectedloanTypeName = value;
                if (value == "Personal") selectedloanTypeId = "1";
                else if (value == "Emergency") selectedloanTypeId = "2";
                else if (value == "Education") selectedloanTypeId = "3";
                else if (value == "Medical") selectedloanTypeId = "4";
                else selectedloanTypeId = null;
              });
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Loan Type *',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
          const SizedBox(height: 10),

          // Loan Amount
          AppUtils.buildNormalText(
            text: "LOAN AMOUNT",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: loanamountcontroller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Loan Amount *",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Repayment Period
          AppUtils.buildNormalText(
            text: "REPAYMENT PERIOD (MONTHS)",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: repaycontroller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Repayment Period (Months) *",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // EMI Amount
          AppUtils.buildNormalText(
            text: "EMI AMOUNT",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: emicontroller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "EMI Amount *",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Reason
          AppUtils.buildNormalText(text: "REASON FOR LOAN"),
          const SizedBox(height: 10),
          TextField(
            controller: reasoncontroller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Reason for Loan",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Required Date
          AppUtils.buildNormalText(
            text: "REQUIRED DATE",
            color: colorScheme.onSurface.withOpacity(0.8),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: requireddatecontroller,
            readOnly: true,
            style: TextStyle(color: colorScheme.onSurface),
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                requireddatecontroller.text =
                    DateFormat('dd-MM-yyyy').format(pickedDate);
              }
            },
            decoration: InputDecoration(
              hintText: "Required Date *",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: colorScheme.primary, width: 1.2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Remarks
          AppUtils.buildNormalText(text: "REMARKS"),
          const SizedBox(height: 10),
          TextField(
            controller: remarkscontroller,
            keyboardType: TextInputType.multiline,
            maxLines: 4,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: "Enter Remarks",
              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
              filled: true,
              fillColor: theme.brightness == Brightness.dark
                  ? colorScheme.surfaceContainerHighest
                  : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.grey, width: 0.5),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Colors.black, width: 0.5),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Attachment
          AppUtils.buildNormalText(text: "ATTACHMENT"),
          const SizedBox(height: 10),
          attachmentPicker(context),
          const SizedBox(height: 30),

          // Submit Button
          CustomButton(
            onPressed: () async {
              if (!validateLoanForm(context)) return;

              if (attachlist.isNotEmpty) {
                await onUpload(); // upload then submit
              } else {
                await onloanrequest(); // submit directly
              }
            },
            name: "Apply Loan Request",
            circularvalue: 30,
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  // ------------------- Loan Request API -------------------
  Future<void> onloanrequest() async {
    try {
      setState(() => loading = true);

      var json = {
        "date": ApiService.mobilecurrentdate,
        "loantypeId": selectedloanTypeId ?? "",
        "loanType": selectedloanTypeName ?? "",
        "loanAmount": loanamountcontroller.text.trim(),
        "repaymentMonth": repaycontroller.text.trim(),
        "emiAmount": emicontroller.text.trim(),
        "reasonforLoan": reasoncontroller.text.trim(),
        "requiredDate": requireddatecontroller.text.trim(),
        "remarks": remarkscontroller.text.trim(),
        "attachment": '',
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

      final response = await ApiService.AddLoan(json);
      setState(() => loading = false);

      if (response.statusCode == 200) {
        final resBody = jsonDecode(response.body);
        if (resBody['status'].toString() == "true") {
          AppUtils.showSingleDialogPopup(context, resBody['message'], "Ok",
              onrefreshscreen, AssetsImageWidget.successimage);
        } else {
          AppUtils.showSingleDialogPopup(context, resBody['message'], "Ok",
              onexitpopup, AssetsImageWidget.warningimage);
        }
      } else {
        throw Exception(jsonDecode(response.body)['message'].toString());
      }
    } catch (e) {
      setState(() => loading = false);
      AppUtils.showSingleDialogPopup(
          context, e.toString(), "Ok", onexitpopup, AssetsImageWidget.errorimage);
    }
  }

  void onexitpopup() => Navigator.of(context).pop();
  void onrefreshscreen() {
    clearForm();
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  void clearForm() {
    selectedloanTypeName = null;
    selectedloanTypeId = null;
    loanamountcontroller.clear();
    repaycontroller.clear();
    emicontroller.clear();
    reasoncontroller.clear();
    requireddatecontroller.clear();
    remarkscontroller.clear();
    attachcontroller.clear();
    attachlist.clear();
  }

  // ------------------- Validation -------------------
  bool validateLoanForm(BuildContext context) {
    if (selectedloanTypeId == null || selectedloanTypeId!.isEmpty) {
      AppUtils.errorsnackBar("Please select loan type", context);
      return false;
    }
    if (loanamountcontroller.text.trim().isEmpty ||
        double.tryParse(loanamountcontroller.text.trim()) == null) {
      AppUtils.errorsnackBar("Please enter valid loan amount", context);
      return false;
    }
    if (repaycontroller.text.trim().isEmpty ||
        int.tryParse(repaycontroller.text.trim()) == null) {
      AppUtils.errorsnackBar("Please enter valid repayment period", context);
      return false;
    }
    if (emicontroller.text.trim().isEmpty ||
        double.tryParse(emicontroller.text.trim()) == null) {
      AppUtils.errorsnackBar("Please enter valid EMI amount", context);
      return false;
    }
    if (reasoncontroller.text.trim().isEmpty) {
      AppUtils.errorsnackBar("Please enter reason for loan", context);
      return false;
    }
    if (requireddatecontroller.text.trim().isEmpty) {
      AppUtils.errorsnackBar("Please select required date", context);
      return false;
    }
    return true;
  }
}
