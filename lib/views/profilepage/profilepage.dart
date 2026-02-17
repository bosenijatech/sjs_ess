import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';

import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/empinfomodel.dart';
import '../../models/filemodel.dart';
import '../../services/apiservice.dart';
import '../../services/filepickerservice.dart';
import '../../services/pref.dart';
import '../../services/uploadservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../../utils/constants.dart';
import '../../utils/custom_indicatoronly.dart';
import '../../utils/sharedprefconstants.dart';
import '../payslip/viewallfiles.dart';
import '../widgets/assets_image_widget.dart';
import 'StickyTabBarDelegate.dart';
import 'edit_education.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _selectedColor = const Color(0xFF1E3A8A);

  final _unselectedColor = const Color(0xff5f6368);
  final _tabs = [
    const Tab(text: 'Personal'),
    const Tab(text: 'Qualification'),
    const Tab(text: 'Documents'),
    const Tab(text: 'Other Details'),
  ];
  String attachmentID = "";
  String attachmentURL = "";
  bool loading = false;
  EmpInfoModel empinfomodel = EmpInfoModel();

  List<String> files = [];
  TextEditingController attachcontroller = TextEditingController();

  final picker = ImagePicker();
  File? imagefile;
  List<File> filelist = [];
  List<PlatformFile>? _paths;
  List<AttachModel> attachlist = [];
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    getdata();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    attachcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor, // ✅ theme-based
        centerTitle: true,
        title: Text(
          "Profile Page",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface, // auto-contrast
              ),
        ),
        iconTheme: IconThemeData(
          color:
              Theme.of(context).colorScheme.onSurface, // for back/leading icons
        ),
      ),
      body: !loading
          ? DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    _headerSection(),
                    _tabSection(context),
                  ];
                },
                body: TabBarView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          primarydetails(context),
                          contactdetails(),
                          addressdetails(),
                          addressdetails2(),
                          dependents(),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [qualificationdetails()],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [documentdetails()],
                      ),
                    ),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          dependentIDdetails(),
                          const SizedBox(
                            height: 10,
                          ),
                          skillsdetails(),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const CustomIndicator(),
    );
  }

  Widget _headerSection() {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          SizedBox(
            height: 210,
            child: Center(
              child: ListView(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildProfileCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          _buildAvatar(context),
          const SizedBox(height: 14),
          _buildFullName(context),
          const SizedBox(height: 5),
          _buildWorkRegion(context),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageUrl = empinfomodel.message?.imageurl ?? "";

    return InkWell(
      onTap: () async {
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
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // ✅ Allow overflow for the plus icon
        children: [
          // Profile image with subtle shadow
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.6)
                      : Colors.grey.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withOpacity(0.2),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error, color: Colors.redAccent),
                      ),
                    )
                  : Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.surface,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/avataricon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
          ),

          // ✅ Plus icon overlay (no longer clipped)
          Positioned(
            bottom: -2,
            right: -2,
            child: _buildPlusIcon(context),
          ),
        ],
      ),
    );
  }

  /// 🎨 Reusable plus icon widget
  Widget _buildPlusIcon(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(4),
      child: Image.asset(
        'assets/icons/plus.png',
        width: 20,
        height: 20,
      ),
    );
  }

  /// 🧑 Full Name
  Widget _buildFullName(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = empinfomodel.message?.firstName ?? "";
    final middleName = empinfomodel.message?.middleName ?? "";
    final lastName = empinfomodel.message?.lastName ?? "";

    return Text(
      "$firstName $middleName $lastName".trim(),
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 🌍 Work Region
  Widget _buildWorkRegion(BuildContext context) {
    final theme = Theme.of(context);
    final workRegion = empinfomodel.message?.workRegion ?? "NA";

    return Text(
      workRegion,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.7),
        fontSize: 13,
      ),
      textAlign: TextAlign.center,
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
      onUpload();
    }
  }

  Future<void> _pickFile() async {
    final attach = await CameraImageService.instance.pickFile(image: true);
    if (attach != null) {
      setState(() {
        attachlist.clear();
        attachlist.add(attach);
        attachcontroller.text = attach.fileName ?? '';
      });
      onUpload();
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
      updateuserimage(attachmentID, attachmentURL);
    }
  }

  void updateuserimage(attachid, imageurl) {
    var json = {
      "type": "UserImg",
      "_id": Prefs.getNsID('nsid'),
      "nsId": Prefs.getNsID('nsid'),
      "firstName": Prefs.getFirstName(
        SharefprefConstants.shareFirstName,
      ),
      "middleName": Prefs.getMiddleName(
        SharefprefConstants.shareMiddleName,
      ),
      "lastName": Prefs.getLastName(
        SharefprefConstants.sharedLastName,
      ),
      "imagename": attachid, //imagename,
      "imageurl": imageurl //camfilepath //camfilepath
    };

    setState(() {
      loading = true;
    });
    ApiService.updatemaster(json).then((response) {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          Prefs.setImageURL(SharefprefConstants.sharedImgUrl, imageurl);

          AppUtils.showSingleDialogPopup(
              context,
              jsonDecode(response.body)['message'],
              "ok",
              onrefresh,
              AssetsImageWidget.successimage);
        } else {
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

  Widget _tabSection(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        tabBar: TabBar(
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 3,
            ),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 14,
          ),
          tabs: _tabs,
        ),

        // 👇 adaptive background color
        backgroundColor: theme.brightness == Brightness.dark
            ? theme.colorScheme.surface
            : Colors.white,
      ),
    );
  }

  Widget primarydetails(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.6);
    final emp = empinfomodel.message;
    return Card(
      elevation: 3,
      color: theme.cardColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppUtils.buildNormalText(
                  text: "Primary Details",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
                AppUtils.buildNormalText(
                    text: "", fontSize: 16, color: Appcolor.twitterBlue),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.buildNormalText(
                          text: "FIRST NAME", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null
                              ? empinfomodel.message!.firstName.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "LAST NAME", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null
                              ? empinfomodel.message!.lastName.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "TITLE", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null
                              ? empinfomodel.message!.title.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "GENDER", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.gender.toString() !=
                                      "null"
                              ? empinfomodel.message!.gender.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "MARITIAL STATUS",
                          fontSize: 12,
                          color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.maritalStatus
                                          .toString() !=
                                      "null"
                              ? empinfomodel.message!.maritalStatus.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "EMAIL ID", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.mobileemail
                                          .toString() !=
                                      "null"
                              ? empinfomodel.message!.mobileemail.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 20,
                      ),
                      AppUtils.buildNormalText(
                          text: "DEPT", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.department.toString() !=
                                      "null"
                              ? empinfomodel.message!.department.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "BANK NAME", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.bankName.toString() !=
                                      "null"
                              ? empinfomodel.message!.bankName.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "BAND", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.band.toString() !=
                                      "null"
                              ? empinfomodel.message!.band.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "SUB BAND", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.subBand.toString() !=
                                      "null"
                              ? empinfomodel.message!.subBand.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "MOBILE NO", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.mobileNo.toString() !=
                                      "null"
                              ? empinfomodel.message!.mobileNo.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 30,
                      ),
                      AppUtils.buildNormalText(
                          text: "JOB STATUS", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.jobStatus.toString() !=
                                      "null"
                              ? empinfomodel.message!.jobStatus.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                      AppUtils.buildNormalText(
                          text: "ACCOUNT NO", fontSize: 12, color: labelColor),
                      const SizedBox(height: 5),
                      AppUtils.buildNormalText(
                          text: empinfomodel.message != null &&
                                  empinfomodel.message!.bankAccountNo
                                          .toString() !=
                                      "null"
                              ? empinfomodel.message!.bankAccountNo.toString()
                              : "-",
                          fontSize: 14,
                          color: textColor),
                      const SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppUtils.buildNormalText(
                        text: "MIDDLE NAME", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.middleName.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "EMP CODE", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.employeeCode.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "DISPLAY NAME", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.firstName.toString() !=
                                    "null"
                            ? empinfomodel.message!.firstName.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "DATE OF BIRTH", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.dateOfBirth.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "D.O.J", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.hireDate.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "SUBSIDIARY", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.subsidiary.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "CATEGORY", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.employeeCategory.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "RELIGION", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null
                            ? empinfomodel.message!.religion.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 30,
                    ),
                    AppUtils.buildNormalText(
                        text: "WORKING REGION",
                        fontSize: 12,
                        color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.workRegion.toString() !=
                                    "null"
                            ? empinfomodel.message!.workRegion.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "MARITIAL STATUS",
                        fontSize: 12,
                        color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.maritalStatus
                                        .toString() !=
                                    "null"
                            ? empinfomodel.message!.maritalStatus.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "BANK NAME", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.bankName.toString() !=
                                    "null"
                            ? empinfomodel.message!.bankName.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "ROUTING NO", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.bankRoutingNo
                                        .toString() !=
                                    "null"
                            ? empinfomodel.message!.bankRoutingNo.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                    AppUtils.buildNormalText(
                        text: "ROLE", fontSize: 12, color: labelColor),
                    const SizedBox(height: 5),
                    AppUtils.buildNormalText(
                        text: empinfomodel.message != null &&
                                empinfomodel.message!.role.toString() != "null"
                            ? empinfomodel.message!.role.toString()
                            : "-",
                        fontSize: 14,
                        color: textColor),
                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget contactdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return empinfomodel.message != null &&
            empinfomodel.message!.emergencyContact!.isNotEmpty
        ? Card(
            color: cardColor,
            elevation: 3,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppUtils.buildNormalText(
                        text: "Emergency Contact Details",
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      AppUtils.buildNormalText(
                          text: "", fontSize: 16, color: Appcolor.twitterBlue),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.buildNormalText(
                                text: "Contact Name",
                                fontSize: 12,
                                color: labelColor),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                                text: empinfomodel.message != null
                                    ? empinfomodel.message!.emergencyContact!
                                        .first.emergencyContactName
                                        .toString()
                                    : "-",
                                fontSize: 14,
                                color: textColor,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(
                              height: 15,
                            ),
                            AppUtils.buildNormalText(
                                text: "Contact Address",
                                fontSize: 12,
                                maxLines: 2,
                                color: labelColor),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                                text: empinfomodel.message != null &&
                                        empinfomodel.message!.emergencyContact!
                                            .isNotEmpty
                                    ? empinfomodel.message!.emergencyContact!
                                        .first.emergencyContactAddress
                                    : "-".toString(),
                                fontSize: 14,
                                color: textColor),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppUtils.buildNormalText(
                                text: "Contact Relation",
                                fontSize: 12,
                                color: labelColor),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                                text: empinfomodel.message != null
                                    ? empinfomodel.message!.emergencyContact!
                                        .first.emergencyContactRelationship
                                        .toString()
                                    : "-",
                                fontSize: 14,
                                color: textColor,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(
                              height: 15,
                            ),
                            AppUtils.buildNormalText(
                                text: "Contact Phone",
                                fontSize: 12,
                                maxLines: 2,
                                color: labelColor),
                            const SizedBox(height: 5),
                            AppUtils.buildNormalText(
                                text: empinfomodel.message != null &&
                                        empinfomodel.message!.emergencyContact!
                                            .isNotEmpty
                                    ? empinfomodel.message!.emergencyContact!
                                        .first.emergencyContactNo
                                    : "-".toString(),
                                fontSize: 14,
                                color: textColor),
                            const SizedBox(
                              height: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )
        : Container();
  }

  Widget addressdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return empinfomodel.message != null &&
            empinfomodel.message!.contacts!.isNotEmpty
        ? Card(
            color: cardColor,
            elevation: 3,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: empinfomodel.message!.contacts![0].defaultBilling
                                  .toString() ==
                              "true"
                          ? "Primary Details"
                          : "Contact Details",
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: "ADDRESS", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].address
                              .toString()
                          : "-",
                      fontSize: 14,
                      maxLines: null,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ADDRESS 1 ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].address1
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ADDRESS 2 ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].address2
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "COUNTRY", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].country
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "STATE  ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].state.toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "CITY", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].city.toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ZIPCODE", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![0].zipCode
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget addressdetails2() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return empinfomodel.message != null &&
            empinfomodel.message!.contacts!.isNotEmpty &&
            empinfomodel.message!.contacts!.length > 1
        ? Card(
            color: cardColor,
            elevation: 3,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: "Address Details",
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: "ADDRESS", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].address
                              .toString()
                          : "-",
                      fontSize: 14,
                      maxLines: null,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ADDRESS 1 ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].address1
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ADDRESS 2 ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].address2
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "COUNTRY", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].country
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "STATE  ", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].state.toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "CITY", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].city.toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                  AppUtils.buildNormalText(
                      text: "ZIPCODE", fontSize: 12, color: labelColor),
                  const SizedBox(height: 5),
                  AppUtils.buildNormalText(
                      text: empinfomodel.message != null
                          ? empinfomodel.message!.contacts![1].zipCode
                              .toString()
                          : "-",
                      fontSize: 14,
                      color: textColor),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget qualificationdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppUtils.buildNormalText(
                    text: "Qualification Details",
                    fontSize: 18,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditEducation(
                              model: empinfomodel,
                              iseditable: false,
                              position: 0)),
                    ).then((_) => getdata());
                  },
                  child: AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ),
              ],
            ),
          ),
          empinfomodel.message != null &&
                  empinfomodel.message!.qualification!.isNotEmpty
              ? ListView.builder(
                  itemCount: empinfomodel.message!.qualification!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.buildNormalText(
                                        text: "ID",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                            .qualification![index].internalid
                                            .toString(),
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "COLLEGE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                            .qualification![index].college
                                            .toString(),
                                        fontSize: 14,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "PERCENTAGE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                            .qualification![index].percentage
                                            .toString(),
                                        fontSize: 14,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "LEVEL OF EDUCATION",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                    .message!
                                                    .qualification![index]
                                                    .levelofeducation
                                                    .toString() ==
                                                "null"
                                            ? ""
                                            : empinfomodel
                                                .message!
                                                .qualification![index]
                                                .levelofeducation
                                                .toString(),
                                        fontSize: 14,
                                        color: textColor),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "EDUCATION",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel.message!
                                              .qualification![index].education
                                              .toString(),
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "PASSING YEAR",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel.message!
                                              .qualification![index].passingYear
                                              .toString(),
                                          fontSize: 12,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "ATTACHMENT",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      (empinfomodel
                                                  .message!
                                                  .qualification![index]
                                                  .certificate
                                                  .toString()
                                                  .isEmpty ||
                                              empinfomodel
                                                      .message!
                                                      .qualification![index]
                                                      .certificate
                                                      .toString() ==
                                                  "null")
                                          ? Container()
                                          : RichText(
                                              text: TextSpan(
                                                text: "",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface, // 👈 dynamic text color
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "View Attachment",
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary, // 👈 theme primary color
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            final certificateUrl =
                                                                empinfomodel
                                                                    .message!
                                                                    .qualification![
                                                                        index]
                                                                    .certificate!;

                                                            if (certificateUrl
                                                                .isEmpty)
                                                              return;

                                                            final mime =
                                                                await AppConstants
                                                                    .getMimeType(
                                                                        certificateUrl);
                                                            final ext = AppConstants
                                                                .getExtensionFromMime(
                                                                    mime);

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    ViewFiles(
                                                                  fileUrl:
                                                                      certificateUrl,
                                                                  fileName:
                                                                      'file.$ext',
                                                                  mimeType:
                                                                      mime,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                  ),
                                                ],
                                              ),
                                            ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  )),
                              // Expanded(
                              //     flex: 1,
                              //     child: InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) => EditEducation(
                              //                   model: empinfomodel,
                              //                   iseditable: true,
                              //                   position: index)),
                              //         ).then((_) => getdata());
                              //       },
                              //       child: const Icon(
                              //         CupertinoIcons.pencil_circle,
                              //         size: 24,
                              //         color: Appcolor.grey,
                              //       ),
                              //     ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text('No Data Found!'),
                ),
        ],
      ),
    );
  }

  Widget documentdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => EditDocuments(
              //           model: empinfomodel, iseditable: false, position: 0)),
              // ).then((_) => getdata());
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: "Document Details",
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ],
              ),
            ),
          ),
          empinfomodel.message != null &&
                  empinfomodel.message!.documents!.isNotEmpty
              ? ListView.builder(
                  itemCount: empinfomodel.message!.documents!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.buildNormalText(
                                        text: "ID NUMBER",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                                .documents![index].idNo ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "COMPANY NAME",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .documents![index]
                                                .companyName ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "ISSUE DATE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                                .documents![index].issueDate ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "DESIGNATION",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .documents![index]
                                                .designation ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "REMAINDER",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                                .documents![index].remainder ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "ATTACHMENTS",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    (empinfomodel.message!.documents![index]
                                                .attachment
                                                .toString()
                                                .isEmpty ||
                                            empinfomodel
                                                    .message!
                                                    .documents![index]
                                                    .attachment
                                                    .toString() ==
                                                "null")
                                        ? Container()
                                        : RichText(
                                            text: TextSpan(
                                              text: "",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface, // 👈 dynamic text color
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "View Attachment",
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary, // 👈 theme primary color
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () async {
                                                          final certificateUrl =
                                                              empinfomodel
                                                                  .message!
                                                                  .documents![
                                                                      index]
                                                                  .attachment!;

                                                          if (certificateUrl
                                                              .isEmpty) return;

                                                          final mime =
                                                              await AppConstants
                                                                  .getMimeType(
                                                                      certificateUrl);
                                                          final ext = AppConstants
                                                              .getExtensionFromMime(
                                                                  mime);

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ViewFiles(
                                                                fileUrl:
                                                                    certificateUrl,
                                                                fileName:
                                                                    'file.$ext',
                                                                mimeType: mime,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "DOCUMENT TYPE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .documents![index]
                                                  .documentType ??
                                              "-",
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "ISSUE OF COUNTRY",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .documents![index]
                                                  .countryofIssue ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "EXPIRY DATE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .documents![index]
                                                  .expiryDate ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "REMARKS",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel.message!
                                                  .documents![index].remarks ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "REMAINDER DATE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .documents![index]
                                                  .remainderDate ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  )),
                              // Expanded(
                              //     flex: 1,
                              //     child: InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) => EditDocuments(
                              //                   model: empinfomodel,
                              //                   iseditable: true,
                              //                   position: index)),
                              //         ).then((_) => getdata());
                              //       },
                              //       child: const Icon(
                              //         CupertinoIcons.pencil_circle,
                              //         size: 24,
                              //         color: Appcolor.grey,
                              //       ),
                              //     ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text('No Documents Found!'),
                ),
        ],
      ),
    );
  }

  Widget dependents() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => EditDepends(
              //           model: empinfomodel, iseditable: false, position: 0)),
              // ).then((_) => getdata());
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: "Dependents Details",
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ],
              ),
            ),
          ),
          (empinfomodel.message != null)
              ? ListView.builder(
                  itemCount: empinfomodel.message!.dependantDetails!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 10),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "NAME",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                              .message!
                                              .dependantDetails![index]
                                              .dependantName
                                              .toString(),
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "RELATION SHIP",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                              .message!
                                              .dependantDetails![index]
                                              .relationship
                                              .toString(),
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "INSURANCE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                              .message!
                                              .dependantDetails![index]
                                              .insurance
                                              .toString(),
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "EDU.ALLOWANCE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                              .message!
                                              .dependantDetails![index]
                                              .educationAllowance
                                              .toString(),
                                          fontSize: 14,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppUtils.buildNormalText(
                                            text: "DATE OF BIRTH",
                                            fontSize: 12,
                                            color: labelColor),
                                        const SizedBox(height: 5),
                                        AppUtils.buildNormalText(
                                            text: empinfomodel.message!
                                                .dependantDetails![index].dob
                                                .toString(),
                                            fontSize: 14,
                                            color: textColor),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        AppUtils.buildNormalText(
                                            text: "PHONE NO",
                                            fontSize: 12,
                                            color: labelColor),
                                        const SizedBox(height: 5),
                                        AppUtils.buildNormalText(
                                            text: empinfomodel
                                                .message!
                                                .dependantDetails![index]
                                                .phoneNo
                                                .toString(),
                                            fontSize: 12,
                                            color: textColor),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        AppUtils.buildNormalText(
                                            text: "AIR TICKET ELIGIBLITY",
                                            fontSize: 12,
                                            color: labelColor),
                                        const SizedBox(height: 5),
                                        AppUtils.buildNormalText(
                                            text: empinfomodel
                                                .message!
                                                .dependantDetails![index]
                                                .airTicket
                                                .toString(),
                                            fontSize: 14,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            color: textColor),
                                      ],
                                    )),
                                // Expanded(
                                //     flex: 1,
                                //     child: InkWell(
                                //       onTap: () {
                                //         Navigator.push(
                                //           context,
                                //           MaterialPageRoute(
                                //               builder: (context) => EditDepends(
                                //                   model: empinfomodel,
                                //                   iseditable: true,
                                //                   position: index)),
                                //         ).then((_) => getdata());
                                //       },
                                //       child: const Icon(
                                //         CupertinoIcons.pencil_circle,
                                //         size: 24,
                                //         color: Appcolor.grey,
                                //       ),
                                //     ))
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Divider(
                            height: 1,
                            thickness: 0.5,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    );
                  })
              : const Center(
                  child: Text('No Depends Found!'),
                ),
        ],
      ),
    );
  }

  Widget skillsdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => EditSkills(
              //           model: empinfomodel, iseditable: false, position: 0)),
              // ).then((_) => getdata());
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: "Skill Details",
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ],
              ),
            ),
          ),
          (empinfomodel.message != null &&
                  empinfomodel.message!.skill!.isNotEmpty)
              ? ListView.builder(
                  itemCount: empinfomodel.message!.skill!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.buildNormalText(
                                        text: "SKILL CODE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel.message!
                                                .skill![index].skillCode ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "YEAR OF EXPERIENCE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .skill![index]
                                                .skillexperience ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "SKILL NAME",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel.message!
                                                  .skill![index].skillName ??
                                              "-",
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "ATTACHMENT",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      (empinfomodel.message!.skill![index]
                                                  .skillCertificate
                                                  .toString()
                                                  .isEmpty ||
                                              empinfomodel
                                                      .message!
                                                      .skill![index]
                                                      .skillCertificate
                                                      .toString() ==
                                                  "null")
                                          ? Container()
                                          : RichText(
                                              text: TextSpan(
                                                text: "",
                                                style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface, // 👈 dynamic text color
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "View Attachment",
                                                    style: TextStyle(
                                                      fontSize: 15.0,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary, // 👈 theme primary color
                                                    ),
                                                    recognizer:
                                                        TapGestureRecognizer()
                                                          ..onTap = () async {
                                                            final certificateUrl =
                                                                empinfomodel
                                                                    .message!
                                                                    .skill![
                                                                        index]
                                                                    .skillCertificate!;

                                                            if (certificateUrl
                                                                .isEmpty)
                                                              return;

                                                            final mime =
                                                                await AppConstants
                                                                    .getMimeType(
                                                                        certificateUrl);
                                                            final ext = AppConstants
                                                                .getExtensionFromMime(
                                                                    mime);

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (_) =>
                                                                    ViewFiles(
                                                                  fileUrl:
                                                                      certificateUrl,
                                                                  fileName:
                                                                      'file.$ext',
                                                                  mimeType:
                                                                      mime,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                  ),
                                                ],
                                              ),
                                            )
                                    ],
                                  )),
                              // Expanded(
                              //     flex: 1,
                              //     child: InkWell(
                              //       onTap: () {
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) => EditSkills(
                              //                   model: empinfomodel,
                              //                   iseditable: true,
                              //                   position: index)),
                              //         ).then((_) => getdata());
                              //       },
                              //       child: const Icon(
                              //         CupertinoIcons.pencil_circle,
                              //         size: 24,
                              //         color: Appcolor.grey,
                              //       ),
                              //     ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text('No Skill Details Found!'),
                ),
        ],
      ),
    );
  }

  Widget dependentIDdetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: InkWell(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => EditDependsIdDetails(
                //           model: empinfomodel, iseditable: false, position: 0)),
                // ).then((_) => getdata());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                    text: "Dependent ID Details",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ],
              ),
            ),
          ),
          (empinfomodel.message != null &&
                  empinfomodel.message!.dependantIdDetails!.isNotEmpty)
              ? ListView.builder(
                  itemCount:
                      empinfomodel.message!.dependantIdDetails!.length ?? 0,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.buildNormalText(
                                        text: "ID NO",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .dependantIdDetails![index]
                                                .idNo ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "RELATION NAME",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .dependantIdDetails![index]
                                                .dependantIdName ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "ISSUE DATE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .dependantIdDetails![index]
                                                .issueDate ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "DESIGATION",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .dependantIdDetails![index]
                                                .designation ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "REMAINDER",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                            .message!
                                            .dependantIdDetails![index]
                                            .remainder
                                            .toString(),
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "ATTACHMENT",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    (empinfomodel
                                                .message!
                                                .dependantIdDetails![index]
                                                .attachment
                                                .toString()
                                                .isEmpty ||
                                            empinfomodel
                                                    .message!
                                                    .dependantIdDetails![index]
                                                    .attachment
                                                    .toString() ==
                                                "null")
                                        ? Container()
                                        : RichText(
                                            text: TextSpan(
                                              text: "",
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface, // 👈 dynamic text color
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: "View Attachment",
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w600,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary, // 👈 theme primary color
                                                  ),
                                                  recognizer:
                                                      TapGestureRecognizer()
                                                        ..onTap = () async {
                                                          final certificateUrl =
                                                              empinfomodel
                                                                  .message!
                                                                  .dependantIdDetails![
                                                                      index]
                                                                  .attachment!;

                                                          if (certificateUrl
                                                              .isEmpty) return;

                                                          final mime =
                                                              await AppConstants
                                                                  .getMimeType(
                                                                      certificateUrl);
                                                          final ext = AppConstants
                                                              .getExtensionFromMime(
                                                                  mime);

                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) =>
                                                                  ViewFiles(
                                                                fileUrl:
                                                                    certificateUrl,
                                                                fileName:
                                                                    'file.$ext',
                                                                mimeType: mime,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                ),
                                              ],
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "ID TYPE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .dependantIdDetails![index]
                                                  .idType ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "COUNTRY OF ISSUE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .dependantIdDetails![index]
                                                  .countryOfIssue ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "EXPIRY DATE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .dependantIdDetails![index]
                                                  .expiryDate ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "REMARKS",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .dependantIdDetails![index]
                                                  .remarks ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "REMAINDER DATE",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .dependantIdDetails![index]
                                                  .remainderDate ??
                                              "-",
                                          fontSize: 12,
                                          color: textColor,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                    ],
                                  )),
                              // Expanded(
                              //     flex: 1,
                              //     child: InkWell(
                              //       onTap: () {
                              //         print(empinfomodel.message!
                              //             .dependantIdDetails![index].sId);
                              //         Navigator.push(
                              //           context,
                              //           MaterialPageRoute(
                              //               builder: (context) =>
                              //                   EditDependsIdDetails(
                              //                       model: empinfomodel,
                              //                       iseditable: true,
                              //                       position: index)),
                              //         ).then((_) => getdata());
                              //       },
                              //       child: const Icon(
                              //         CupertinoIcons.pencil_circle,
                              //         size: 24,
                              //         color: Appcolor.grey,
                              //       ),
                              //     ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text('No Dependents Found!'),
                ),
        ],
      ),
    );
  }

  Widget assetDetails() {
    final theme = Theme.of(context);
    final textColor = theme.colorScheme.onSurface;
    final labelColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final cardColor = theme.cardColor;
    return Card(
      color: cardColor,
      elevation: 3,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => EditSkills(
              //           model: empinfomodel, iseditable: false, position: 0)),
              // ).then((_) => getdata());
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppUtils.buildNormalText(
                      text: "Asset Details",
                      fontSize: 18,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold),
                  AppUtils.buildNormalText(
                      text: "", fontSize: 14, color: Appcolor.twitterBlue),
                ],
              ),
            ),
          ),
          (empinfomodel.message != null &&
                  empinfomodel.message!.skill!.isNotEmpty)
              ? ListView.builder(
                  itemCount: empinfomodel.message!.skill!.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppUtils.buildNormalText(
                                        text: "ASSET CODE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .assetDetails![index]
                                                .assetCode ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "ASSET TYPE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .assetDetails![index]
                                                .assetType ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    AppUtils.buildNormalText(
                                        text: "DATE",
                                        fontSize: 12,
                                        color: labelColor),
                                    const SizedBox(height: 5),
                                    AppUtils.buildNormalText(
                                        text: empinfomodel
                                                .message!
                                                .assetDetails![index]
                                                .assetassignDate ??
                                            "-",
                                        fontSize: 12,
                                        color: textColor),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppUtils.buildNormalText(
                                          text: "ASSET NAME",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .assetDetails![index]
                                                  .assetName ??
                                              "-",
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "SERIAL",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .assetDetails![index]
                                                  .assetSerialNo ??
                                              "-",
                                          fontSize: 14,
                                          color: textColor),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      AppUtils.buildNormalText(
                                          text: "STATUS",
                                          fontSize: 12,
                                          color: labelColor),
                                      const SizedBox(height: 5),
                                      AppUtils.buildNormalText(
                                          text: empinfomodel
                                                  .message!
                                                  .assetDetails![index]
                                                  .status ??
                                              "-",
                                          fontSize: 14,
                                          color: textColor),
                                    ],
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  })
              : const Center(
                  child: Text('No Asset Details Found!'),
                ),
        ],
      ),
    );
  }

  void getdata() async {
    setState(() {
      loading = true;
    });
    ApiService.getemployeedetailsdata().then((response) {
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        if (jsonDecode(response.body)['status'].toString() == "true") {
          empinfomodel = EmpInfoModel.fromJson(jsonDecode(response.body));
        } else {
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

  void onrefresh() {
    Navigator.of(context).pop();
    getdata();
    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void onsuccessimagerefresh() {
    Navigator.of(context).pop();
  }

  Future<void> _launchUrl(url, {bool isNewTab = true}) async {
    if (Platform.isAndroid) {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalNonBrowserApplication)) {
        throw Exception('Could not launch $url');
      }
    } else if (Platform.isIOS) {
      if (!await launchUrl(Uri.parse(url),
          mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    }
  }
}
