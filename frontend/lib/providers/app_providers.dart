import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/nutrition_model.dart';
import '../models/ai_plan_model.dart';
import '../models/post_model.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// User & Auth State
class UserNotifier extends StateNotifier<UserModel?> {
  final ApiService _api;
  UserNotifier(this._api) : super(null) {
    loadUser();
  }

  Future<void> loadUser() async {
    final data = await _api.get('/users/profile');
    if (data != null) {
      state = UserModel.fromJson(data);
    } else {
      // Offline fallback user
      state = UserModel(
        id: 'usr_demo_777',
        firebaseUid: 'usr_demo_777',
        displayName: 'Alex Morgan',
        email: 'alex.morgan@fitflow.app',
        fitnessGoal: 'muscle_gain',
        experienceLevel: 'intermediate',
        weightKg: 74.5,
        heightCm: 178.0,
        language: 'en',
        totalWorkoutsCompleted: 14,
        currentStreakDays: 6,
      );
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
    final updated = await _api.patch('/users/profile', payload);
    if (updated != null) {
      state = UserModel.fromJson(updated);
    } else if (state != null) {
      state = UserModel(
        id: state!.id,
        firebaseUid: state!.firebaseUid,
        displayName: displayName ?? state!.displayName,
        email: state!.email,
        avatarUrl: state!.avatarUrl,
        fitnessGoal: fitnessGoal ?? state!.fitnessGoal,
        experienceLevel: experienceLevel ?? state!.experienceLevel,
        weightKg: weightKg ?? state!.weightKg,
        heightCm: heightCm ?? state!.heightCm,
        language: language ?? state!.language,
        totalWorkoutsCompleted: state!.totalWorkoutsCompleted,
        currentStreakDays: state!.currentStreakDays,
      );
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier(ref.watch(apiServiceProvider));
});

// Today Scheduled Workout
final todayWorkoutProvider = FutureProvider<WorkoutModel>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.get('/workouts/today');
  if (data != null) {
    return WorkoutModel.fromJson(data);
  }
  return WorkoutModel(
    id: 'wk_today_01',
    title: 'Functional Full-Body Hypertrophy',
    category: 'Strength',
    durationMinutes: 45,
    difficulty: 'Intermediate',
    caloriesBurnEstimate: 380,
    description: 'Target compound movement chains focusing on chest, upper back, and quads.',
    isScheduledToday: true,
    exercises: [
      ExerciseItem(name: 'Goblet Squats', sets: 4, reps: '10-12', rest: 90, target: 'Quads & Glutes'),
      ExerciseItem(name: 'Dumbbell Bench Press', sets: 4, reps: '8-10', rest: 90, target: 'Chest & Triceps'),
      ExerciseItem(name: 'Dumbbell Bent-Over Row', sets: 3, reps: '10-12', rest: 75, target: 'Upper Back'),
      ExerciseItem(name: 'Plank Shoulder Taps', sets: 3, reps: '45 sec', rest: 45, target: 'Core Anti-Rotation'),
    ],
  );
});

// Workouts Catalog
class WorkoutsListNotifier extends StateNotifier<AsyncValue<List<WorkoutModel>>> {
  final ApiService _api;
  String _selectedCategory = 'All';
  int? _maxDuration;

