import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/ai_plan_model.dart';

abstract class IAiPlanRepository {
  Future<AiPlanModel> generatePlan({
    required String goal,
    required List<String> availableEquipment,
    String experienceLevel,
    int daysPerWeek,
  });
  Future<List<AiPlanModel>> getMyPlans();
}

class AiPlanRepository implements IAiPlanRepository {
  final ApiClient _client;

  AiPlanRepository(this._client);

  @override
  Future<AiPlanModel> generatePlan({
    required String goal,
    required List<String> availableEquipment,
    String experienceLevel = 'intermediate',
    int daysPerWeek = 4,
  }) async {
    final data = await _client.post(
      ApiConstants.aiGeneratePlan,
      {
        'goal': goal,
        'availableEquipment': availableEquipment,
        'experienceLevel': experienceLevel,
        'daysPerWeek': daysPerWeek,
      },
      timeout: ApiConstants.aiServiceTimeout,
    );
    return AiPlanModel.fromJson(data);
  }

  @override
  Future<List<AiPlanModel>> getMyPlans() async {
    final data = await _client.get(ApiConstants.aiMyPlans);
    final list = data as List;
    return list.map((e) => AiPlanModel.fromJson(e)).toList();
  }
}
