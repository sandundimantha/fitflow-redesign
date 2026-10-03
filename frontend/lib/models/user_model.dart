import 'package:flutter/foundation.dart';

@immutable
class UserModel {
  final String id;
  final String firebaseUid;
  final String displayName;
  final String? email;
  final String? avatarUrl;
  final String fitnessGoal;
  final String experienceLevel;
  final double weightKg;
  final double heightCm;
  final String language;
  final int totalWorkoutsCompleted;
  final int currentStreakDays;

  const UserModel({
    required this.id,
    required this.firebaseUid,
    required this.displayName,
    this.email,
    this.avatarUrl,
    required this.fitnessGoal,
    required this.experienceLevel,
    required this.weightKg,
    required this.heightCm,
    required this.language,
    this.totalWorkoutsCompleted = 0,
    this.currentStreakDays = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'User',
      email: json['email']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      fitnessGoal: json['fitnessGoal']?.toString() ?? 'general_fitness',
      experienceLevel: json['experienceLevel']?.toString() ?? 'beginner',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0.0,
      language: json['language']?.toString() ?? 'en',
      totalWorkoutsCompleted:
          (json['totalWorkoutsCompleted'] as num?)?.toInt() ?? 0,
      currentStreakDays: (json['currentStreakDays'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'fitnessGoal': fitnessGoal,
      'experienceLevel': experienceLevel,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'language': language,
      'totalWorkoutsCompleted': totalWorkoutsCompleted,
      'currentStreakDays': currentStreakDays,
    };
  }

  UserModel copyWith({
    String? id,
    String? firebaseUid,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? fitnessGoal,
    String? experienceLevel,
    double? weightKg,
    double? heightCm,
    String? language,
    int? totalWorkoutsCompleted,
    int? currentStreakDays,
  }) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      language: language ?? this.language,
      totalWorkoutsCompleted:
          totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
