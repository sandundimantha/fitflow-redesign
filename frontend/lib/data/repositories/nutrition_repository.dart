import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/nutrition_model.dart';

abstract class INutritionRepository {
  Future<List<FoodSuggestion>> autocomplete(String query);
  Future<NutritionLogModel> logMeal(NutritionLogModel meal);
  Future<DayNutritionSummary> getTodaySummary();
  Future<List<NutritionLogModel>> getTodayMeals();
}

class NutritionRepository implements INutritionRepository {
  final ApiClient _client;

  NutritionRepository(this._client);

  @override
  Future<List<FoodSuggestion>> autocomplete(String query) async {
    final data = await _client.get(
      '${ApiConstants.nutritionAutocomplete}?q=$query',
      useCache: false,
    );
    final list = data as List;
    return list.map((e) => FoodSuggestion.fromJson(e)).toList();
  }

  @override
  Future<NutritionLogModel> logMeal(NutritionLogModel meal) async {
    final data = await _client.post(ApiConstants.nutritionLog, {
      'mealType': meal.mealType,
      'foodName': meal.foodName,
      'servingAmount': meal.servingAmount,
      'servingUnit': meal.servingUnit,
      'calories': meal.calories,
      'proteinGrams': meal.proteinGrams,
      'carbsGrams': meal.carbsGrams,
      'fatGrams': meal.fatGrams,
    });
    return NutritionLogModel.fromJson(data);
  }

  @override
  Future<DayNutritionSummary> getTodaySummary() async {
    final data = await _client.get(ApiConstants.nutritionTodaySummary);
    return DayNutritionSummary.fromJson(data);
  }

  @override
  Future<List<NutritionLogModel>> getTodayMeals() async {
    final data = await _client.get(ApiConstants.nutritionTodayMeals);
    final list = data as List;
    return list.map((e) => NutritionLogModel.fromJson(e)).toList();
  }
}
