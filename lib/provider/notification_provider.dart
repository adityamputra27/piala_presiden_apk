// notif_provider.dart
import 'package:flutter/material.dart';
import 'package:piala_presiden_apk/data/local_notification_db.dart';
import 'package:piala_presiden_apk/models/local_notification.dart';

class NotificationProvider with ChangeNotifier {
  List<LocalNotification> _notifications = [];
  int _unreadCount = 0;

  List<LocalNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  // Ambil data dari db dan update state
  Future<void> fetchNotif() async {
    _notifications = await LocalNotificationDb().getAllNotif();
    _unreadCount = await LocalNotificationDb().getUnreadCount();
    notifyListeners();
  }

  // Insert notif baru dari FCM
  Future<void> insertNotif(LocalNotification notif) async {
    await LocalNotificationDb().insertOrIgnore(notif);
    await fetchNotif();
  }

  // Mark satu notif as read
  Future<void> markAsRead(String id) async {
    await LocalNotificationDb().markAsRead(id);
    await fetchNotif();
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    await LocalNotificationDb().markAllAsRead();
    await fetchNotif();
  }

  // Delete notif
  Future<void> deleteNotif(String id) async {
    await LocalNotificationDb().deleteNotif(id);
    await fetchNotif();
  }
}
