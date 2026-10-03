import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class ExerciseItem {
  final String name;
  final int sets;
  final String reps;
  final int rest;
  final String target;

  const ExerciseItem({
    required this.name,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.target,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      name: json['name']?.toString() ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      reps: json['reps']?.toString() ?? '',
      rest: (json['rest'] as num?)?.toInt() ?? 0,
      target: json['target']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'rest': rest,
      'target': target,
    };
  }

  ExerciseItem copyWith({
    String? name,
    int? sets,
    String? reps,
    int? rest,
    String? target,
  }) {
    return ExerciseItem(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      rest: rest ?? this.rest,
      target: target ?? this.target,
    );
  }
}

@immutable
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

  const WorkoutModel({
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
        final decoded = jsonDecode(json['exercisesJson'].toString()) as List;
        exList = decoded
            .map((e) => ExerciseItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (_) {}
    } else if (json['exercises'] != null && json['exercises'] is List) {
      final list = json['exercises'] as List;
      exList = list
          .map((e) => ExerciseItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return WorkoutModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'All Levels',
      caloriesBurnEstimate:
          (json['caloriesBurnEstimate'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      description: json['description']?.toString() ?? '',
      isScheduledToday: json['isScheduledToday'] == true,
      exercises: List<ExerciseItem>.unmodifiable(exList),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'durationMinutes': durationMinutes,
      'difficulty': difficulty,
      'caloriesBurnEstimate': caloriesBurnEstimate,
      'imageUrl': imageUrl,
      'description': description,
      'isScheduledToday': isScheduledToday,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  WorkoutModel copyWith({
    String? id,
    String? title,
    String? category,
    int? durationMinutes,
    String? difficulty,
    int? caloriesBurnEstimate,
    String? imageUrl,
    String? description,
    bool? isScheduledToday,
    List<ExerciseItem>? exercises,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      difficulty: difficulty ?? this.difficulty,
      caloriesBurnEstimate: caloriesBurnEstimate ?? this.caloriesBurnEstimate,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isScheduledToday: isScheduledToday ?? this.isScheduledToday,
      exercises: exercises != null
          ? List<ExerciseItem>.unmodifiable(exercises)
          : this.exercises,
    );
  }
}

@immutable
class WorkoutLogModel {
  final String id;
  final String? workoutId;
  final String workoutTitle;
  final String category;
  final int durationMinutes;
  final int caloriesBurned;
  final int? perceivedExertion;
  final String? notes;
  final DateTime completedAt;

  const WorkoutLogModel({
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
      id: json['id']?.toString() ?? '',
      workoutId: json['workoutId']?.toString(),
      workoutTitle: json['workoutTitle']?.toString() ?? 'Workout',
      category: json['category']?.toString() ?? 'General',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 0,
      caloriesBurned: (json['caloriesBurned'] as num?)?.toInt() ?? 0,
      perceivedExertion: (json['perceivedExertion'] as num?)?.toInt(),
      notes: json['notes']?.toString(),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'category': category,
      'durationMinutes': durationMinutes,
      'caloriesBurned': caloriesBurned,
      'perceivedExertion': perceivedExertion,
      'notes': notes,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  WorkoutLogModel copyWith({
    String? id,
    String? workoutId,
    String? workoutTitle,
    String? category,
    int? durationMinutes,
    int? caloriesBurned,
    int? perceivedExertion,
    String? notes,
    DateTime? completedAt,
  }) {
    return WorkoutLogModel(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      category: category ?? this.category,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      perceivedExertion: perceivedExertion ?? this.perceivedExertion,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

@immutable
class DailyComparisonPoint {
  final String day;
  final int thisWeekMinutes;
  final int lastWeekMinutes;

  const DailyComparisonPoint({
    required this.day,
    required this.thisWeekMinutes,
    required this.lastWeekMinutes,
  });

  factory DailyComparisonPoint.fromJson(Map<String, dynamic> json) {
    return DailyComparisonPoint(
      day: json['day']?.toString() ?? '',
      thisWeekMinutes: (json['thisWeekMinutes'] as num?)?.toInt() ?? 0,
      lastWeekMinutes: (json['lastWeekMinutes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'thisWeekMinutes': thisWeekMinutes,
      'lastWeekMinutes': lastWeekMinutes,
    };
  }
}

@immutable
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

  const WeeklyComparisonStats({
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
    final legend = (json['legend'] as Map<String, dynamic>?) ?? {};
    final summary = (json['summary'] as Map<String, dynamic>?) ?? {};
    final rawList = (json['dailyBreakdown'] as List?) ?? [];

    return WeeklyComparisonStats(
      thisWeekLabel: legend['thisWeekLabel']?.toString() ?? 'This Week',
      lastWeekLabel: legend['lastWeekLabel']?.toString() ?? 'Last Week',
      thisWeekTotalMinutes:
          (summary['thisWeekTotalMinutes'] as num?)?.toInt() ?? 0,
      lastWeekTotalMinutes:
          (summary['lastWeekTotalMinutes'] as num?)?.toInt() ?? 0,
      thisWeekTotalCalories:
          (summary['thisWeekTotalCalories'] as num?)?.toInt() ?? 0,
      lastWeekTotalCalories:
          (summary['lastWeekTotalCalories'] as num?)?.toInt() ?? 0,
      thisWeekSessions: (summary['thisWeekSessions'] as num?)?.toInt() ?? 0,
      lastWeekSessions: (summary['lastWeekSessions'] as num?)?.toInt() ?? 0,
      durationChangePercent:
          (summary['durationChangePercent'] as num?)?.toInt() ?? 0,
      dailyBreakdown: List<DailyComparisonPoint>.unmodifiable(
        rawList.map((e) =>
            DailyComparisonPoint.fromJson(Map<String, dynamic>.from(e))),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'legend': {
        'thisWeekLabel': thisWeekLabel,
        'lastWeekLabel': lastWeekLabel,
      },
      'summary': {
        'thisWeekTotalMinutes': thisWeekTotalMinutes,
        'lastWeekTotalMinutes': lastWeekTotalMinutes,
        'thisWeekTotalCalories': thisWeekTotalCalories,
        'lastWeekTotalCalories': lastWeekTotalCalories,
        'thisWeekSessions': thisWeekSessions,
        'lastWeekSessions': lastWeekSessions,
        'durationChangePercent': durationChangePercent,
      },
      'dailyBreakdown': dailyBreakdown.map((e) => e.toJson()).toList(),
    };
  }
}
