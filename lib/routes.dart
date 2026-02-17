import 'package:AlSaqr/views/loanrequest/loanrequest.dart';
import 'package:AlSaqr/views/loanrequest/loandetailsview.dart';
import 'package:AlSaqr/views/memorequest/memorequest.dart';
import 'package:AlSaqr/views/memorequest/memoview.dart';
import 'package:AlSaqr/views/passportrequest/passportrequest.dart';
import 'package:AlSaqr/views/passportrequest/passportview.dart';
import 'package:flutter/material.dart';

import 'routenames.dart';
import 'views/airticket/airticketrequest.dart';
import 'views/airticket/airticketview.dart';
import 'views/assetrequest/assetapply.dart';
import 'views/assetrequest/viewassets.dart';
import 'views/attendance/attendance_history.dart';
import 'views/attendance/view_attendance.dart';
import 'views/changepassword/changepassword.dart';
import 'views/dutytravel/dutytravelapply.dart';
import 'views/dutytravel/dutytraveldetail.dart';
import 'views/grievances/applygrievance.dart';
import 'views/landingpage/teammets.dart';
import 'views/leave/applycompoffpage.dart';
import 'views/leave/dummy.dart';
import 'views/leave/leaveapplypage.dart';
import 'views/leave/viewcompoffdetails.dart';
import 'views/leave/viewleavedetails.dart';
import 'views/letterpage/letterapply.dart';
import 'views/letterpage/viewletterdetails.dart';
import 'views/loanrequest/loanview.dart';
import 'views/login/loginpage.dart';
import 'views/overtime/overtimehistory.dart';
import 'views/payslip/viewpayslip.dart';
import 'views/profilepage/profilepage.dart';
import 'views/reimbursement/reimburesementapply.dart';
import 'views/reimbursement/reimbursementdetails.dart';
import 'views/rejoin/rejointab.dart';
import 'views/splash.dart/splash.dart';


class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
  //  final args = settings.arguments;
    switch (settings.name) {
      case (RouteNames.splashscreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());
      case (RouteNames.loginscreen):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginPage());
      // case (RouteNames.landingpage):
      //   return MaterialPageRoute(
      //       builder: (BuildContext context) => const LandingPage());

      case (RouteNames.attendancehistory):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Attendancehistory());

      //LEAVE
      case (RouteNames.applyleave):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LeaveApplyPage());
      case (RouteNames.viewleave):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ViewLeavePage());

      //LEAVE
      case (RouteNames.applycompoffleave):
        return MaterialPageRoute(
            builder: (BuildContext context) => const CompOffApplyPage());
      case (RouteNames.viewcompoffleave):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ViewCompOffPage());

      //ASSET
      case (RouteNames.viewasset):
        return MaterialPageRoute(
            builder: (BuildContext context) => const AssetDetailPage());

      case (RouteNames.applyasset):
        return MaterialPageRoute(
            builder: (BuildContext context) => const AssetApplyPage());
      //LETTER REQUEST

      // case (RouteNames.rejoin):
      //   return MaterialPageRoute(
      //       builder: (BuildContext context) => const DutyResumption());
      case (RouteNames.viewrejoin):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ReJoinTab());
      //ASSET
      case (RouteNames.viewletter):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ViewLetterDetailsPage());
      case (RouteNames.addletter):
        return MaterialPageRoute(
            builder: (BuildContext context) => const LetterApplyPage());
      //Duty Travel
      case (RouteNames.dutytravelview):
        return MaterialPageRoute(
            builder: (BuildContext context) => const DutyTravelDetailsPage());
      case (RouteNames.dutytravelapply):
        return MaterialPageRoute(
            builder: (BuildContext context) => const DutyTravelApplyPage());
      //REIM APPLY
      case (RouteNames.reimview):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ReimbursementDetails());
      case (RouteNames.reimapply):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ReimbursementApplyPage());

      //GRIEVANCE
      case (RouteNames.viewgrievance):
      case (RouteNames.addgrievance):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ApplyGrievancePage());

      case (RouteNames.changepassword):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ChangePassword());
      case (RouteNames.payslip):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ViewPaySlipPage());
      case (RouteNames.viewattendance):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ViewAttendance());

      case (RouteNames.overtimehistory):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Overtimehistory());

      case (RouteNames.viewprofile):
        return MaterialPageRoute(
            builder: (BuildContext context) => const ProfilePage());

      case (RouteNames.viewdummy):
        return MaterialPageRoute(
            builder: (BuildContext context) => const DummyScreen());

      case (RouteNames.myteam):
        return MaterialPageRoute(
            builder: (BuildContext context) => const MyTeamScreen());
      case (RouteNames.viewairticket):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Airticketview());
      case (RouteNames.airticketrequest):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Airticketrequest());
      case (RouteNames.passportrequest):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Passportrequest());
      case (RouteNames.viewpassport):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Passportview());
      case (RouteNames.memorequest):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Memorequest());
      case (RouteNames.viewmemo):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Memoview());
      case (RouteNames.loanrequest):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Loanrequest());
      case (RouteNames.viewloan):
        return MaterialPageRoute(
            builder: (BuildContext context) => const Loanview());
      default:
        _errorRoute();
    }
    return _errorRoute();
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text("No route is configured"),
        ),
      ),
    );
  }
}
