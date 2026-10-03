import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/workout_model.dart';
import 'workout_history_screen.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  final categories = ['All', 'Strength', 'HIIT', 'Cardio', 'Mobility'];
  int? selectedMaxDuration;

  @override
  Widget build(BuildContext context) {
    final workoutsAsync = ref.watch(workoutsListProvider);
    final currentCat = ref.watch(workoutsListProvider.notifier).selectedCategory;

    return Scaffold(
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surface,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Browse Workouts',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(foregroundColor: AppTheme.secondary),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('View History', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const WorkoutHistoryScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Category Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = currentCat == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(workoutsListProvider.notifier).filter(category: cat);
                          },
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 6),

                // Duration filter row
                Row(
                  children: [
                    const Text('Duration:', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    const SizedBox(width: 8),
                    _durationChip('Any', null),
                    const SizedBox(width: 6),
                    _durationChip('< 30 min', 30),
                    const SizedBox(width: 6),
                    _durationChip('< 45 min', 45),
                  ],
                ),
              ],
            ),
          ),

          // Workouts List
          Expanded(
            child: workoutsAsync.when(
              data: (list) {
                if (list.isEmpty) {
                  return const Center(child: Text('No workouts match your filters.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) => _buildWorkoutListItem(list[idx]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('Error loading workouts: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationChip(String label, int? val) {
    final isSelected = selectedMaxDuration == val;
    return GestureDetector(
      onTap: () {
        setState(() => selectedMaxDuration = val);
        ref.read(workoutsListProvider.notifier).filter(maxDuration: val);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppTheme.secondary : AppTheme.surfaceBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.secondary : AppTheme.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutListItem(WorkoutModel workout) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
            child: Image.network(
              workout.imageUrl ?? 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 100, height: 100, color: AppTheme.surfaceLight),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        workout.category.toUpperCase(),
                        style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${workout.difficulty}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text('${workout.durationMinutes} min', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      const SizedBox(width: 12),
                      const Icon(Icons.local_fire_department_rounded, size: 14, color: AppTheme.amber),
                      const SizedBox(width: 4),
                      Text('${workout.caloriesBurnEstimate} kcal', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primary, size: 36),
            onPressed: () => _startWorkout(workout),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  void _startWorkout(WorkoutModel workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Start Session: ${workout.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(workout.description, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.check, color: Colors.black),
                label: const Text('Complete & Save to History'),
                onPressed: () async {
                  await ref.read(workoutHistoryProvider.notifier).addLog(
                        WorkoutLogModel(
                          id: 'log_${DateTime.now().millisecondsSinceEpoch}',
                          workoutId: workout.id,
                          workoutTitle: workout.title,
                          category: workout.category,
                          durationMinutes: workout.durationMinutes,
                          caloriesBurned: workout.caloriesBurnEstimate,
                          completedAt: DateTime.now(),
                        ),
                      );
                  Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.primary,
                        content: Text('Logged session to your history!'),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted))),
            ],
          ),
        );
      },
    );
  }
}
