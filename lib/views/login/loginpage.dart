import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/loginmodel.dart';
import '../../routenames.dart';
import '../../services/apiservice.dart';
import '../../services/pref.dart';
import '../../utils/app_utils.dart';
import '../../utils/appcolor.dart';
import '../../utils/sharedprefconstants.dart';
import '../widgets/assets_image_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  LoginModel loginModel = LoginModel();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          // 🌗 Gradient adapts to theme
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E3A8A),
                    const Color(0xFF2C2C2C),
                  ]
                : [
                    Appcolor.whiteShade1,
                    Appcolor.whiteShade2,
                  ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsetsGeometry.all(16),
            child: Column(
              
              children: [
                SizedBox(height: 100,),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    'assets/images/alsaqrlogo.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
             SizedBox(height: 100,),
                // 🌗 Title + Subtitle
                Text(
                  "Welcome Back",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                Text(
                  "Sign in to your Al Saqr account",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? Colors.white70
                        : theme.colorScheme.primary.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 35),
            
                // 📧 Email Field
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Email / Username",
                    prefixIcon: Icon(Icons.email_outlined,
                        color: theme.colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 15),
            
                // 🔒 Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    hintText: "Password",
                    prefixIcon: Icon(Icons.lock_outline,
                        color: theme.colorScheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: theme.colorScheme.primary.withOpacity(0.7),
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
            
                // 🔗 Forgot Password
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: TextButton(
                //     onPressed: () {},
                //     child: Text(
                //       "Forgot Password?",
                //       style: TextStyle(
                //         color: theme.colorScheme.primary,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 20),
            
                // 🚪 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_emailController.text.isEmpty) {
                              AppUtils.showSingleDialogPopup(
                                  context,
                                  "Enter username or email",
                                  "Ok",
                                  onexitpopup,
                                  null);
                            } else if (_passwordController.text.isEmpty) {
                              AppUtils.showSingleDialogPopup(context,
                                  "Enter password", "Ok", onexitpopup, null);
                            } else {
                              getlogin();
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Login"),
                  ),
                ),
                const SizedBox(height: 25),
            
                // 📝 Footer
                Text(
                  "© 2025 Al Saqr. All rights reserved.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.white54 : Appcolor.primarycolor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getlogin() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getlogin(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['status'].toString() == "true") {
          loginModel = LoginModel.fromJson(body);
          if (loginModel.data!.mobileaccess.toString() == "false") {
            AppUtils.showSingleDialogPopup(
              context,
              "You Are Not Authorised Mobile User. Please Contact Your Administrator!",
              "Ok",
              onexitpopup,
              null,
            );
          } else {
            addsharedpref(loginModel);
          }
        } else {
          AppUtils.showSingleDialogPopup(
            context,
            body['message'],
            "Ok",
            onexitpopup,
            AssetsImageWidget.errorimage,
          );
        }
      } else {
        throw Exception("Server Error");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      AppUtils.showSingleDialogPopup(
        context,
        e.toString(),
        "Ok",
        onexitpopup,
        AssetsImageWidget.errorimage,
      );
    }
  }

  Future addsharedpref(LoginModel model) async {
    await Prefs.setLoggedIn(SharefprefConstants.sharefloggedin, true);
    await Prefs.setFullName(
        SharefprefConstants.shareFullName,
        '${model.data!.firstName.toString()}'
        // ' ${model.data!.middleName.toString()}'
        ' ${model.data!.lastName.toString()}');
    await Prefs.setFirstName(
        SharefprefConstants.shareFirstName, model.data!.firstName.toString());
    await Prefs.setMiddleName(
        SharefprefConstants.shareMiddleName, model.data!.middleName.toString());

    await Prefs.setLastName(
        SharefprefConstants.sharedLastName, model.data!.lastName.toString());
    await Prefs.setTitle(
        SharefprefConstants.sharedLastName, model.data!.title.toString());

    await Prefs.setEmpID(
        SharefprefConstants.sharedempId, model.data!.employeeCode!.toString());
    await Prefs.setUniqId(
        SharefprefConstants.shareduniqId, model.data!.sId.toString());
    await Prefs.setUserName(SharefprefConstants.shareduserName,
        model.data!.mobileusername.toString());
    await Prefs.setToken(SharefprefConstants.sharedToken, "");
    await Prefs.setDesignation(SharefprefConstants.shareddesignation, "");
    await Prefs.setDept(
        SharefprefConstants.shareddept, model.data!.department.toString());

    await Prefs.setNsID(
        SharefprefConstants.sharednsid, model.data!.nsId!.toString());

    await Prefs.setShiftName(SharefprefConstants.sharedshiftName,
        "GENERAL SHIFT (08:00 AM - 05:30 PM)");
    await Prefs.setShiftFromTime(
        SharefprefConstants.sharedShiftFromTime, "08:00 AM");
    await Prefs.setShiftToTime(
        SharefprefConstants.sharedShiftToTime, "05:30 PM");

    await Prefs.setImei(SharefprefConstants.sharedimei,
        model.data!.imei.toString() == "" ? "" : model.data!.imei.toString());

    await Prefs.setImageURL(
        (model.data!.imageurl.toString() == "null" ||
                model.data!.imageurl.toString().isEmpty)
            ? ""
            : SharefprefConstants.sharedImgUrl,
        model.data!.imageurl.toString());

    await Prefs.setMobileNo(
        SharefprefConstants.sharedMobNo, model.data!.mobileNo.toString());

    await Prefs.setWorkRegion(SharefprefConstants.sharedWorkregion,
        model.data!.workRegion.toString());

    await Prefs.setLinemanager(
        SharefprefConstants.sharedLineManager,
        model.data!.linemanager.toString() == "null"
            ? "-"
            : model.data!.linemanager.toString());

    await Prefs.setSupervisor(
        SharefprefConstants.sharedsupervisor,
        model.data!.supervisor.toString() == "null"
            ? "-"
            : model.data!.supervisor.toString());

    await Prefs.sethod(
        SharefprefConstants.sharedhod,
        model.data!.hod.toString() == "null"
            ? "-"
            : model.data!.hod.toString());

    await Prefs.setDeviceIdnetifier(SharefprefConstants.sharedDeviceID, "");
    await Prefs.setPayGroupID(SharefprefConstants.sharedpaygroupid,
        model.data!.paygroupId.toString());
    await Prefs.setPayGroupName(SharefprefConstants.sharedpaygroupname,
        model.data!.paygroupName.toString());

    await Prefs.setEmail(
        SharefprefConstants.sharedemailid, model.data!.mobileemail.toString());

    await Prefs.setnetsuiteConsumerKey(
        "netsuiteConsumerKey", model.secretkey![0].cONSUMERKEY.toString());
    await Prefs.setnetsuiteConsumerSecret("netsuiteConsumerSecret",
        model.secretkey![0].cONSUMERSECRET.toString());
    await Prefs.setnetsuiteToken(
        "netsuiteToken", model.secretkey![0].aCCESSTOKEN.toString());
    await Prefs.setnetsuiteTokenSecret(
        "netsuiteTokenSecret", model.secretkey![0].tOKENSECRET.toString());
    await Prefs.setRealm("netSuiteRealm", model.secretkey![0].rEALM.toString());

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, RouteNames.viewdummy, (Route<dynamic> route) => false);
    }
  }

  void onexitpopup() => Navigator.of(context).pop();
}
