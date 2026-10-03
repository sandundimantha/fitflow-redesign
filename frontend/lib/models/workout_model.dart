import 'dart:convert';

class ExerciseItem {
  final String name;
  final int sets;
  final String reps;
  final int rest;
  final String target;

  ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.target,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      name: json['name'] ?? '',
      sets: json['sets'] ?? 3,
      reps: json['reps']?.toString() ?? '10-12',
      rest: json['rest'] ?? 60,
      target: json['target'] ?? 'Full Body',
    );
  }
}

class WorkoutModel {
  final String id;
  final String title;
  final String category;
  final int durationMinutes;
  final String difficulty;
  final int caloriesBurnEstimate;
  final String? imageUrl;
  final String description;
  final bool isScheduledToday;
  final List<ExerciseItem> exercises;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.difficulty,
    required this.caloriesBurnEstimate,
    this.imageUrl,
    required this.description,
    this.isScheduledToday = false,
    required this.exercises,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    List<ExerciseItem> exList = [];
    if (json['exercisesJson'] != null) {
      try {
        final decoded = jsonDecode(json['exercisesJson']) as List;
        exList = decoded.map((e) => ExerciseItem.fromJson(e)).toList();
      } catch (e) {}
    } else if (json['exercises'] != null) {
      final list = json['exercises'] as List;
      exList = list.map((e) => ExerciseItem.fromJson(e)).toList();
    }

    return WorkoutModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'Strength',
      durationMinutes: json['durationMinutes'] ?? 30,
      difficulty: json['difficulty'] ?? 'Intermediate',
      caloriesBurnEstimate: json['caloriesBurnEstimate'] ?? 250,
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
      description: json['description'] ?? '',
      isScheduledToday: json['isScheduledToday'] ?? false,
      exercises: exList,
    );
  }
}

class WorkoutLogModel {
  final String id;
  final String? workoutId;
  final String workoutTitle;
  final String category;
  int durationMinutes;
  int caloriesBurned;
  final int? perceivedExertion;
  final String? notes;
  final DateTime completedAt;

  WorkoutLogModel({
    required this.id,
    this.workoutId,
    required this.workoutTitle,
    required this.category,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.perceivedExertion,
    this.notes,
    required this.completedAt,
  });

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) {
    return WorkoutLogModel(
      id: json['id'] ?? '',
      workoutId: json['workoutId'],
      workoutTitle: json['workoutTitle'] ?? 'Workout',
      category: json['category'] ?? 'General',
      durationMinutes: json['durationMinutes'] ?? 30,
      caloriesBurned: json['caloriesBurned'] ?? 200,
      perceivedExertion: json['perceivedExertion'],
      notes: json['notes'],
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : DateTime.now(),
    );
  }
}

class DailyComparisonPoint {
  final String day;
  final int thisWeekMinutes;
  final int lastWeekMinutes;

  DailyComparisonPoint({
    required this.day,
    required this.thisWeekMinutes,
    required this.lastWeekMinutes,
  });

  factory DailyComparisonPoint.fromJson(Map<String, dynamic> json) {
    return DailyComparisonPoint(
      day: json['day'] ?? '',
      thisWeekMinutes: json['thisWeekMinutes'] ?? 0,
      lastWeekMinutes: json['lastWeekMinutes'] ?? 0,
    );
  }
}

class WeeklyComparisonStats {
  final String thisWeekLabel;
  final String lastWeekLabel;
  final int thisWeekTotalMinutes;
  final int lastWeekTotalMinutes;
  final int thisWeekTotalCalories;
  final int lastWeekTotalCalories;
  final int thisWeekSessions;
  final int lastWeekSessions;
  final int durationChangePercent;
  final List<DailyComparisonPoint> dailyBreakdown;

  WeeklyComparisonStats({
    required this.thisWeekLabel,
    required this.lastWeekLabel,
    required this.thisWeekTotalMinutes,
    required this.lastWeekTotalMinutes,
    required this.thisWeekTotalCalories,
    required this.lastWeekTotalCalories,
    required this.thisWeekSessions,
    required this.lastWeekSessions,
    required this.durationChangePercent,
    required this.dailyBreakdown,
  });

  factory WeeklyComparisonStats.fromJson(Map<String, dynamic> json) {
    final legend = json['legend'] ?? {};
    final summary = json['summary'] ?? {};
    final rawList = (json['dailyBreakdown'] as List?) ?? [];

    return WeeklyComparisonStats(
      thisWeekLabel: legend['thisWeekLabel'] ?? 'This Week',
      lastWeekLabel: legend['lastWeekLabel'] ?? 'Last Week',
      thisWeekTotalMinutes: summary['thisWeekTotalMinutes'] ?? 115,
      lastWeekTotalMinutes: summary['lastWeekTotalMinutes'] ?? 100,
      thisWeekTotalCalories: summary['thisWeekTotalCalories'] ?? 1010,
      lastWeekTotalCalories: summary['lastWeekTotalCalories'] ?? 840,
      thisWeekSessions: summary['thisWeekSessions'] ?? 3,
      lastWeekSessions: summary['lastWeekSessions'] ?? 3,
      durationChangePercent: summary['durationChangePercent'] ?? 15,
      dailyBreakdown: rawList.map((e) => DailyComparisonPoint.fromJson(e)).toList(),
    );
  }
}
