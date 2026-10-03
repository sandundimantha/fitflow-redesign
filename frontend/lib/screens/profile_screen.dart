import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'auth_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final nameController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  String selectedGoal = 'muscle_gain';
  String selectedLevel = 'intermediate';
  String selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    if (user != null) {
      nameController.text = user.displayName;
      weightController.text = user.weightKg.toString();
      heightController.text = user.heightCm.toString();
      selectedGoal = user.fitnessGoal;
      selectedLevel = user.experienceLevel;
      selectedLanguage = user.language;
    }
  }

  void _saveProfile() async {
    final w = double.tryParse(weightController.text);
    final h = double.tryParse(heightController.text);

    await ref.read(userProvider.notifier).updateProfile(
          displayName: nameController.text.trim(),
          fitnessGoal: selectedGoal,
          experienceLevel: selectedLevel,
          weightKg: w,
          heightCm: h,
          language: selectedLanguage,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.primary,
          content: Text('Profile updated successfully!'),
        ),
      );
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: AppTheme.secondary),
            SizedBox(width: 8),
            Text('Privacy Policy & GDPR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FitFlow Data Sovereignty',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primary),
              ),
              SizedBox(height: 6),
              Text(
                'Your health metrics, workout logs, and nutrition logs are encrypted and never sold to third-party ad networks.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
              SizedBox(height: 12),
              Text(
                'Coursework Compliance Notice',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondary),
              ),
              SizedBox(height: 6),
              Text(
                'In accordance with IT3060 HCI privacy guidelines, biometric data is stored securely in PostgreSQL with field-level encryption protocols and user rights for data export.',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage: NetworkImage(
                      user?.avatarUrl ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Alex Morgan',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? 'alex.morgan@fitflow.app',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${user?.totalWorkoutsCompleted ?? 14} WORKOUTS COMPLETED',
                            style: const TextStyle(color: AppTheme.primary, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =========================================================================
            // REQUIREMENT: Edit Profile Details
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
                  const Text('EDIT PROFILE ATTRIBUTES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Display Name', prefixIcon: Icon(Icons.person_outline)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.scale_rounded)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height_rounded)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGoal,
                    decoration: const InputDecoration(labelText: 'Fitness Goal'),
                    items: const [
                      DropdownMenuItem(value: 'muscle_gain', child: Text('Muscle Gain (Hypertrophy)')),
                      DropdownMenuItem(value: 'weight_loss', child: Text('Fat Loss & Calorie Burn')),
                      DropdownMenuItem(value: 'endurance', child: Text('Cardiovascular Endurance')),
                      DropdownMenuItem(value: 'functional_fitness', child: Text('Functional Mobility')),
                    ],
                    onChanged: (v) => setState(() => selectedGoal = v!),
                  ),
                  const SizedBox(height: 16),

                  // =====================================================================
                  // REQUIREMENT: Language Preference Selector
                  // =====================================================================
                  DropdownButtonFormField<String>(
                    value: selectedLanguage,
                    decoration: const InputDecoration(
                      labelText: 'Language Preference',
                      prefixIcon: Icon(Icons.translate_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English (US/UK)')),
                      DropdownMenuItem(value: 'es', child: Text('Español (Spanish)')),
                      DropdownMenuItem(value: 'fr', child: Text('Français (French)')),
                      DropdownMenuItem(value: 'de', child: Text('Deutsch (German)')),
                      DropdownMenuItem(value: 'si', child: Text('සිංහල (Sinhala)')),
                    ],
                    onChanged: (v) => setState(() => selectedLanguage = v!),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile Settings'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // =========================================================================
            // REQUIREMENT: Privacy Policy Link
            // =========================================================================
            ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              tileColor: AppTheme.surface,
              leading: const Icon(Icons.privacy_tip_outlined, color: AppTheme.secondary),
              title: const Text('Privacy Policy & Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Review your data sovereignty and encryption details', style: TextStyle(fontSize: 11)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              onTap: _showPrivacyPolicy,
            ),
            const SizedBox(height: 12),

            // =========================================================================
            // REQUIREMENT: Logout
            // =========================================================================
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: const Text('Log Out of FitFlow', style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
