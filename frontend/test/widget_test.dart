import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitflow_app/main.dart';
import 'package:fitflow_app/screens/main_navigation_screen.dart';

void main() {
  testWidgets('FitFlow app launches and displays Dashboard with Today Scheduled Workout above the fold', (WidgetTester tester) async {
    // Build the app inside a ProviderScope
    await tester.pumpWidget(
      const ProviderScope(
        child: FitFlowApp(),
      ),
    );

    // Initial pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify App Bar Title
    expect(find.text('FitFlow'), findsOneWidget);

    // Verify Today's Scheduled Workout heading is rendered above the fold
    expect(find.text("TODAY'S SCHEDULED WORKOUT"), findsOneWidget);

    // Verify Quick Actions exist
    expect(find.text('Workout History'), findsOneWidget);
    expect(find.text('Progress Chart'), findsOneWidget);
    expect(find.text('Nutrition Tracker'), findsOneWidget);
    expect(find.text('Community Feed'), findsOneWidget);

    // Verify Bottom Navigation items
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Workouts'), findsOneWidget);
    expect(find.text('AI Plan'), findsOneWidget);
    expect(find.text('Nutrition'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });

  testWidgets('Switching tabs navigates directly in 1 tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FitFlowApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on AI Plan in bottom nav (1 tap)
    await tester.tap(find.text('AI Plan'));
    await tester.pumpAndSettle();

    // Verify AI Workout Architect screen appears
    expect(find.text('AI Workout Architect'), findsOneWidget);
    expect(find.text('Generate AI Workout Protocol'), findsOneWidget);
  });
}
