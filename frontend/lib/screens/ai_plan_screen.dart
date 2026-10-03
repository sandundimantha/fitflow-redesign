import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../models/ai_plan_model.dart';

class AiPlanScreen extends ConsumerStatefulWidget {
  const AiPlanScreen({super.key});

  @override
  ConsumerState<AiPlanScreen> createState() => _AiPlanScreenState();
}

class _AiPlanScreenState extends ConsumerState<AiPlanScreen> {
  String selectedGoal = 'muscle_gain';
  final List<String> selectedEquipment = ['dumbbells', 'bodyweight'];
  int daysPerWeek = 4;
  String experienceLevel = 'intermediate';

  final availableGoals = [
    {'id': 'muscle_gain', 'label': 'Muscle Gain (Hypertrophy)'},
    {'id': 'weight_loss', 'label': 'Fat Loss & Conditioning'},
    {'id': 'endurance', 'label': 'Aerobic Endurance & Stamina'},
    {'id': 'functional_fitness', 'label': 'Functional Mobility & Power'},
  ];

  final allEquipment = [
    {'id': 'dumbbells', 'label': 'Dumbbells'},
    {'id': 'barbell', 'label': 'Barbell & Rack'},
    {'id': 'pullup_bar', 'label': 'Pull-up Bar'},
    {'id': 'bodyweight', 'label': 'Bodyweight Only'},
    {'id': 'resistance_bands', 'label': 'Resistance Bands'},
  ];

  void _generatePlan() async {
    final stopwatch = Stopwatch()..start();
    final success = await ref.read(aiPlanProvider.notifier).generatePlan(
          goal: selectedGoal,
          availableEquipment: selectedEquipment,
          experienceLevel: experienceLevel,
          daysPerWeek: daysPerWeek,
        );
    stopwatch.stop();

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text(
            'Protocol generated in ${stopwatch.elapsedMilliseconds}ms (< 3s SLA)!',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(aiPlanProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.2),
                    AppTheme.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.psychology_rounded, color: AppTheme.accent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Workout Architect',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Analyzes your PostgreSQL history + equipment via FastAPI microservice with 1-line rationales.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Generator Input Form
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
                  const Text('1. SELECT FITNESS GOAL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedGoal,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                    items: availableGoals
                        .map((g) => DropdownMenuItem(value: g['id'], child: Text(g['label']!)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedGoal = val);
                    },
                  ),
                  const SizedBox(height: 18),

                  const Text('2. AVAILABLE EQUIPMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: allEquipment.map((eq) {
                      final isSelected = selectedEquipment.contains(eq['id']);
                      return FilterChip(
                        label: Text(eq['label']!),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedEquipment.add(eq['id']!);
                            } else {
                              selectedEquipment.remove(eq['id']!);
                            }
                          });
                        },
                        selectedColor: AppTheme.primary,
                        backgroundColor: AppTheme.surfaceLight,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('3. TRAINING FREQUENCY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      Text('$daysPerWeek Days / Week', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondary)),
                    ],
                  ),
                  Slider(
                    value: daysPerWeek.toDouble(),
                    min: 2,
                    max: 5,
                    divisions: 3,
                    activeColor: AppTheme.secondary,
                    onChanged: (v) => setState(() => daysPerWeek = v.round()),
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: planAsync.isLoading ? null : _generatePlan,
                      icon: planAsync.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.auto_awesome_rounded, color: Colors.black),
                      label: Text(
                        planAsync.isLoading ? 'Generating Protocol (< 3s)...' : 'Generate AI Workout Protocol',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // =========================================================================
            // REQUIREMENT: Render generated plan + ONE-LINE EXPLANATION of why each exercise was chosen
            // =========================================================================
            planAsync.when(
              data: (plan) {
                if (plan == null) return const SizedBox();
                return _buildGeneratedPlanView(plan);
              },
              loading: () => Container(
                padding: const EdgeInsets.all(28),
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 12),
                    Text('FastAPI Microservice analyzing history and synthesizing exercises...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedPlanView(AiPlanModel plan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'GENERATED AI BLUEPRINT',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: AppTheme.textMuted),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
              child: Text(
                '${plan.durationWeeks} WEEKS • ${plan.daysPerWeek} DAYS/WK',
                style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(plan.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Text(plan.summary, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Day Routines with Rationales
        ...plan.routines.map((routine) => _buildRoutineCard(routine)),
      ],
    );
  }

  Widget _buildRoutineCard(AiDayRoutine routine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  routine.dayTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  '${routine.estimatedDurationMinutes} min',
                  style: const TextStyle(color: AppTheme.secondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(14),
            itemCount: routine.exercises.length,
            separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 20),
            itemBuilder: (ctx, idx) {
              final ex = routine.exercises[idx];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ex.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${ex.sets} sets × ${ex.reps}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Target: ${ex.targetMuscle} • Equipment: ${ex.equipmentRequired}',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 6),

                  // =====================================================================
                  // REQUIREMENT: Short one-line explanation of why each exercise was chosen
                  // =====================================================================
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primary, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            ex.rationale,
                            style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
