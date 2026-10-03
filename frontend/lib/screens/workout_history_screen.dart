import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/workout_model.dart';

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  String selectedCategory = 'All';
  int? selectedMaxDuration;
  final categories = ['All', 'Strength', 'HIIT', 'Cardio', 'Mobility'];

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => selectedCategory = cat);
                            ref.read(workoutHistoryProvider.notifier).loadHistory(
                                  category: cat,
                                  maxDuration: selectedMaxDuration,
                                );
                          },
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Filter by duration:', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    const SizedBox(width: 8),
                    _durationBadge('Any', null),
                    const SizedBox(width: 6),
                    _durationBadge('≤ 30 min', 30),
                    const SizedBox(width: 6),
                    _durationBadge('≤ 45 min', 45),
                  ],
                ),
              ],
            ),
          ),

          // Logs List
          Expanded(
            child: historyAsync.when(
              data: (logs) {
                if (logs.isEmpty) {
                  return const Center(child: Text('No workout history found for these filters.'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: logs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, idx) => _buildLogCard(logs[idx]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _durationBadge(String label, int? val) {
    final isSelected = selectedMaxDuration == val;
    return InkWell(
      onTap: () {
        setState(() => selectedMaxDuration = val);
        ref.read(workoutHistoryProvider.notifier).loadHistory(
              category: selectedCategory,
              maxDuration: val,
            );
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
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

  Widget _buildLogCard(WorkoutLogModel log) {
    final dateFormat = DateFormat('EEE, MMM d • h:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  log.category.toUpperCase(),
                  style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                dateFormat.format(log.completedAt),
                style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            log.workoutTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 16, color: AppTheme.secondary),
              const SizedBox(width: 4),
              Text('${log.durationMinutes} min', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              const Icon(Icons.local_fire_department_rounded, size: 16, color: AppTheme.amber),
              const SizedBox(width: 4),
              Text('${log.caloriesBurned} kcal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              // REQUIREMENT: Edit a logged entry (e.g. correct duration)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.surfaceLight,
                  foregroundColor: AppTheme.textPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.secondary),
                label: const Text('Edit', style: TextStyle(fontSize: 12)),
                onPressed: () => _showEditLogDialog(log),
              ),
            ],
          ),
          if (log.notes != null && log.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Notes: ${log.notes}',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditLogDialog(WorkoutLogModel log) {
    final durationController = TextEditingController(text: log.durationMinutes.toString());
    final caloriesController = TextEditingController(text: log.caloriesBurned.toString());
    final notesController = TextEditingController(text: log.notes ?? '');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppTheme.primary),
              SizedBox(width: 8),
              Text('Edit Logged Session', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (Minutes)',
                  prefixIcon: Icon(Icons.timer_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories Burned (kcal)',
                  prefixIcon: Icon(Icons.local_fire_department_outlined, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Session Notes',
                  prefixIcon: Icon(Icons.notes_rounded, size: 18),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
            ),
            ElevatedButton(
              child: const Text('Save Changes'),
              onPressed: () async {
                final newDuration = int.tryParse(durationController.text) ?? log.durationMinutes;
                final newCalories = int.tryParse(caloriesController.text) ?? log.caloriesBurned;
                await ref.read(workoutHistoryProvider.notifier).editLog(
                      log.id,
                      newDuration,
                      newCalories,
                      notesController.text,
                    );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: AppTheme.primary,
                    content: Text('Log successfully updated!'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
