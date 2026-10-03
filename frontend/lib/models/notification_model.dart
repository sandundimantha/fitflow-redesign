enum NotificationType { expertReply, alert, confirmation }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    NotificationType nType = NotificationType.confirmation;
    final rawType = json['type']?.toString().toLowerCase() ?? '';
    if (rawType.contains('expert')) {
      nType = NotificationType.expertReply;
    } else if (rawType.contains('alert')) {
      nType = NotificationType.alert;
    }

    return NotificationModel(
      id: json['id'] ?? '',
      type: nType,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }
}
