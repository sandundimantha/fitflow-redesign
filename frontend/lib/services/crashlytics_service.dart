import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Enterprise Crashlytics Service providing centralized crash reporting,
/// fatal/non-fatal exception tracking, custom logging, and user identification.
class CrashlyticsService {
  static final CrashlyticsService instance = CrashlyticsService._internal();

  CrashlyticsService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize Firebase Core and Firebase Crashlytics with error handling hooks.
  Future<void> initialize() async {
    try {
      if (Firebase.apps.isEmpty) {
        // Attempt default initialization if platform configurations exist
        await Firebase.initializeApp();
      }

      if (!kIsWeb) {
        // Pass all uncaught errors from the Flutter framework to Crashlytics
        FlutterError.onError = onFlutterError;

        // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework
        PlatformDispatcher.instance.onError = onPlatformError;

        // Enable Crashlytics collection in production
        await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      }

      _isInitialized = true;
      debugPrint('[CrashlyticsService] Successfully initialized Firebase Crashlytics.');
    } catch (e) {
      // In local dev/test or web environments without google-services.json,
      // fail gracefully and log locally so the app runs smoothly.
      debugPrint('[CrashlyticsService] Running in offline/fallback mode ($e).');
      _isInitialized = false;

      // Still capture framework errors to console in fallback mode
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        debugPrint('[CrashlyticsFallback] Error: ${details.exceptionAsString()}');
      };
    }
  }

  /// Hook for Flutter framework errors (e.g. build exceptions)
  void onFlutterError(FlutterErrorDetails details) {
    if (_isInitialized && !kIsWeb) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    } else {
      FlutterError.presentError(details);
      debugPrint('[Crashlytics] FlutterError: ${details.exceptionAsString()}');
    }
  }

  /// Hook for asynchronous uncaught platform errors
  bool onPlatformError(Object error, StackTrace stack) {
    if (_isInitialized && !kIsWeb) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      debugPrint('[Crashlytics] PlatformError: $error\n$stack');
    }
    return true;
  }

  /// Log custom breadcrumb message into Crashlytics session
  Future<void> log(String message) async {
    debugPrint('[Breadcrumb] $message');
    if (_isInitialized && !kIsWeb) {
      try {
        await FirebaseCrashlytics.instance.log(message);
      } catch (_) {}
    }
  }

  /// Explicitly record caught exceptions (non-fatal or fatal)
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    debugPrint('[Crashlytics] Caught error (fatal=$fatal): $exception (reason: $reason)');
    if (_isInitialized && !kIsWeb) {
      try {
        await FirebaseCrashlytics.instance.recordError(
          exception,
          stack,
          reason: reason,
          fatal: fatal,
        );
      } catch (_) {}
    }
  }

  /// Associate crashes with the authenticated user ID
  Future<void> setUserIdentifier(String userId) async {
    if (_isInitialized && !kIsWeb) {
      try {
        await FirebaseCrashlytics.instance.setUserIdentifier(userId);
      } catch (_) {}
    }
  }

  /// Set custom key-value pairs to annotate crashes
  Future<void> setCustomKey(String key, Object value) async {
    if (_isInitialized && !kIsWeb) {
      try {
        await FirebaseCrashlytics.instance.setCustomKey(key, value);
      } catch (_) {}
    }
  }
}
