import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String appName = 'FitFlow';

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static String get websocketUrl {
    return baseUrl.replaceFirst('http', 'ws').replaceFirst('/api', '/ws/feed');
  }

  // Endpoints
  static const String authSync = '/auth/sync';
  static const String authMe = '/auth/me';

  static const String userProfile = '/users/profile';
  static const String privacyPolicy = '/users/privacy-policy';

  static const String todayWorkout = '/workouts/today';
  static const String workoutsList = '/workouts';
  static const String workoutLog = '/workouts/log';
  static const String workoutHistory = '/workouts/logs/history';
  static const String weeklyStats = '/workouts/stats/weekly-comparison';

  static const String nutritionAutocomplete = '/nutrition/autocomplete';
  static const String nutritionLog = '/nutrition/log';
  static const String nutritionTodaySummary = '/nutrition/today-summary';
  static const String nutritionTodayMeals = '/nutrition/logs/today';

  static const String aiGeneratePlan = '/ai-plans/generate';
  static const String aiMyPlans = '/ai-plans/my-plans';

  static const String socialFeed = '/social/feed';
  static const String socialPosts = '/social/posts';
  static const String socialChallenges = '/social/challenges';

  static const String notifications = '/notifications';

  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration aiServiceTimeout = Duration(seconds: 8);
}
