import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient client;
  final StreamController<int> _unreadCountCtrl =
      StreamController<int>.broadcast();

  NotificationService({required this.client}) {
    _initRealtime();
  }

  /// Inisialisasi listener Supabase
  void _initRealtime() {
    client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('is_read', false)
        .listen((List<Map<String, dynamic>> supabaseData) async {
          final prefs = await SharedPreferences.getInstance();
          final localList =
              prefs.getStringList('local_unread_notifications') ?? [];

          // Tambahkan ID yang belum ada
          for (final rec in supabaseData) {
            final id = rec['id'].toString();
            if (!localList.contains(id)) {
              localList.add(id);
            }
          }

          await prefs.setStringList('local_unread_notifications', localList);

          _unreadCountCtrl.add(localList.length);
        });
  }

  /// Stream untuk UI berlangganan perubahan count
  Stream<int> get unreadCountStream => _unreadCountCtrl.stream;

  /// Hitung dari SharedPreferences
  Future<int> getLocalUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('local_unread_notifications') ?? [];
    return list.length;
  }

  /// Ambil semua notifikasi (boleh untuk display history)
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await client
        .from('notifications')
        .select()
        .order('sent_at', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> markAllAsRead() async {
    final prefs = await SharedPreferences.getInstance();
    final result = await prefs.remove('local_unread_notifications');
    _unreadCountCtrl.add(0);
  }

  /// Dispose controller (panggil saat App dimatikan)
  void dispose() {
    _unreadCountCtrl.close();
  }
}
