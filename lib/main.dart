
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'routenames.dart';
import 'routes.dart';
import 'services/idletimeoutservice.dart';
import 'services/pref.dart';
import 'views/themes/themes.dart';
import 'views/widgets/custom_widgets.dart';
import 'views/widgets/network_status_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
IdleTimeoutService idleService = IdleTimeoutService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await NotificationService().initFCM();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(errorMessage: details.exceptionAsString());
  };

  await Prefs.init();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<NetworkStatus>(
            create: (context) =>
                NetworkStatusService().networkStatusController.stream,
            initialData: NetworkStatus.online,
          ),
        ],
        child: 
        MaterialApp(
          
          navigatorKey: navigatorKey,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.lightTheme,
          themeMode: ThemeMode.system,
          initialRoute: RouteNames.splashscreen,
          onGenerateRoute: Routes.generateRoutes,
          debugShowCheckedModeBanner: false,
        )
        );
  }
}
