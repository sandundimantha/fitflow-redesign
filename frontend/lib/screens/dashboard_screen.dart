import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/workout_model.dart';
import 'main_navigation_screen.dart';
import 'workout_history_screen.dart';
import 'progress_charts_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayWorkoutAsync = ref.watch(todayWorkoutProvider);
    final nutritionAsync = ref.watch(nutritionProvider);
    final user = ref.watch(userProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(todayWorkoutProvider);
          await ref.read(nutritionProvider.notifier).loadTodayNutrition();
          await ref.read(userProvider.notifier).loadUser();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // User Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to crush it, ${user?.displayName?.split(' ').first ?? 'Alex'}?',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: ${user?.fitnessGoal.replaceAll('_', ' ').toUpperCase() ?? 'MUSCLE GAIN'} • Level: ${user?.experienceLevel.toUpperCase() ?? 'INTERMEDIATE'}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: AppTheme.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${user?.currentStreakDays ?? 6} Days',
                        style: const TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // =========================================================================
            // REQUIREMENT: Today's scheduled workout shown ABOVE THE FOLD FIRST!
            // Not buried under widgets!
            // =========================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: AppTheme.primary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "TODAY'S SCHEDULED WORKOUT",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'PRIORITY 1',
                    style: TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            todayWorkoutAsync.when(
              data: (workout) => _buildTodayWorkoutCard(context, ref, workout),
              loading: () => Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              ),
              error: (e, _) => const SizedBox(),
            ),
            const SizedBox(height: 20),

            // =========================================================================
            // REQUIREMENT: Quick Links to History, Community, Nutrition (Directly reachable)
            // =========================================================================
            const Text(
              'QUICK ACTIONS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildQuickLinkCard(
                    icon: Icons.history_rounded,
                    color: AppTheme.secondary,
                    title: 'Workout History',
                    subtitle: 'Filter & edit logs',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickLinkCard(
                    icon: Icons.bar_chart_rounded,
                    color: AppTheme.primary,
                    title: 'Progress Chart',
                    subtitle: 'This vs last week',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ProgressChartsScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildQuickLinkCard(
                    icon: Icons.restaurant_rounded,
                    color: AppTheme.amber,
                    title: 'Nutrition Tracker',
                    subtitle: 'Log food & macros',
                    onTap: () => ref.read(navigationIndexProvider.notifier).state = 3,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildQuickLinkCard(
                    icon: Icons.groups_rounded,
                    color: AppTheme.accent,
                    title: 'Community Feed',
                    subtitle: 'Join challenges',
                    onTap: () => ref.read(navigationIndexProvider.notifier).state = 4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // =========================================================================
            // Nutrition Running Totals (Cached in Redis)
            // =========================================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TODAY'S MACRO TOTALS (REDIS CACHED)",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppTheme.textMuted,
                  ),
                ),
                TextButton(
                  onPressed: () => ref.read(navigationIndexProvider.notifier).state = 3,
                  child: const Text('Log Meal +', style: TextStyle(color: AppTheme.primary, fontSize: 13)),
                ),
              ],
            ),
            nutritionAsync.when(
              data: (nutrition) => _buildNutritionBanner(nutrition),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTodayWorkoutCard(BuildContext context, WidgetRef ref, WorkoutModel workout) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: Stack(
              children: [
                Image.network(
                  workout.imageUrl ?? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 140, color: AppTheme.surfaceLight),
                ),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppTheme.surface.withOpacity(0.9)],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          workout.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, size: 16, color: AppTheme.textPrimary),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.durationMinutes} min',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.local_fire_department_rounded, size: 16, color: AppTheme.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${workout.caloriesBurnEstimate} kcal',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  workout.description,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                        label: const Text('Start Workout Now'),
                        onPressed: () {
                          _showStartWorkoutDialog(context, ref, workout);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.surfaceBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onPressed: () => ref.read(navigationIndexProvider.notifier).state = 1,
                      child: const Icon(Icons.list_rounded, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionBanner(dynamic nutrition) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily Energy', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${nutrition.consumedCalories}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                      ),
                      Text(
                        ' / ${nutrition.targetCalories} kcal',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt_rounded, color: AppTheme.amber, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildMacroPill('Protein', '${nutrition.consumedProteinGrams}g', '${nutrition.targetProteinGrams}g', AppTheme.primary)),
              const SizedBox(width: 8),
              Expanded(child: _buildMacroPill('Carbs', '${nutrition.consumedCarbsGrams}g', '${nutrition.targetCarbsGrams}g', AppTheme.secondary)),
              const SizedBox(width: 8),
              Expanded(child: _buildMacroPill('Fats', '${nutrition.consumedFatGrams}g', '${nutrition.targetFatGrams}g', AppTheme.accent)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroPill(String name, String current, String target, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text('$current / $target', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showStartWorkoutDialog(BuildContext context, WidgetRef ref, WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ready to train: ${workout.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                '${workout.exercises.length} exercises planned (${workout.durationMinutes} min target). Log your effort when complete.',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black),
                label: const Text('Complete & Log Workout'),
                onPressed: () async {
                  await ref.read(workoutHistoryProvider.notifier).addLog(
                        WorkoutLogModel(
                          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
                          workoutId: workout.id,
                          workoutTitle: workout.title,
                          category: workout.category,
                          durationMinutes: workout.durationMinutes,
                          caloriesBurned: workout.caloriesBurnEstimate,
                          perceivedExertion: 8,
                          notes: 'Completed session from Today schedule',
                          completedAt: DateTime.now(),
                        ),
                      );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.primary,
                      content: Text('Workout successfully logged! Added to your history.', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
            ],
          ),
        );
      },
    );
  }
}
