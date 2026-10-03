import 'package:flutter/foundation.dart';

@immutable
class AiExerciseItem {
  final String name;
  final String targetMuscle;
  final String equipmentRequired;
  final int sets;
  final String reps;
  final int restSeconds;
  final String rationale;

  const AiExerciseItem({
    required this.name,
    required this.targetMuscle,
    required this.equipmentRequired,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    required this.rationale,
  });

  factory AiExerciseItem.fromJson(Map<String, dynamic> json) {
    return AiExerciseItem(
      name: json['name']?.toString() ?? '',
      targetMuscle: json['target_muscle']?.toString() ??
          json['targetMuscle']?.toString() ??
          '',
      equipmentRequired: json['equipment_required']?.toString() ??
          json['equipmentRequired']?.toString() ??
          '',
      sets: (json['sets'] as num?)?.toInt() ?? 0,
      reps: json['reps']?.toString() ?? '',
      restSeconds: (json['rest_seconds'] as num?)?.toInt() ??
          (json['restSeconds'] as num?)?.toInt() ??
          0,
      rationale: json['rationale']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'targetMuscle': targetMuscle,
      'equipmentRequired': equipmentRequired,
      'sets': sets,
      'reps': reps,
      'restSeconds': restSeconds,
      'rationale': rationale,
    };
  }

  AiExerciseItem copyWith({
    String? name,
    String? targetMuscle,
    String? equipmentRequired,
    int? sets,
    String? reps,
    int? restSeconds,
    String? rationale,
  }) {
    return AiExerciseItem(
      name: name ?? this.name,
      targetMuscle: targetMuscle ?? this.targetMuscle,
      equipmentRequired: equipmentRequired ?? this.equipmentRequired,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      rationale: rationale ?? this.rationale,
    );
  }
}

@immutable
class AiDayRoutine {
  final int dayNumber;
  final String dayTitle;
  final String focus;
  final int estimatedDurationMinutes;
  final List<AiExerciseItem> exercises;

  const AiDayRoutine({
    required this.dayNumber,
    required this.dayTitle,
    required this.focus,
    required this.estimatedDurationMinutes,
    required this.exercises,
  });

  factory AiDayRoutine.fromJson(Map<String, dynamic> json) {
    final exRaw = (json['exercises'] as List?) ?? [];
    return AiDayRoutine(
      dayNumber: (json['day_number'] as num?)?.toInt() ??
          (json['dayNumber'] as num?)?.toInt() ??
          1,
      dayTitle: json['day_title']?.toString() ??
          json['dayTitle']?.toString() ??
          'Day Routine',
      focus: json['focus']?.toString() ?? '',
      estimatedDurationMinutes:
          (json['estimated_duration_minutes'] as num?)?.toInt() ??
              (json['estimatedDurationMinutes'] as num?)?.toInt() ??
              0,
      exercises: List<AiExerciseItem>.unmodifiable(
        exRaw.map((e) => AiExerciseItem.fromJson(Map<String, dynamic>.from(e))),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'dayTitle': dayTitle,
      'focus': focus,
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  AiDayRoutine copyWith({
    int? dayNumber,
    String? dayTitle,
    String? focus,
    int? estimatedDurationMinutes,
    List<AiExerciseItem>? exercises,
  }) {
    return AiDayRoutine(
      dayNumber: dayNumber ?? this.dayNumber,
      dayTitle: dayTitle ?? this.dayTitle,
      focus: focus ?? this.focus,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      exercises: exercises != null
          ? List<AiExerciseItem>.unmodifiable(exercises)
          : this.exercises,
    );
  }
}

@immutable
class AiPlanModel {
  final String id;
  final String title;
  final String goal;
  final String experienceLevel;
  final int durationWeeks;
  final int daysPerWeek;
  final String summary;
  final List<AiDayRoutine> routines;

  const AiPlanModel({
    required this.id,
    required this.title,
    required this.goal,
    required this.experienceLevel,
    required this.durationWeeks,
    required this.daysPerWeek,
    required this.summary,
    required this.routines,
  });

  factory AiPlanModel.fromJson(Map<String, dynamic> json) {
    final rRaw = (json['routines'] as List?) ?? [];
    return AiPlanModel(
      id: json['id']?.toString() ?? json['plan_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'AI Workout Protocol',
      goal: json['goal']?.toString() ?? 'general_fitness',
      experienceLevel: json['experience_level']?.toString() ??
          json['experienceLevel']?.toString() ??
          'Intermediate',
      durationWeeks: (json['duration_weeks'] as num?)?.toInt() ??
          (json['durationWeeks'] as num?)?.toInt() ??
          4,
      daysPerWeek: (json['days_per_week'] as num?)?.toInt() ??
          (json['daysPerWeek'] as num?)?.toInt() ??
          3,
      summary: json['summary']?.toString() ?? '',
      routines: List<AiDayRoutine>.unmodifiable(
        rRaw.map((r) => AiDayRoutine.fromJson(Map<String, dynamic>.from(r))),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'goal': goal,
      'experienceLevel': experienceLevel,
      'durationWeeks': durationWeeks,
      'daysPerWeek': daysPerWeek,
      'summary': summary,
      'routines': routines.map((r) => r.toJson()).toList(),
    };
  }

  AiPlanModel copyWith({
    String? id,
    String? title,
    String? goal,
    String? experienceLevel,
    int? durationWeeks,
    int? daysPerWeek,
    String? summary,
    List<AiDayRoutine>? routines,
  }) {
    return AiPlanModel(
      id: id ?? this.id,
      title: title ?? this.title,
      goal: goal ?? this.goal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      durationWeeks: durationWeeks ?? this.durationWeeks,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      summary: summary ?? this.summary,
      routines: routines != null
          ? List<AiDayRoutine>.unmodifiable(routines)
          : this.routines,
    );
  }
}
