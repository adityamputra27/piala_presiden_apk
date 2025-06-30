class LocalNotification {
  final String id;
  final String title;
  final String message;
  final DateTime sentAt;
  final String type;
  bool isRead;

  LocalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.sentAt,
    required this.type,
    required this.isRead,
  });

  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    return LocalNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      sentAt: DateTime.parse(map['sent_at']),
      type: map['type'],
      isRead: map['is_read'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
      'type': type,
      'is_read': isRead ? 1 : 0,
    };
  }
}
