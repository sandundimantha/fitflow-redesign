import 'package:flutter/foundation.dart';

@immutable
class FoodSuggestion {
  final String foodName;
  final String defaultServing;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  const FoodSuggestion({
    required this.foodName,
    required this.defaultServing,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  factory FoodSuggestion.fromJson(Map<String, dynamic> json) {
    return FoodSuggestion(
      foodName: json['foodName']?.toString() ?? '',
      defaultServing: json['defaultServing']?.toString() ?? '1 serving',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'defaultServing': defaultServing,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
    };
  }

  FoodSuggestion copyWith({
    String? foodName,
    String? defaultServing,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
  }) {
    return FoodSuggestion(
      foodName: foodName ?? this.foodName,
      defaultServing: defaultServing ?? this.defaultServing,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
    );
  }
}

@immutable
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

  const NutritionLogModel({
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
      id: json['id']?.toString() ?? '',
      mealType: json['mealType']?.toString() ?? 'snack',
      foodName: json['foodName']?.toString() ?? 'Food',
      servingAmount: (json['servingAmount'] as num?)?.toDouble() ?? 1.0,
      servingUnit: json['servingUnit']?.toString() ?? 'serving',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinGrams: (json['proteinGrams'] as num?)?.toDouble() ?? 0.0,
      carbsGrams: (json['carbsGrams'] as num?)?.toDouble() ?? 0.0,
      fatGrams: (json['fatGrams'] as num?)?.toDouble() ?? 0.0,
      loggedAt: json['loggedAt'] != null
          ? DateTime.tryParse(json['loggedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'foodName': foodName,
      'servingAmount': servingAmount,
      'servingUnit': servingUnit,
      'calories': calories,
      'proteinGrams': proteinGrams,
      'carbsGrams': carbsGrams,
      'fatGrams': fatGrams,
      'loggedAt': loggedAt.toIso8601String(),
    };
  }

  NutritionLogModel copyWith({
    String? id,
    String? mealType,
    String? foodName,
    double? servingAmount,
    String? servingUnit,
    int? calories,
    double? proteinGrams,
    double? carbsGrams,
    double? fatGrams,
    DateTime? loggedAt,
  }) {
    return NutritionLogModel(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      foodName: foodName ?? this.foodName,
      servingAmount: servingAmount ?? this.servingAmount,
      servingUnit: servingUnit ?? this.servingUnit,
      calories: calories ?? this.calories,
      proteinGrams: proteinGrams ?? this.proteinGrams,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      fatGrams: fatGrams ?? this.fatGrams,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }
}

@immutable
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

  const DayNutritionSummary({
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
      targetCalories: (json['targetCalories'] as num?)?.toInt() ?? 0,
      consumedCalories: (json['consumedCalories'] as num?)?.toInt() ?? 0,
      targetProteinGrams: (json['targetProteinGrams'] as num?)?.toInt() ?? 0,
      consumedProteinGrams:
          (json['consumedProteinGrams'] as num?)?.toInt() ?? 0,
      targetCarbsGrams: (json['targetCarbsGrams'] as num?)?.toInt() ?? 0,
      consumedCarbsGrams: (json['consumedCarbsGrams'] as num?)?.toInt() ?? 0,
      targetFatGrams: (json['targetFatGrams'] as num?)?.toInt() ?? 0,
      consumedFatGrams: (json['consumedFatGrams'] as num?)?.toInt() ?? 0,
      loggedMealsCount: (json['loggedMealsCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetCalories': targetCalories,
      'consumedCalories': consumedCalories,
      'targetProteinGrams': targetProteinGrams,
      'consumedProteinGrams': consumedProteinGrams,
      'targetCarbsGrams': targetCarbsGrams,
      'consumedCarbsGrams': consumedCarbsGrams,
      'targetFatGrams': targetFatGrams,
      'consumedFatGrams': consumedFatGrams,
      'loggedMealsCount': loggedMealsCount,
    };
  }

  DayNutritionSummary copyWith({
    int? targetCalories,
    int? consumedCalories,
    int? targetProteinGrams,
    int? consumedProteinGrams,
    int? targetCarbsGrams,
    int? consumedCarbsGrams,
    int? targetFatGrams,
    int? consumedFatGrams,
    int? loggedMealsCount,
  }) {
    return DayNutritionSummary(
      targetCalories: targetCalories ?? this.targetCalories,
      consumedCalories: consumedCalories ?? this.consumedCalories,
      targetProteinGrams: targetProteinGrams ?? this.targetProteinGrams,
      consumedProteinGrams:
          consumedProteinGrams ?? this.consumedProteinGrams,
      targetCarbsGrams: targetCarbsGrams ?? this.targetCarbsGrams,
      consumedCarbsGrams: consumedCarbsGrams ?? this.consumedCarbsGrams,
      targetFatGrams: targetFatGrams ?? this.targetFatGrams,
      consumedFatGrams: consumedFatGrams ?? this.consumedFatGrams,
      loggedMealsCount: loggedMealsCount ?? this.loggedMealsCount,
    );
  }
}
