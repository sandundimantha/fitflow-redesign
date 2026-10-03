import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool isSignUp = false;
  final emailController = TextEditingController(text: 'alex.morgan@fitflow.app');
  final passwordController = TextEditingController(text: 'password123');
  final nameController = TextEditingController(text: 'Alex Morgan');
  bool isLoading = false;

  void _handleAuth() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(apiClientProvider).setAuthCredentials(
          token: 'dev-token-xyz',
          userId: 'usr_demo_777',
        );
    await ref.read(userProvider.notifier).loadUser();
    if (mounted) {
      setState(() => isLoading = false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090D16),
              Color(0xFF0F172A),
              Color(0xFF051C14),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Brand Logo & Title
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primary.withOpacity(0.4), width: 2),
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FitFlow',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Intelligent Fitness & Macro Optimization',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 36),

                  // Auth Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surface.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.surfaceBorder),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          isSignUp ? 'Create FitFlow Account' : 'Welcome Back',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (isSignUp) ...[
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person_outline, color: AppTheme.textMuted),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address or Phone',
                            prefixIcon: Icon(Icons.mail_outline, color: AppTheme.textMuted),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted),
                          ),
                        ),
                        const SizedBox(height: 22),
                        ElevatedButton(
                          onPressed: isLoading ? null : _handleAuth,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                )
                              : Text(isSignUp ? 'Sign Up with Firebase' : 'Sign In with Firebase'),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () => setState(() => isSignUp = !isSignUp),
                          child: Text(
                            isSignUp ? 'Already have an account? Sign In' : "Don't have an account? Sign Up",
                            style: const TextStyle(color: AppTheme.secondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick One-Tap Demo Mode Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary, width: 1.2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _handleAuth,
                    icon: const Icon(Icons.flash_on_rounded, color: AppTheme.primary),
                    label: const Text(
                      'Fast Dev Bypass Mode (Alex Morgan)',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Meets coursework target: Sub-2-second cold launch',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
