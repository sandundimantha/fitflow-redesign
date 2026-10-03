import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/nutrition_model.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  final foodController = TextEditingController();
  final servingController = TextEditingController(text: '1.0');
  final caloriesController = TextEditingController(text: '300');
  final proteinController = TextEditingController(text: '25.0');
  final carbsController = TextEditingController(text: '30.0');
  final fatController = TextEditingController(text: '8.0');

  String selectedMealType = 'lunch';
  String servingUnit = 'portion';
  List<FoodSuggestion> suggestions = [];
  bool isSearching = false;

  void _onFoodQueryChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => suggestions = []);
      return;
    }
    setState(() => isSearching = true);
    final results = await ref.read(nutritionProvider.notifier).autocomplete(query);
    if (mounted) {
      setState(() {
        suggestions = results;
        isSearching = false;
      });
    }
  }

  void _selectSuggestion(FoodSuggestion s) {
    setState(() {
      foodController.text = s.foodName;
      caloriesController.text = s.calories.toString();
      proteinController.text = s.proteinGrams.toString();
      carbsController.text = s.carbsGrams.toString();
      fatController.text = s.fatGrams.toString();
      servingUnit = s.defaultServing;
      suggestions = [];
    });
  }

  void _logMeal() async {
    if (foodController.text.trim().isEmpty) return;

    final newMeal = NutritionLogModel(
      id: 'nut_${DateTime.now().millisecondsSinceEpoch}',
      mealType: selectedMealType,
      foodName: foodController.text.trim(),
      servingAmount: double.tryParse(servingController.text) ?? 1.0,
      servingUnit: servingUnit,
      calories: int.tryParse(caloriesController.text) ?? 250,
      proteinGrams: double.tryParse(proteinController.text) ?? 20.0,
      carbsGrams: double.tryParse(carbsController.text) ?? 25.0,
      fatGrams: double.tryParse(fatController.text) ?? 5.0,
      loggedAt: DateTime.now(),
    );

    await ref.read(nutritionProvider.notifier).logMeal(newMeal);
    foodController.clear();
    setState(() => suggestions = []);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text('Meal logged and Redis macro totals updated!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionAsync = ref.watch(nutritionProvider);
    final todayMeals = ref.watch(nutritionProvider.notifier).todayMeals;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Macro Progress Banner
            nutritionAsync.when(
              data: (summary) => _buildMacroSummary(summary),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // =========================================================================
            // REQUIREMENT: Food-Name Autocomplete (suggest matches while typing)
            // =========================================================================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOG A MEAL (AUTOCOMPLETE ENABLED)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meal Type Selector
                  DropdownButtonFormField<String>(
                    value: selectedMealType,
                    decoration: const InputDecoration(labelText: 'Meal Category'),
                    items: const [
                      DropdownMenuItem(value: 'breakfast', child: Text('Breakfast 🍳')),
                      DropdownMenuItem(value: 'lunch', child: Text('Lunch 🥗')),
                      DropdownMenuItem(value: 'dinner', child: Text('Dinner 🥩')),
                      DropdownMenuItem(value: 'snack', child: Text('Snack / Shake 🍌')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedMealType = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  // Autocomplete Search Input
                  TextField(
                    controller: foodController,
                    onChanged: _onFoodQueryChanged,
                    decoration: InputDecoration(
                      labelText: 'Food Name (Type e.g. "Chicken", "Oats", "Salmon")',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.secondary),
                      suffixIcon: isSearching
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.secondary)),
                            )
                          : null,
                    ),
                  ),

                  // Suggestions Dropdown List
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.secondary.withOpacity(0.5)),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: suggestions.length,
                        separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 1),
                        itemBuilder: (ctx, i) {
                          final s = suggestions[i];
                          return ListTile(
                            dense: true,
                            title: Text(s.foodName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(
                              '${s.calories} kcal • P: ${s.proteinGrams}g | C: ${s.carbsGrams}g | F: ${s.fatGrams}g (${s.defaultServing})',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                            ),
                            trailing: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.secondary, size: 20),
                            onTap: () => _selectSuggestion(s),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Macro breakdown inputs
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: proteinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Protein (g)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: carbsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Carbs (g)'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: fatController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Fats (g)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_task_rounded, color: Colors.black),
                      label: const Text('Save Meal to PostgreSQL & Update Redis'),
                      onPressed: _logMeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Today's Logged Meals
            const Text(
              "TODAY'S LOGGED MEALS",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 10),
            if (todayMeals.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('No meals logged yet today.', style: TextStyle(color: AppTheme.textSecondary))),
              )
            else
              ...todayMeals.map((meal) => _buildMealItem(meal)),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroSummary(DayNutritionSummary summary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Daily Nutrition Target', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(
                '${summary.consumedCalories} / ${summary.targetCalories} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (summary.consumedCalories / summary.targetCalories).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surfaceLight,
              color: AppTheme.primary,
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildProgressBar('Protein', summary.consumedProteinGrams, summary.targetProteinGrams, AppTheme.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProgressBar('Carbs', summary.consumedCarbsGrams, summary.targetCarbsGrams, AppTheme.secondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProgressBar('Fats', summary.consumedFatGrams, summary.targetFatGrams, AppTheme.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(String label, int current, int target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${current}g / ${target}g', style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppTheme.surfaceLight,
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildMealItem(NutritionLogModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_rounded, color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.foodName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${meal.mealType.toUpperCase()} • P: ${meal.proteinGrams}g | C: ${meal.carbsGrams}g | F: ${meal.fatGrams}g',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${meal.calories} kcal',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.amber, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
