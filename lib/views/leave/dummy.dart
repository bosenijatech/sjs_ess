import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../models/announcementmodel.dart';
import '../../models/error_model.dart';
import '../../models/holidaymastermodel.dart';
import '../../models/loginmodel.dart';
import '../../models/pendingmodel.dart';
import '../../routenames.dart';
import '../../services/apiservice.dart';
import '../../services/pref.dart';
import '../../services/userstatusservice.dart';
import '../../utils/app_utils.dart';
import '../../utils/constants.dart';
import '../../utils/sharedprefconstants.dart';
import '../payslip/viewallfiles.dart';
import '../widgets/assets_image_widget.dart';
import '../widgets/wishthempage.dart';

class DummyScreen extends StatefulWidget {
  const DummyScreen({super.key});

  @override
  State<DummyScreen> createState() => _DummyScreenState();
}

class _DummyScreenState extends State<DummyScreen> {
  List<AnnouncementData> announcementList = [];

  bool loading = false;
  int leaveCount = 0;
  int letterCount = 0;
  int totalCount = 0;
  ErrorModelNetSuite errorModelNetSuite = ErrorModelNetSuite();
  List<HolidayModel> holidayList = [];

  PendingModel model = PendingModel();
  List<Map<String, String>> wishData = [];
  List<Map<String, String>> leaveData = [];
  List<Map<String, String>> allWishData = [];
  final months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  @override
  void initState() {
    UserStatusService().startChecking(context);
    getAllEvents();
    super.initState();
  }

  @override
  void dispose() {
    UserStatusService().stopChecking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: !loading
          ? SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => getAllEvents(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerSection(context),
                        const SizedBox(height: 10),
                        otherServicesSection(context),
                        const SizedBox(height: 10),
                        if (announcementList.isNotEmpty) announcementSection(),
                        const SizedBox(height: 10),
                        wishlistwidgets(context),
                        const SizedBox(height: 10),
                        leavewidgets(context),
                        const SizedBox(height: 10),
                        // upcomingHolidays(context),
                        // const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget headerSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 👤 Profile Section
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.grey.shade800 : Colors.white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  child: ClipOval(
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: getProfileImage(size: 56),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // 👋 Greeting Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello ${Prefs.getFullName(SharefprefConstants.shareFullName) ?? "User"}!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    'Welcome Back!',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🚪 Logout Button
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.5)
                      : Colors.black12.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: isDark ? Colors.redAccent.shade100 : Colors.red,
              ),
              onPressed: () => logout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget getProfileImage({double size = 100}) {
    final gender =
        Prefs.getGender(SharefprefConstants.sharedgender)?.toLowerCase() ?? "";
    final imageUrl = Prefs.getImei(SharefprefConstants.sharedimei) ?? "";

    if (imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.fill,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return SizedBox(
              width: size,
              height: size,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return _defaultProfileImage(gender, size);
          },
        ),
      );
    }

