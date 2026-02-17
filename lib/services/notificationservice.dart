import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../main.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initFCM() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // ✅ For iOS, allow foreground alerts
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (Platform.isIOS) {
      // Wait for APNs registration to complete
      await Future.delayed(const Duration(seconds: 3));
    }

    try {
      String? token = await _messaging.getToken();
      print("🔥 FCM Token: $token");
    } catch (e) {
      print("⚠️ Error getting FCM token: $e");
    }

    // Android permissions
    if (Platform.isAndroid &&
        (await _messaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            ))
                .authorizationStatus !=
            AuthorizationStatus.authorized) {
      print("User declined notification permission on Android");
    }

    // Get FCM token

    // Initialize local notifications
    await _initLocalNotifications();

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundNotification);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    // App opened from notification (background or terminated)
    _handleNotificationClick();

    // Token refresh listener
    _messaging.onTokenRefresh.listen((newToken) {
      print('New FCM Token: $newToken');
    });
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final route = response.payload;
        _navigateToRoute(route);
      },
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    //  final notification = AppNotification(
    //   id: message.messageId ?? message.hashCode.toString(),
    //   title: message.notification?.title ?? message.data['title'] ?? '',
    //   body: message.notification?.body ?? message.data['body'] ?? '',
    //   route: message.data['route'] ?? '',
    //   receivedAt: DateTime.now(),
    // );

    // saveNotification(notification); // ✅ Save with duplicate check

    final title = message.data['title'] ?? message.notification?.title;
    final body = message.data['body'] ?? message.notification?.body;
    final route = message.data['route'];

    if (title != null && body != null) {
      _localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel',
            'Default',
            channelDescription: 'Default notifications',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: route,
      );
    }
  }

  void _handleNotificationClick() async {
    // App opened from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _navigateToRoute(initialMessage.data['route']);
    }

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _navigateToRoute(message.data['route']);
    });
  }

  // Future<void> saveNotification(AppNotification notification) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final stored = prefs.getStringList('notifications') ?? [];

  //   final existing = stored.any((e) {
  //     final map = jsonDecode(e);
  //     return map['id'] == notification.id;
  //   });

  //   if (existing) {
  //     print('⚠️ Duplicate notification skipped');
  //     return;
  //   }

  //   stored.insert(0, jsonEncode(notification.toMap()));
  //   await prefs.setStringList('notifications', stored);
  //   print('✅ Notification saved');
  // }

  void _navigateToRoute(String? route) {
    if (route == null || route.isEmpty) return;

    switch (route) {
      case 'leaveApproval':
        break;
      case 'waitingApproval':
        navigatorKey.currentState?.pushNamed('/waitingApproval');
        break;
      case 'otherPage':
        navigatorKey.currentState?.pushNamed('/otherPage');
        break;
      default:
        navigatorKey.currentState?.pushNamed('/');
    }
  }
}

/// Top-level background handler
@pragma('vm:entry-point')
Future<void> _handleBackgroundNotification(RemoteMessage message) async {
  await Firebase.initializeApp();

  final localNotifications = FlutterLocalNotificationsPlugin();
  const androidSettings =
      AndroidInitializationSettings('@mipmap/launcher_icon');
  const iosSettings = DarwinInitializationSettings();
  const initSettings =
      InitializationSettings(android: androidSettings, iOS: iosSettings);

  await localNotifications.initialize(initSettings);

  final title = message.data['title'] ?? message.notification?.title;
  final body = message.data['body'] ?? message.notification?.body;
  final route = message.data['route'];

  if (title != null && body != null) {
    localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default',
          channelDescription: 'Default notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: route,
    );
  }
}
