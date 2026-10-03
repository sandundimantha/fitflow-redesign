import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/notification_model.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
}

class NotificationRepository implements INotificationRepository {
  final ApiClient _client;

  NotificationRepository(this._client);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _client.get(ApiConstants.notifications);
    final list = data as List;
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }

  @override
  Future<void> markAsRead(String id) async {
    await _client.patch('${ApiConstants.notifications}/$id/read', {});
  }
}
