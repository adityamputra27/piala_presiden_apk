import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:piala_presiden_apk/data/local_notification_db.dart';
import 'package:piala_presiden_apk/models/local_notification.dart';

@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(
  NotificationResponse notificationResponse,
) {
  if (kDebugMode) {
    print(notificationResponse);
  }
}

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> showNotification(RemoteMessage message) async {
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.max,
  );

  AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        icon: '@drawable/ic_notification',
        channel.id.toString(),
        channel.name.toString(),
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        ticker: 'ticker',
        color: const Color(0xff0A141B),
        colorized: true,
      );

  await _flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);

  const DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

  NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: darwinNotificationDetails,
  );

  Future.delayed(Duration.zero, () {
    _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      notificationDetails,
    );
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  showNotification(message);

  final topic = message.from?.replaceFirst('/topics/', '');
  await LocalNotificationDb().insertOrIgnore(
    LocalNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? '-',
      message: message.notification?.body ?? '-',
      sentAt: DateTime.now(),
      type: topic!,
      isRead: false,
    ),
  );
}

class FirebaseNotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void initLocalNotifications(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitializationSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    var iosInitializationSettings = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse:
          onDidReceiveBackgroundNotificationResponse,
    );
  }

  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) async {
      initLocalNotifications(context, message);
      showNotification(message);

      // ====== Tambahkan kode insert ke DB/Provider di sini ======
      final data = message.data;
      final topic = message.from?.replaceFirst('/topics/', '');

      await LocalNotificationDb().insertOrIgnore(
        LocalNotification(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification?.title ?? '-',
          message: message.notification?.body ?? '-',
          sentAt: DateTime.tryParse(data['sent_at'] ?? '') ?? DateTime.now(),
          type: topic!,
          isRead: false,
        ),
      );
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  void requestNotificationPermission(Function(bool) onResult) async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: false,
    );

    bool isGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!isGranted) {
      AppSettings.openAppSettings(type: AppSettingsType.notification);
    }

    onResult(isGranted);
  }

  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }
}
