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

  UserModel({
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
      id: json['id'] ?? 'usr_demo_777',
      firebaseUid: json['firebaseUid'] ?? 'usr_demo_777',
      displayName: json['displayName'] ?? 'Alex Morgan',
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200',
      fitnessGoal: json['fitnessGoal'] ?? 'muscle_gain',
      experienceLevel: json['experienceLevel'] ?? 'intermediate',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 74.5,
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 178.0,
      language: json['language'] ?? 'en',
      totalWorkoutsCompleted: json['totalWorkoutsCompleted'] ?? 14,
      currentStreakDays: json['currentStreakDays'] ?? 6,
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
}
