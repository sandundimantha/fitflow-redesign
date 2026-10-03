import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/workout_model.dart';

abstract class IWorkoutRepository {
  Future<WorkoutModel> getTodayWorkout();
  Future<List<WorkoutModel>> getWorkouts({String? category, int? maxDuration, String? difficulty});
  Future<List<WorkoutLogModel>> getHistory({String? category, int? maxDuration});
  Future<WorkoutLogModel> logWorkout(WorkoutLogModel log);
  Future<WorkoutLogModel> updateLog(String logId, int newDurationMinutes, int newCalories, String? notes);
  Future<WeeklyComparisonStats> getWeeklyComparison();
}

class WorkoutRepository implements IWorkoutRepository {
  final ApiClient _client;

  WorkoutRepository(this._client);

  @override
  Future<WorkoutModel> getTodayWorkout() async {
    final data = await _client.get(ApiConstants.todayWorkout);
    return WorkoutModel.fromJson(data);
  }

  @override
  Future<List<WorkoutModel>> getWorkouts({String? category, int? maxDuration, String? difficulty}) async {
    String query = '';
    if (category != null && category != 'All') query += '?category=$category';
    if (maxDuration != null) {
      query += query.isEmpty ? '?maxDuration=$maxDuration' : '&maxDuration=$maxDuration';
    }
    if (difficulty != null) {
      query += query.isEmpty ? '?difficulty=$difficulty' : '&difficulty=$difficulty';
    }

    final data = await _client.get('${ApiConstants.workoutsList}$query');
    final list = data as List;
    return list.map((e) => WorkoutModel.fromJson(e)).toList();
  }

  @override
  Future<List<WorkoutLogModel>> getHistory({String? category, int? maxDuration}) async {
    String query = '';
    if (category != null && category != 'All') query += '?category=$category';
    if (maxDuration != null) {
      query += query.isEmpty ? '?maxDuration=$maxDuration' : '&maxDuration=$maxDuration';
    }

    final data = await _client.get('${ApiConstants.workoutHistory}$query');
    final list = data as List;
    return list.map((e) => WorkoutLogModel.fromJson(e)).toList();
  }

  @override
  Future<WorkoutLogModel> logWorkout(WorkoutLogModel log) async {
    final data = await _client.post(ApiConstants.workoutLog, {
      'workoutId': log.workoutId,
      'workoutTitle': log.workoutTitle,
      'category': log.category,
      'durationMinutes': log.durationMinutes,
      'caloriesBurned': log.caloriesBurned,
      'perceivedExertion': log.perceivedExertion,
      'notes': log.notes,
    });
    return WorkoutLogModel.fromJson(data);
  }

  @override
  Future<WorkoutLogModel> updateLog(String logId, int newDurationMinutes, int newCalories, String? notes) async {
    final data = await _client.patch('${ApiConstants.workoutHistory.replaceFirst('/history', '')}/$logId', {
      'durationMinutes': newDurationMinutes,
      'caloriesBurned': newCalories,
      'notes': notes,
    });
    return WorkoutLogModel.fromJson(data);
  }

  @override
  Future<WeeklyComparisonStats> getWeeklyComparison() async {
    final data = await _client.get(ApiConstants.weeklyStats);
    return WeeklyComparisonStats.fromJson(data);
  }
}
