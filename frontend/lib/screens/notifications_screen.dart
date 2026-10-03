import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: notificationsAsync.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(child: Text('No new notifications.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, idx) => _buildNotificationCard(context, ref, notifications[idx]),
              ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('Error loading notifications: $e')),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, NotificationModel item) {
    final dateFormat = DateFormat('h:mm a • MMM d');

    // =========================================================================
    // REQUIREMENT: Visually distinguished by type (expert/system reply, alert, confirmation)
    // =========================================================================
    Color accentColor;
    String badgeText;
    IconData icon;

    switch (item.type) {
      case NotificationType.expertReply:
        accentColor = AppTheme.accent;
        badgeText = 'EXPERT REPLY';
        icon = Icons.support_agent_rounded;
        break;
      case NotificationType.alert:
        accentColor = AppTheme.amber;
        badgeText = 'ALERT';
        icon = Icons.warning_amber_rounded;
        break;
      case NotificationType.confirmation:
        accentColor = AppTheme.primary;
        badgeText = 'CONFIRMATION';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.isRead ? AppTheme.surface : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isRead ? AppTheme.surfaceBorder : accentColor.withOpacity(0.6),
          width: item.isRead ? 1 : 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(color: accentColor, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      dateFormat.format(item.timestamp),
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.message,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
                ),
                if (!item.isRead) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => ref.read(notificationsProvider.notifier).markRead(item.id),
                      child: const Text('Mark as Read', style: TextStyle(fontSize: 11, color: AppTheme.secondary)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
