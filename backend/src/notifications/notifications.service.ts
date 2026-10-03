import { Injectable } from '@nestjs/common';

export interface NotificationItem {
  id: string;
  type: 'expert_reply' | 'alert' | 'confirmation';
  title: string;
  message: string;
  timestamp: string;
  isRead: boolean;
  metadata?: Record<string, any>;
}

@Injectable()
export class NotificationsService {
  private notifications: NotificationItem[] = [
    {
      id: 'notif_01',
      type: 'expert_reply',
      title: 'Coach Marcus Replied',
      message: 'Great tempo on your goblet squats! Focus on keeping your elbows tucked next set.',
      timestamp: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
      isRead: false,
      metadata: { coachId: 'c_marcus', workoutId: 'wk_today_01' },
    },
    {
      id: 'notif_02',
      type: 'alert',
      title: 'Hydration Target Warning',
      message: 'You have only logged 1.2L of water today. Aim for at least 2.5L to support recovery.',
      timestamp: new Date(Date.now() - 2 * 3600 * 1000).toISOString(),
      isRead: false,
    },
    {
      id: 'notif_03',
      type: 'confirmation',
      title: 'Challenge Milestone Confirmed',
      message: 'Day 12 of Spring 30-Day Lean Muscle Protocol successfully verified. +50 XP awarded!',
      timestamp: new Date(Date.now() - 5 * 3600 * 1000).toISOString(),
      isRead: true,
      metadata: { challengeId: 'ch_01' },
    },
    {
      id: 'notif_04',
      type: 'alert',
      title: 'Rest Day Recommended',
      message: 'Your muscle fatigue score is high after 3 consecutive strength sessions. Take active rest.',
      timestamp: new Date(Date.now() - 24 * 3600 * 1000).toISOString(),
      isRead: true,
    },
    {
      id: 'notif_05',
      type: 'confirmation',
      title: 'Meal Log Saved',
      message: 'Logged 67g protein from lunch. You are 72% toward your daily protein goal.',
      timestamp: new Date(Date.now() - 28 * 3600 * 1000).toISOString(),
      isRead: true,
    },
  ];

  findAll(userId: string): NotificationItem[] {
    return this.notifications;
  }

  markAsRead(id: string) {
    const item = this.notifications.find((n) => n.id === id);
    if (item) item.isRead = true;
    return { success: true };
  }
}