  WorkoutsListNotifier(this._api) : super(const AsyncValue.loading()) {
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
    String query = '';
    if (_selectedCategory != 'All') query += '?category=$_selectedCategory';
    if (_maxDuration != null) {
      query += query.isEmpty ? '?maxDuration=$_maxDuration' : '&maxDuration=$_maxDuration';
    }

    final data = await _api.get('/workouts$query');
    if (data != null && data is List) {
      state = AsyncValue.data(data.map((e) => WorkoutModel.fromJson(e)).toList());
    } else {
      // Fallback
      state = AsyncValue.data([
        WorkoutModel(
          id: 'wk_today_01',
          title: 'Functional Full-Body Hypertrophy',
          category: 'Strength',
          durationMinutes: 45,
          difficulty: 'Intermediate',
          caloriesBurnEstimate: 380,
          description: 'Target compound movement chains for balanced strength.',
          isScheduledToday: true,
          exercises: [],
        ),
        WorkoutModel(
          id: 'wk_hiit_02',
          title: 'Metabolic HIIT Blaze',
          category: 'HIIT',
          durationMinutes: 25,
          difficulty: 'Advanced',
          caloriesBurnEstimate: 320,
          description: 'High-intensity interval training.',
          isScheduledToday: false,
          exercises: [],
        ),
        WorkoutModel(
          id: 'wk_cardio_03',
          title: 'Zone 2 Aerobic Conditioning',
          category: 'Cardio',
          durationMinutes: 35,
          difficulty: 'Beginner',
          caloriesBurnEstimate: 260,
          description: 'Aerobic base building.',
          isScheduledToday: false,
          exercises: [],
        ),
        WorkoutModel(
          id: 'wk_mobility_04',
          title: 'Deep Hip & Thoracic Mobility',
          category: 'Mobility',
          durationMinutes: 20,
          difficulty: 'Beginner',
          caloriesBurnEstimate: 110,
          description: 'Relieve posture stiffness and improve movement.',
          isScheduledToday: false,
          exercises: [],
        ),
      ]);
    }
  }
}

final workoutsListProvider =
    StateNotifierProvider<WorkoutsListNotifier, AsyncValue<List<WorkoutModel>>>((ref) {
  return WorkoutsListNotifier(ref.watch(apiServiceProvider));
});

// Workout History & Editing
class WorkoutHistoryNotifier extends StateNotifier<AsyncValue<List<WorkoutLogModel>>> {
  final ApiService _api;
  WorkoutHistoryNotifier(this._api) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory({String? category, int? maxDuration}) async {
    state = const AsyncValue.loading();
    String query = '';
    if (category != null && category != 'All') query += '?category=$category';
    if (maxDuration != null) {
      query += query.isEmpty ? '?maxDuration=$maxDuration' : '&maxDuration=$maxDuration';
    }

    final data = await _api.get('/workouts/logs/history$query');
    if (data != null && data is List) {
      state = AsyncValue.data(data.map((e) => WorkoutLogModel.fromJson(e)).toList());
    } else {
      // Fallback past logs
      state = AsyncValue.data([
        WorkoutLogModel(
          id: 'log_1',
          workoutTitle: 'Functional Full-Body Hypertrophy',
          category: 'Strength',
          durationMinutes: 45,
          caloriesBurned: 380,
          perceivedExertion: 8,
          notes: 'Solid form on goblet squats',
          completedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        WorkoutLogModel(
          id: 'log_2',
          workoutTitle: 'Metabolic HIIT Blaze',
          category: 'HIIT',
          durationMinutes: 30,
          caloriesBurned: 340,
          perceivedExertion: 9,
          notes: 'High heart rate bursts',
          completedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        WorkoutLogModel(
          id: 'log_3',
          workoutTitle: 'Zone 2 Aerobic Conditioning',
          category: 'Cardio',
          durationMinutes: 40,
          caloriesBurned: 290,
          perceivedExertion: 6,
          notes: 'Easy recovery run',
          completedAt: DateTime.now().subtract(const Duration(days: 4)),
        ),
      ]);
    }
  }

  Future<bool> editLog(String logId, int newDurationMinutes, int newCalories, String? notes) async {
    final res = await _api.patch('/workouts/logs/$logId', {
      'durationMinutes': newDurationMinutes,
      'caloriesBurned': newCalories,
      'notes': notes,
    });

    state.whenData((logs) {
      state = AsyncValue.data(logs.map((l) {
        if (l.id == logId) {
          l.durationMinutes = newDurationMinutes;
          l.caloriesBurned = newCalories;
        }
        return l;
      }).toList());
    });
    return res != null;
  }

  Future<void> addLog(WorkoutLogModel newLog) async {
    await _api.post('/workouts/log', {
      'workoutId': newLog.workoutId,
      'workoutTitle': newLog.workoutTitle,
      'category': newLog.category,
      'durationMinutes': newLog.durationMinutes,
      'caloriesBurned': newLog.caloriesBurned,
      'perceivedExertion': newLog.perceivedExertion,
      'notes': newLog.notes,
    });
    await loadHistory();
  }
}

final workoutHistoryProvider =
    StateNotifierProvider<WorkoutHistoryNotifier, AsyncValue<List<WorkoutLogModel>>>((ref) {
  return WorkoutHistoryNotifier(ref.watch(apiServiceProvider));
});

// Weekly Progress Stats (This Week vs Last Week)
final weeklyStatsProvider = FutureProvider<WeeklyComparisonStats>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final data = await api.get('/workouts/stats/weekly-comparison');
  if (data != null) {
    return WeeklyComparisonStats.fromJson(data);
  }
  return WeeklyComparisonStats(
    thisWeekLabel: 'This Week',
    lastWeekLabel: 'Last Week',
    thisWeekTotalMinutes: 115,
    lastWeekTotalMinutes: 100,
    thisWeekTotalCalories: 1010,
    lastWeekTotalCalories: 840,
    thisWeekSessions: 3,
    lastWeekSessions: 3,
    durationChangePercent: 15,
    dailyBreakdown: [
      DailyComparisonPoint(day: 'Mon', thisWeekMinutes: 45, lastWeekMinutes: 40),
      DailyComparisonPoint(day: 'Tue', thisWeekMinutes: 0, lastWeekMinutes: 0),
      DailyComparisonPoint(day: 'Wed', thisWeekMinutes: 30, lastWeekMinutes: 25),
      DailyComparisonPoint(day: 'Thu', thisWeekMinutes: 0, lastWeekMinutes: 0),
      DailyComparisonPoint(day: 'Fri', thisWeekMinutes: 40, lastWeekMinutes: 35),
      DailyComparisonPoint(day: 'Sat', thisWeekMinutes: 0, lastWeekMinutes: 0),
      DailyComparisonPoint(day: 'Sun', thisWeekMinutes: 0, lastWeekMinutes: 0),
    ],
  );
});

