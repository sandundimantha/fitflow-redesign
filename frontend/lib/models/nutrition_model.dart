class FoodSuggestion {
  final String foodName;
  final String defaultServing;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  FoodSuggestion({
    required this.foodName,
    required this.defaultServing,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  factory FoodSuggestion.fromJson(Map<String, dynamic> json) {
    return FoodSuggestion(
      foodName: json['foodName'] ?? '',
      defaultServing: json['defaultServing'] ?? '1 serving',
      calories: json['calories'] ?? 100,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class NutritionLogModel {
  final String id;
  final String mealType;
  final String foodName;
  final double servingAmount;
  final String servingUnit;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final DateTime loggedAt;

  NutritionLogModel({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.servingAmount,
    required this.servingUnit,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.loggedAt,
  });

  factory NutritionLogModel.fromJson(Map<String, dynamic> json) {
    return NutritionLogModel(
      id: json['id'] ?? '',
      mealType: json['mealType'] ?? 'snack',
      foodName: json['foodName'] ?? 'Food',
      servingAmount: (json['servingAmount'] as num?)?.toDouble() ?? 1.0,
      servingUnit: json['servingUnit'] ?? 'serving',
      calories: json['calories'] ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
      loggedAt: json['loggedAt'] != null ? DateTime.parse(json['loggedAt']) : DateTime.now(),
    );
  }
}

class DayNutritionSummary {
  final int targetCalories;
  final int consumedCalories;
  final int targetProteinGrams;
  final int consumedProteinGrams;
  final int targetCarbsGrams;
  final int consumedCarbsGrams;
  final int targetFatGrams;
  final int consumedFatGrams;
  final int loggedMealsCount;

  DayNutritionSummary({
    required this.targetCalories,
    required this.consumedCalories,
    required this.targetProteinGrams,
    required this.consumedProteinGrams,
    required this.targetCarbsGrams,
    required this.consumedCarbsGrams,
    required this.targetFatGrams,
    required this.consumedFatGrams,
    required this.loggedMealsCount,
  });

  factory DayNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DayNutritionSummary(
      targetCalories: json['targetCalories'] ?? 2400,
      consumedCalories: json['consumedCalories'] ?? 840,
      targetProteinGrams: json['targetProteinGrams'] ?? 160,
      consumedProteinGrams: json['consumedProteinGrams'] ?? 76,
      targetCarbsGrams: json['targetCarbsGrams'] ?? 260,
      consumedCarbsGrams: json['consumedCarbsGrams'] ?? 100,
      targetFatGrams: json['targetFatGrams'] ?? 70,
      consumedFatGrams: json['consumedFatGrams'] ?? 13,
      loggedMealsCount: json['loggedMealsCount'] ?? 2,
    );
  }
}
