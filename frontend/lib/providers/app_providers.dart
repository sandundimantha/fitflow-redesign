import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/api_client.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../data/repositories/nutrition_repository.dart';
import '../data/repositories/ai_plan_repository.dart';
import '../data/repositories/social_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/nutrition_model.dart';
import '../models/ai_plan_model.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';
import '../services/socket_service.dart';

// Dependency Injection: Client & Repositories
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(ref.watch(apiClientProvider));
});

final workoutRepositoryProvider = Provider<IWorkoutRepository>((ref) {
  return WorkoutRepository(ref.watch(apiClientProvider));
});

final nutritionRepositoryProvider = Provider<INutritionRepository>((ref) {
  return NutritionRepository(ref.watch(apiClientProvider));
});

final aiPlanRepositoryProvider = Provider<IAiPlanRepository>((ref) {
  return AiPlanRepository(ref.watch(apiClientProvider));
});

final socialRepositoryProvider = Provider<ISocialRepository>((ref) {
  return SocialRepository(ref.watch(apiClientProvider));
});

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  return NotificationRepository(ref.watch(apiClientProvider));
});

// User State Notifier
class UserNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final IAuthRepository _repo;

  UserNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<void> loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _repo.getProfile();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? fitnessGoal,
    String? experienceLevel,
    double? weightKg,
    double? heightCm,
    String? language,
  }) async {
    final payload = {
      if (displayName != null) 'displayName': displayName,
      if (fitnessGoal != null) 'fitnessGoal': fitnessGoal,
      if (experienceLevel != null) 'experienceLevel': experienceLevel,
      if (weightKg != null) 'weightKg': weightKg,
      if (heightCm != null) 'heightCm': heightCm,
      if (language != null) 'language': language,
    };
    try {
      final updated = await _repo.updateProfile(payload);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<UserModel?>>((ref) {
  return UserNotifier(ref.watch(authRepositoryProvider));
});

// Today Scheduled Workout Provider (Priority 1 Above the Fold)
final todayWorkoutProvider = FutureProvider<WorkoutModel>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return await repo.getTodayWorkout();
});

// Workouts Catalog Notifier
class WorkoutsListNotifier extends StateNotifier<AsyncValue<List<WorkoutModel>>> {
  final IWorkoutRepository _repo;
  String _selectedCategory = 'All';
  int? _maxDuration;

  WorkoutsListNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadWorkouts();
  }

  String get selectedCategory => _selectedCategory;
  int? get maxDuration => _maxDuration;

  Future<void> filter({String? category, int? maxDuration}) async {
    if (category != null) _selectedCategory = category;
    _maxDuration = maxDuration;
    await loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    state = const AsyncValue.loading();
    try {
      final workouts = await _repo.getWorkouts(
        category: _selectedCategory,
        maxDuration: _maxDuration,
      );
      state = AsyncValue.data(workouts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final workoutsListProvider =
    StateNotifierProvider<WorkoutsListNotifier, AsyncValue<List<WorkoutModel>>>((ref) {
  return WorkoutsListNotifier(ref.watch(workoutRepositoryProvider));
});

// Workout History Notifier
class WorkoutHistoryNotifier extends StateNotifier<AsyncValue<List<WorkoutLogModel>>> {
  final IWorkoutRepository _repo;

  WorkoutHistoryNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory({String? category, int? maxDuration}) async {
    state = const AsyncValue.loading();
    try {
      final history = await _repo.getHistory(category: category, maxDuration: maxDuration);
      state = AsyncValue.data(history);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> editLog(String logId, int newDurationMinutes, int newCalories, String? notes) async {
    try {
      final updated = await _repo.updateLog(logId, newDurationMinutes, newCalories, notes);
      state.whenData((logs) {
        state = AsyncValue.data(logs.map((l) => l.id == logId ? updated : l).toList());
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> addLog(WorkoutLogModel newLog) async {
    try {
      await _repo.logWorkout(newLog);
      await loadHistory();
    } catch (e) {}
  }
}

final workoutHistoryProvider =
    StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<WorkoutLogModel>>>((ref) {
  return WorkoutHistoryNotifier(ref.watch(workoutRepositoryProvider));
});

// Weekly Progress Stats Provider
final weeklyStatsProvider = FutureProvider<WeeklyComparisonStats>((ref) async {
  final repo = ref.watch(workoutRepositoryProvider);
  return await repo.getWeeklyComparison();
});

// Nutrition Notifier
class NutritionNotifier extends StateNotifier<AsyncValue<DayNutritionSummary>> {
  final INutritionRepository _repo;
  List<NutritionLogModel> _todayMeals = [];

  NutritionNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadTodayNutrition();
  }

  List<NutritionLogModel> get todayMeals => _todayMeals;

  Future<void> loadTodayNutrition() async {
    try {
      _todayMeals = await _repo.getTodayMeals();
      final summary = await _repo.getTodaySummary();
      state = AsyncValue.data(summary);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<List<FoodSuggestion>> autocomplete(String query) async {
    try {
      return await _repo.autocomplete(query);
    } catch (e) {
      return [];
    }
  }

  Future<void> logMeal(NutritionLogModel meal) async {
    try {
      await _repo.logMeal(meal);
      await loadTodayNutrition();
    } catch (e) {}
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, AsyncValue<DayNutritionSummary>>((ref) {
  return NutritionNotifier(ref.watch(nutritionRepositoryProvider));
});

// AI Plan Notifier
class AiPlanNotifier extends StateNotifier<AsyncValue<AiPlanModel?>> {
  final IAiPlanRepository _repo;

  AiPlanNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<bool> generatePlan({
    required String goal,
    required List<String> availableEquipment,
    String experienceLevel = 'intermediate',
    int daysPerWeek = 4,
  }) async {
    state = const AsyncValue.loading();
    try {
      final plan = await _repo.generatePlan(
        goal: goal,
        availableEquipment: availableEquipment,
        experienceLevel: experienceLevel,
        daysPerWeek: daysPerWeek,
      );
      state = AsyncValue.data(plan);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final aiPlanProvider =
    StateNotifierProvider<AiPlanNotifier, AsyncValue<AiPlanModel?>>((ref) {
  return AiPlanNotifier(ref.watch(aiPlanRepositoryProvider));
});

// Social Notifier
class SocialNotifier extends StateNotifier<AsyncValue<List<SocialPostModel>>> {
  final ISocialRepository _repo;
  final String? _currentUserId;
  List<ChallengeModel> _challenges = [];

  SocialNotifier(this._repo, {String? currentUserId})
      : _currentUserId = currentUserId,
        super(const AsyncValue.loading()) {
    loadFeed();
    loadChallenges();
    _listenSocket();
  }

  List<ChallengeModel> get challenges => _challenges;

  void _listenSocket() {
    SocketService().feedStream.listen((event) {
      if (event['type'] == 'NEW_POST' && event['data'] != null) {
        final newPost = SocialPostModel.fromJson(event['data']);
        state.whenData((posts) {
          state = AsyncValue.data([newPost, ...posts]);
        });
      }
    });
  }

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repo.getFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadChallenges() async {
    try {
      _challenges = await _repo.getChallenges();
    } catch (e) {}
  }

  Future<void> createPost(String content, {String? challengeId, String? challengeName}) async {
    try {
      await _repo.createPost(content, challengeId: challengeId, challengeName: challengeName);
      await loadFeed();
    } catch (e) {}
  }

  Future<void> toggleLike(String postId, {String? userId}) async {
    final activeUser = userId ?? _currentUserId ?? '';
    try {
      await _repo.toggleLike(postId);
      state.whenData((posts) {
        state = AsyncValue.data(posts.map((p) {
          if (p.id == postId) {
            final isLiked = p.isLikedBy(activeUser);
            final updatedLikedBy = List<String>.from(p.likedBy);
            final int newCount;
            if (isLiked) {
              updatedLikedBy.remove(activeUser);
              newCount = (p.likesCount - 1).clamp(0, 999999);
            } else {
              if (activeUser.isNotEmpty) updatedLikedBy.add(activeUser);
              newCount = p.likesCount + 1;
            }
            return p.copyWith(
              likesCount: newCount,
              likedBy: updatedLikedBy,
            );
          }
          return p;
        }).toList());
      });
    } catch (e) {}
  }

  Future<void> addComment(String postId, String text) async {
    try {
      await _repo.addComment(postId, text);
      await loadFeed();
    } catch (e) {}
  }

  Future<void> joinChallenge(String challengeId) async {
    try {
      await _repo.joinChallenge(challengeId);
      _challenges = _challenges.map((c) {
        if (c.id == challengeId) {
          return c.copyWith(
            isJoined: true,
            participantsCount: c.participantsCount + 1,
          );
        }
        return c;
      }).toList();
    } catch (e) {}
  }
}

final socialProvider =
    StateNotifierProvider<SocialNotifier, AsyncValue<List<SocialPostModel>>>((ref) {
  final repo = ref.watch(socialRepositoryProvider);
  final user = ref.watch(userProvider).value;
  return SocialNotifier(repo, currentUserId: user?.id);
});

// Notifications Notifier
class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final INotificationRepository _repo;

  NotificationsNotifier(this._repo) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifs = await _repo.getNotifications();
      state = AsyncValue.data(notifs);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _repo.markAsRead(id);
      state.whenData((notifs) {
        state = AsyncValue.data(
            notifs.map((n) => n.id == id ? n.copyWith(isRead: true) : n).toList());
      });
    } catch (e) {}
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  return NotificationsNotifier(ref.watch(notificationRepositoryProvider));
});
