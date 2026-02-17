import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../models/assetnamemodel.dart';
import '../../models/assettypemodel.dart';
import '../../services/apiservice.dart';
import '../../services/pref.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/custom_button.dart';

class AssetApplyPage extends StatefulWidget {
  const AssetApplyPage({super.key});

  @override
  State<AssetApplyPage> createState() => _AssetApplyPageState();
}

class _AssetApplyPageState extends State<AssetApplyPage> {
  final assetTypekey = GlobalKey<DropdownSearchState<AssetTypeModel>>();
  final assetnamekey = GlobalKey<DropdownSearchState<AssetNameModel>>();

  AssetTypeModel? selectedAssetType;
  AssetNameModel? selectedName;

  bool? check1 = false;
  bool loading = false;
  TextEditingController remarkscontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    remarkscontroller.clear();
    super.dispose();
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
            text: "Asset Request Application",
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
          AppUtils.buildNormalText(text: "ASSET TYPE"),
          const SizedBox(
            height: 5,
          ),
          DropdownSearch<AssetTypeModel>(
            key: assetTypekey,
            selectedItem: selectedAssetType,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              interceptCallBacks: true,
            ),
            asyncItems: (String filter) =>
                ApiService.getAssetTypelist(filter: filter),
            itemAsString: (AssetTypeModel item) => item.name.toString(),
            onChanged: (AssetTypeModel? item) {
              setState(() {
                selectedAssetType = item;
              });
              print("Selected ID: ${selectedAssetType?.id}");
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Asset Type *',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),

                // ✅ RECTANGLE border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.black, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AppUtils.buildNormalText(text: "ASSET NAME"),
          const SizedBox(height: 10),
          DropdownSearch<AssetNameModel>(
            key: assetnamekey,
            selectedItem: selectedName,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              interceptCallBacks: true,
            ),
            asyncItems: (String filter) =>
                ApiService.getAssetNamelist(filter: filter),
            itemAsString: (AssetNameModel item) => item.name.toString(),
            onChanged: (AssetNameModel? item) {
              setState(() {
                selectedName = item;
              });
            },
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Asset Name *',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 14),

                // ✅ RECTANGLE border
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.zero, // <-- No curve
                  borderSide: BorderSide(color: Colors.black, width: 1.2),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          AppUtils.buildNormalText(text: "REMARKS", fontSize: 15),
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
            height: 20,
          ),
          CustomButton(
            onPressed: () {
              onpostletterrequest();
            },
            name: "Apply Asset Request",
            circularvalue: 30,
            fontSize: 16,
          )
        ],
      ),
    );
  }

  void onpostletterrequest() async {
    var currentdate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    var json = {
      "assetrequestapplicationno":
          "MASSET-${Prefs.getEmpID('empID').toString()}-${Prefs.getUserName('username').toString()}-$currentdate",
      "date": ApiService.mobilecurrentdate,
      "assettypecode": selectedAssetType?.id ?? "",
      "assettypename": selectedAssetType?.name ?? "",
      "assetcode": selectedName?.id ?? "",
      "assetname": selectedName?.name ?? "",
      "remarks": remarkscontroller.text,
      "attachment": "",
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
    ApiService.postassetrequest(json).then((response) {
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
}
