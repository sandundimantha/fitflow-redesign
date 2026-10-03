class AiExerciseItem {
  final String name;
  final String targetMuscle;
  final String equipmentRequired;
  final int sets;
  final String reps;
  final int restSeconds;
  final String rationale;

  AiExerciseItem({
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
      name: json['name'] ?? '',
      targetMuscle: json['target_muscle'] ?? json['targetMuscle'] ?? 'General',
      equipmentRequired: json['equipment_required'] ?? json['equipmentRequired'] ?? 'bodyweight',
      sets: json['sets'] ?? 3,
      reps: json['reps']?.toString() ?? '10-12',
      restSeconds: json['rest_seconds'] ?? json['restSeconds'] ?? 60,
      rationale: json['rationale'] ?? 'Selected for balanced muscular development.',
    );
  }
}

class AiDayRoutine {
  final int dayNumber;
  final String dayTitle;
  final String focus;
  final int estimatedDurationMinutes;
  final List<AiExerciseItem> exercises;

  AiDayRoutine({
    required this.dayNumber,
    required this.dayTitle,
    required this.focus,
    required this.estimatedDurationMinutes,
    required this.exercises,
  });

  factory AiDayRoutine.fromJson(Map<String, dynamic> json) {
    final exRaw = (json['exercises'] as List?) ?? [];
    return AiDayRoutine(
      dayNumber: json['day_number'] ?? json['dayNumber'] ?? 1,
      dayTitle: json['day_title'] ?? json['dayTitle'] ?? 'Day Routine',
      focus: json['focus'] ?? 'Strength & Endurance',
      estimatedDurationMinutes: json['estimated_duration_minutes'] ?? json['estimatedDurationMinutes'] ?? 40,
      exercises: exRaw.map((e) => AiExerciseItem.fromJson(e)).toList(),
    );
  }
}

class AiPlanModel {
  final String id;
  final String title;
  final String goal;
  final String experienceLevel;
  final int durationWeeks;
  final int daysPerWeek;
  final String summary;
  final List<AiDayRoutine> routines;

  AiPlanModel({
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
      id: json['id'] ?? json['plan_id'] ?? '',
      title: json['title'] ?? 'AI Workout Protocol',
      goal: json['goal'] ?? 'muscle_gain',
      experienceLevel: json['experience_level'] ?? json['experienceLevel'] ?? 'Intermediate',
      durationWeeks: json['duration_weeks'] ?? json['durationWeeks'] ?? 4,
      daysPerWeek: json['days_per_week'] ?? json['daysPerWeek'] ?? 4,
      summary: json['summary'] ?? '',
      routines: rRaw.map((r) => AiDayRoutine.fromJson(r)).toList(),
    );
  }
}