    return _defaultProfileImage(gender, size);
  }

  Widget _defaultProfileImage(String gender, double size) {
    final asset = gender == "female"
        ? 'assets/icons/female.jpeg'
        : 'assets/icons/male.jpeg';

    return ClipOval(
      child: Image.asset(
        asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget otherServicesSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final services = [
      {
        'icon': CupertinoIcons.person_2,
        'label': 'My Profile',
        'color': Colors.blue
      },
      {
        'icon': Icons.flight_takeoff_rounded,
        'label': 'Leave Request',
        'color': Colors.purple
      },
      {
        'icon': Icons.description_outlined,
        'label': 'Letter Request',
        'color': Colors.amber
      },
      {
        'icon': Icons.picture_as_pdf,
        'label': 'Pay Slip',
        'color': Colors.green
      },
      {
        'icon': Icons.account_balance_wallet_rounded,
        'label': 'HR Expenses',
        'color': Colors.deepPurple
      },
      {'icon': Icons.group, 'label': 'Team', 'color': Colors.redAccent},
      {
        'icon': Icons.devices_other,
        'label': 'Asset Request',
        'color': Colors.indigo
      },
      {
        'icon': Icons.flight_takeoff_outlined,
        'label': 'Comp Off Leave',
        'color': Colors.pink
      },
      {
        'icon': Icons.refresh_rounded,
        'label': 'Re-join Request',
        'color': Colors.teal
      },
      {
        'icon': Icons.password_outlined,
        'label': 'Change Password',
        'color': Colors.deepOrange
      },
            {
        'icon': Icons.airplane_ticket,
        'label': 'Air Ticket Request',
        'color': Colors.deepPurple
      },
      {
        'icon': Icons.how_to_reg,
        'label': 'Daily Attendance',
        'color': Colors.green
      },
      {
        'icon': Icons.flight,
        'label': 'Passport Request',
        'color': Colors.blueAccent
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Memo Request',
        'color': Colors.teal
      },
      {
        'icon': Icons.edit_calendar,
        'label': 'Attendance Reqularization',
        'color': Colors.indigo
      },
      {
        'icon': Icons.account_balance,
        'label': 'Loan Request',
        'color': Colors.deepOrange
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.cardColor, // ✅ automatically adapts
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.black12.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          final Color baseColor = service['color'] as Color;

          return GestureDetector(
            onTap: () {
              final routeNames = [
                RouteNames.viewprofile,
                RouteNames.viewleave,
                RouteNames.viewletter,
                RouteNames.payslip,
                RouteNames.reimview,
                RouteNames.myteam,
                RouteNames.viewasset,
                RouteNames.viewcompoffleave,
                RouteNames.viewrejoin,
                RouteNames.changepassword,
                RouteNames.viewairticket,
                RouteNames.viewpassport,
                RouteNames.viewpassport,
                RouteNames.viewmemo,
                RouteNames.viewmemo,
                RouteNames.viewloan,
              ];

              if (index < routeNames.length) {
                Navigator.pushNamed(context, routeNames[index]).then((_) {
                  getAllEvents();
                });
              }
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: baseColor.withOpacity(isDark ? 0.7 : 1),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    color: baseColor.withOpacity(isDark ? 0.15 : 0.08),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: baseColor,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service['label'] as String,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget dashboardGrid(double width) {
    final List<Map<String, dynamic>> items = [
      {
        'icon': Icons.person,
        'label': 'My Profile',
        'color': const Color(0xff5cbc3c),
        'route': RouteNames.viewprofile
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Leave Request',
        'color': const Color(0xfffe5d3b),
        'route': RouteNames.viewleave
      },
      {
        'icon': Icons.dock,
        'label': 'Letter Request',
        'color': const Color(0xffe32845),
        'route': RouteNames.viewletter
      },
      {
        'icon': Icons.receipt_long,
        'label': 'Pay Slip',
        'color': const Color(0xff31aaf3),
        'route': RouteNames.payslip
      },
      {
        'icon': Icons.task,
        'label': 'View Claim',
        'color': const Color(0xff785af6),
        'route': RouteNames.reimview
      },
      {
        'icon': Icons.people,
        'label': 'Team',
        'color': const Color(0xfff59d00),
        'route': RouteNames.myteam
      },
      {
        'icon': Icons.devices_other,
        'label': 'Asset Request',
        'color': const Color(0xfff500e9),
        'route': RouteNames.viewasset
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width < 600 ? 3 : 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () => Navigator.pushNamed(context, item['route']),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [item['color'], item['color'].withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: item['color'].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item['icon'], color: Colors.white, size: 30),
                const SizedBox(height: 8),
                Text(item['label'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget announcementSection() {
    return Card(
      elevation: 3,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.campaign_rounded,
                      color: Colors.purple, size: 22),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Announcements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 3,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            // 🔹 List
            if (announcementList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ),
              )
            else
              ListView.separated(
                separatorBuilder: (_, __) => Divider(
                  color: Colors.grey.shade300,
                  height: 20,
                ),
                itemCount: announcementList.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final ann = announcementList[index];
                  return InkWell(
                    onTap: () async {
                      if (ann.attachmentURL.isNotEmpty) {
                        final mime =
                            await AppConstants.getMimeType(ann.attachmentURL);
                        final ext = AppConstants.getExtensionFromMime(mime);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ViewFiles(
                              fileUrl: ann.attachmentURL,
                              fileName: 'file.$ext',
                              mimeType: mime,
                            ),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.purple.shade100,
                            child: Text(
                              ann.message.isNotEmpty
                                  ? ann.message[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ann.message,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (ann.attachmentURL.isNotEmpty)
                                  const Row(
                                    children: [
                                      Icon(Icons.attach_file,
                                          color: Colors.purple, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        "View Attachment",
                                        style: TextStyle(
                                            color: Colors.purple,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ann.attachmentURL.isNotEmpty
                              ? const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget upcomingHolidays(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (holidayList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'No upcoming holidays 🎉',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        elevation: 4,
        color: theme.cardColor,
        shadowColor: colorScheme.shadow.withOpacity(0.25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Title Section
              Text(
                'Upcoming Holidays',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: holidayList.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final holiday = holidayList[index];
                    final baseColor = colorScheme.primary.withOpacity(0.9);

                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                        width: 230,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              baseColor,
                              colorScheme.primaryContainer.withOpacity(0.9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🔹 Holiday Name
                              Text(
                                holiday.name ?? '',
                                style: TextStyle(
                                  color: colorScheme.onPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              // 🔹 Date & Day Details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month,
                                        color: colorScheme.onPrimary,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        holiday.holidayDate ?? '',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if ((holiday.holidayDay ?? '').isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.event_available,
                                          color: colorScheme.onPrimary,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          holiday.holidayDay ?? '',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget wishlistwidgets(BuildContext context) {
    final theme = Theme.of(context);

    if (wishData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        elevation: 3,
        color: theme.cardColor,
        shadowColor: theme.shadowColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: WishThemWidget(
          type: "Upcoming Birthday 🎂",
          wishList: wishData,
        ),
      ),
    );
  }

  Widget leavewidgets(BuildContext context) {
    final theme = Theme.of(context);

    if (leaveData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Card(
        elevation: 3,
        color: theme.cardColor, // ✅ adapts to light/dark theme
        shadowColor: theme.shadowColor.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: WishThemWidget(
          type: "Off this Week 🌴",
          wishList: leaveData,
        ),
      ),
    );
  }

  void logout() async {
    Prefs.clear(); // Clears all stored preferences
    Prefs.remove("remove"); // Redundant if clear() already wipes everything
    Prefs.setLoggedIn(
        SharefprefConstants.sharefloggedin, false); // Explicit logout flag

    Navigator.pushNamedAndRemoveUntil(
      context,
      RouteNames.loginscreen,
      (Route<dynamic> route) => false,
    );
  }

  void getAllEvents() async {
    if (!mounted) return;

    setState(() => loading = true);

    await Future.wait<void>([
      syncCredentialsFromBackend(),
      // fetchHolidayData(),
      getleavelist(),
      getannouncement(),
      getBirthdayList(),
    ]);
    if (!mounted) return;
    setState(() => loading = false);
  }

  Future<void> syncCredentialsFromBackend() async {
    final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}api/mobileapp/getcredentials'));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body['status'].toString() == "true") {
        final loginModel = LoginModel.fromJson(body);

        if (loginModel.secretkey != null && loginModel.secretkey!.isNotEmpty) {
          await updateSharedPrefIfDifferent(loginModel);
        }
      }
    }
  }

  Future<void> updateSharedPrefIfDifferent(LoginModel loginModel) async {
    final newKey = loginModel.secretkey![0];

    // Read existing values
    final currentConsumerKey =
        Prefs.getnetsuiteConsumerKey("netsuiteConsumerKey");
    final currentConsumerSecret =
        Prefs.getnetsuiteConsumerSecret("netsuiteConsumerSecret");
    final currentToken = Prefs.getnetsuiteToken("netsuiteToken");
    final currentTokenSecret =
        Prefs.getnetsuiteTokenSecret("netsuiteTokenSecret");
    final currentRealm = Prefs.getRealm("netSuiteRealm");

    // Update only if different
    if (currentConsumerKey != newKey.cONSUMERKEY) {
      await Prefs.setnetsuiteConsumerKey(
          "netsuiteConsumerKey", newKey.cONSUMERKEY.toString());
    }

    if (currentConsumerSecret != newKey.cONSUMERSECRET) {
      await Prefs.setnetsuiteConsumerSecret(
          "netsuiteConsumerSecret", newKey.cONSUMERSECRET.toString());
    }

    if (currentToken != newKey.aCCESSTOKEN) {
      await Prefs.setnetsuiteToken(
          "netsuiteToken", newKey.aCCESSTOKEN.toString());
    }

    if (currentTokenSecret != newKey.tOKENSECRET) {
      await Prefs.setnetsuiteTokenSecret(
          "netsuiteTokenSecret", newKey.tOKENSECRET.toString());
    }

    if (currentRealm != newKey.rEALM) {
      await Prefs.setRealm("netSuiteRealm", newKey.rEALM.toString());
    }

    print("SharedPreferences updated if any key changed");
  }

  Future<void> getannouncement() async {
    try {
      final response = await ApiService.viewannouncement();

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rootData = decoded['data'];

        // Extract inner "data" arrays and flatten
        announcementList = rootData.expand((announcement) {
          final List dataList = announcement['data'] ?? [];
          return dataList.map((e) => AnnouncementData.fromJson(e));
        }).toList();

        print(jsonEncode(announcementList));
      } else {
        throw Exception(jsonDecode(response.body)['message'].toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  Future<void> fetchHolidayData() async {
    try {
      setState(() => loading = true);

      final List<HolidayModel> holidays = await ApiService.getHolidayMaster(
          regionFilter:
              Prefs.getWorkRegion(SharefprefConstants.sharedWorkregion) ?? "");

      setState(() {
        holidayList.clear();
        holidayList.addAll(holidays);
        loading = false;
      });
    } catch (e) {
      print("Error fetching holidays: $e");
      setState(() => loading = false);
    }
  }

  Future<void> getleavelist() async {
    try {
      final response = await ApiService.getPendingleaves();
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['status'] == true) {
          final leaveResponse = decoded['data'];
          if (leaveResponse is List) {
            leaveData = leaveResponse.map<Map<String, String>>((emp) {
              final fullName = emp['toEmpName']?.toString() ?? '';
              final initials = fullName.trim().isNotEmpty
                  ? fullName
                      .trim()
                      .split(" ")
                      .where((e) => e.isNotEmpty)
                      .map((e) => e.characters.first)
                      .take(2)
                      .join()
                  : "??";

              return {
                "name": fullName,
                "date": emp['leaveDate']?.toString() ?? '',
                "type": "LEAVE",
                "initials": initials,
                "photo": ""
              };
            }).toList();

            if (!mounted) return;
            setState(() {
              allWishData = [...wishData, ...leaveData];
            });
          } else {
            if (!mounted) return;
            setState(() {
              leaveData = [];
            });
          }
          print("Leave List: $leaveData");
        } else {
          if (!mounted) return;
          setState(() {
            leaveData = [];
          });
        }
      } else {
        //throw Exception(jsonDecode(response.body)['message'].toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  Future<void> getBirthdayList() async {
    try {
      final response = await ApiService.getBirthdayList();
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final data = decoded['message'];
        if (decoded['status'].toString() == "true" && data is List) {
          final List<dynamic> rawList = data;

          final List<Map<String, dynamic>> mapped = rawList.map((emp) {
            final firstName = emp['firstName'] ?? '';
            final lastName = emp['lastName'] ?? '';
            final fullName = "$firstName $lastName".trim();

            final dob = emp['dateOfBirth'] ?? ''; // "19/09/2000"
            String formattedDate = '';
            if (dob.contains("/")) {
              final parts = dob.split("/");
              if (parts.length >= 2) {
                final day = parts[0];
                final month = parts[1];
                formattedDate = "$day ${months[int.parse(month) - 1]}";
              }
            }

            return {
              "name": fullName,
              "date": formattedDate,
              "type": "B'DAY",
              "initials": fullName.isNotEmpty
                  ? fullName
                      .split(" ")
                      .map((e) => e.isNotEmpty ? e[0] : "")
                      .take(2)
                      .join()
                  : "??",
              "photo": "",
            };
          }).toList();

          if (!mounted) return;
          setState(() {
            wishData = mapped.cast<Map<String, String>>();
            allWishData = [...wishData, ...leaveData];
          });
        } else {
          if (!mounted) return;
          setState(() {
            wishData = [];
          });
        }
      } else {
        throw Exception(jsonDecode(response.body)['message'].toString());
      }
    } catch (e) {
      if (!mounted) return;
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  void onexitpopup() {
    AppUtils.pop(context);
  }

  String formatDate(DateTime date) => DateFormat('d MMMM y').format(date);
}