// Nutrition Provider
class NutritionNotifier extends StateNotifier<AsyncValue<DayNutritionSummary>> {
  final ApiService _api;
  List<NutritionLogModel> _todayMeals = [];

  NutritionNotifier(this._api) : super(const AsyncValue.loading()) {
    loadTodayNutrition();
  }

  List<NutritionLogModel> get todayMeals => _todayMeals;

  Future<void> loadTodayNutrition() async {
    final summaryData = await _api.get('/nutrition/today-summary');
    final mealsData = await _api.get('/nutrition/logs/today');

    if (mealsData != null && mealsData is List) {
      _todayMeals = mealsData.map((e) => NutritionLogModel.fromJson(e)).toList();
    }

    if (summaryData != null) {
      state = AsyncValue.data(DayNutritionSummary.fromJson(summaryData));
    } else {
      state = AsyncValue.data(DayNutritionSummary(
        targetCalories: 2400,
        consumedCalories: 840,
        targetProteinGrams: 160,
        consumedProteinGrams: 76,
        targetCarbsGrams: 260,
        consumedCarbsGrams: 100,
        targetFatGrams: 70,
        consumedFatGrams: 13,
        loggedMealsCount: 2,
      ));
    }
  }

  Future<List<FoodSuggestion>> autocomplete(String query) async {
    final res = await _api.get('/nutrition/autocomplete?q=$query', useCache: false);
    if (res != null && res is List) {
      return res.map((e) => FoodSuggestion.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> logMeal(NutritionLogModel meal) async {
    await _api.post('/nutrition/log', {
      'mealType': meal.mealType,
      'foodName': meal.foodName,
      'servingAmount': meal.servingAmount,
      'servingUnit': meal.servingUnit,
      'calories': meal.calories,
      'proteinGrams': meal.proteinGrams,
      'carbsGrams': meal.carbsGrams,
      'fatGrams': meal.fatGrams,
    });
    await loadTodayNutrition();
  }
}

final nutritionProvider =
    StateNotifierProvider<NutritionNotifier, AsyncValue<DayNutritionSummary>>((ref) {
  return NutritionNotifier(ref.watch(apiServiceProvider));
});

// AI Plan Provider
class AiPlanNotifier extends StateNotifier<AsyncValue<AiPlanModel?>> {
  final ApiService _api;
  AiPlanNotifier(this._api) : super(const AsyncValue.data(null));

  Future<bool> generatePlan({
    required String goal,
    required List<String> availableEquipment,
    String experienceLevel = 'intermediate',
    int daysPerWeek = 4,
  }) async {
    state = const AsyncValue.loading();
    final res = await _api.post('/ai-plans/generate', {
      'goal': goal,
      'availableEquipment': availableEquipment,
      'experienceLevel': experienceLevel,
      'daysPerWeek': daysPerWeek,
    });

    if (res != null) {
      state = AsyncValue.data(AiPlanModel.fromJson(res));
      return true;
    } else {
      // Local demo fallback
      state = AsyncValue.data(AiPlanModel(
        id: 'plan_local_demo',
        title: 'AI Hypertrophy & Longevity Blueprint',
        goal: goal,
        experienceLevel: experienceLevel,
        durationWeeks: 4,
        daysPerWeek: daysPerWeek,
        summary: 'Targeted plan matching your equipment. Exercises calibrated to past volume.',
        routines: [
          AiDayRoutine(
            dayNumber: 1,
            dayTitle: 'Upper Body Force & Control',
            focus: 'Chest, Delts & Lats',
            estimatedDurationMinutes: 45,
            exercises: [
              AiExerciseItem(
                name: 'Dumbbell Bench Press',
                targetMuscle: 'Chest',
                equipmentRequired: 'dumbbells',
                sets: 4,
                reps: '8-10',
                restSeconds: 90,
                rationale: 'Primary compound horizontal press to overload pectorals using dumbbells.',
              ),
              AiExerciseItem(
                name: 'Dumbbell Bent-Over Row',
                targetMuscle: 'Upper Back',
                equipmentRequired: 'dumbbells',
                sets: 3,
                reps: '10-12',
                restSeconds: 75,
                rationale: 'Strengthens rhomboids and counters postural slump from desk sitting.',
              ),
            ],
          ),
        ],
      ));
      return true;
    }
  }
}

final aiPlanProvider =
    StateNotifierProvider<AiPlanNotifier, AsyncValue<AiPlanModel?>>((ref) {
  return AiPlanNotifier(ref.watch(apiServiceProvider));
});

// Social Community Provider
class SocialNotifier extends StateNotifier<AsyncValue<List<SocialPostModel>>> {
  final ApiService _api;
  List<ChallengeModel> _challenges = [];

  SocialNotifier(this._api) : super(const AsyncValue.loading()) {
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
    final res = await _api.get('/social/feed');
    if (res != null && res is List) {
      state = AsyncValue.data(res.map((e) => SocialPostModel.fromJson(e)).toList());
    } else {
      state = AsyncValue.data([
        SocialPostModel(
          id: 'post_01',
          userId: 'usr_sarah_11',
          authorName: 'Sarah Jenkins',
          authorAvatar: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
          content: 'Crushed Day 12 of the Spring Lean Muscle challenge! Hit a new 5-rep PR on Goblet Squats (28kg). The AI progressive plan is working 🔥💪',
          mediaUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
          challengeName: 'Spring 30-Day Lean Muscle Protocol',
          likesCount: 24,
          likedBy: ['usr_demo_777'],
          comments: [
            SocialCommentModel(
              id: 'c_1',
              userId: 'usr_mike_99',
              authorName: 'Mike Chen',
              text: 'Huge work Sarah! Form looked super clean!',
              createdAt: DateTime.now().subtract(const Duration(hours: 1)),
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ]);
    }
  }

  Future<void> loadChallenges() async {
    final res = await _api.get('/social/challenges');
    if (res != null && res is List) {
      _challenges = res.map((e) => ChallengeModel.fromJson(e)).toList();
    } else {
      _challenges = [
        ChallengeModel(
          id: 'ch_01',
          title: 'Spring 30-Day Lean Muscle Protocol',
          category: 'Hypertrophy',
          participantsCount: 1420,
          daysRemaining: 18,
          imageUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=600',
          description: 'Commit to 4 strength workouts per week, hitting 1.6g/kg protein daily.',
          isJoined: true,
        ),
        ChallengeModel(
          id: 'ch_02',
          title: '10,000 Daily Steps Consistency Quest',
          category: 'Endurance',
          participantsCount: 3840,
          daysRemaining: 12,
          imageUrl: 'https://images.unsplash.com/photo-1502680390469-be75c86b636f?w=600',
          description: 'Keep your active streak alive and log every step.',
          isJoined: false,
        ),
      ];
    }
  }

  Future<void> createPost(String content, {String? challengeId, String? challengeName}) async {
    await _api.post('/social/posts', {
      'content': content,
      'challengeId': challengeId,
      'challengeName': challengeName,
    });
    await loadFeed();
  }

  Future<void> toggleLike(String postId) async {
    await _api.post('/social/posts/$postId/like', {});
    state.whenData((posts) {
      state = AsyncValue.data(posts.map((p) {
        if (p.id == postId) {
          final isLiked = p.likedBy.contains('usr_demo_777');
          if (isLiked) {
            p.likedBy.remove('usr_demo_777');
            p.likesCount = (p.likesCount - 1).clamp(0, 9999);
          } else {
            p.likedBy.add('usr_demo_777');
            p.likesCount += 1;
          }
        }
        return p;
      }).toList());
    });
  }

  Future<void> addComment(String postId, String text) async {
    await _api.post('/social/posts/$postId/comments', {'text': text});
    await loadFeed();
  }

  Future<void> joinChallenge(String challengeId) async {
    await _api.post('/social/challenges/$challengeId/join', {});
    _challenges = _challenges.map((c) {
      if (c.id == challengeId) c.isJoined = true;
      return c;
    }).toList();
  }
}

final socialProvider =
    StateNotifierProvider<SocialNotifier, AsyncValue<List<SocialPostModel>>>((ref) {
  return SocialNotifier(ref.watch(apiServiceProvider));
});

// Notifications Provider
class NotificationsNotifier extends StateNotifier<List<NotificationModel>> {
  final ApiService _api;
  NotificationsNotifier(this._api) : super([]) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    final res = await _api.get('/notifications');
    if (res != null && res is List) {
      state = res.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      state = [
        NotificationModel(
          id: 'n_1',
          type: NotificationType.expertReply,
          title: 'Coach Marcus Replied',
          message: 'Great tempo on your goblet squats! Keep your elbows tucked next set.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        NotificationModel(
          id: 'n_2',
          type: NotificationType.alert,
          title: 'Hydration Target Warning',
          message: 'You have only logged 1.2L of water today. Aim for at least 2.5L.',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        NotificationModel(
          id: 'n_3',
          type: NotificationType.confirmation,
          title: 'Challenge Milestone Confirmed',
          message: 'Day 12 of Spring 30-Day Lean Muscle Protocol verified. +50 XP awarded!',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          isRead: true,
        ),
      ];
    }
  }

  Future<void> markRead(String id) async {
    await _api.patch('/notifications/$id/read', {});
    state = state.map((n) {
      if (n.id == id) n.isRead = true;
      return n;
    }).toList();
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationModel>>((ref) {
  return NotificationsNotifier(ref.watch(apiServiceProvider));
});
