class SocialCommentModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String text;
  final DateTime createdAt;

  SocialCommentModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.text,
    required this.createdAt,
  });

  factory SocialCommentModel.fromJson(Map<String, dynamic> json) {
    return SocialCommentModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      authorName: json['authorName'] ?? 'Athlete',
      authorAvatar: json['authorAvatar'],
      text: json['text'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class SocialPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? mediaUrl;
  final String? challengeId;
  final String? challengeName;
  int likesCount;
  List<String> likedBy;
  List<SocialCommentModel> comments;
  final DateTime createdAt;

  SocialPostModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    this.mediaUrl,
    this.challengeId,
    this.challengeName,
    required this.likesCount,
    required this.likedBy,
    required this.comments,
    required this.createdAt,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    final cList = (json['comments'] as List?) ?? [];
    final lList = (json['likedBy'] as List?) ?? [];

    return SocialPostModel(
      id: json['id'] ?? json['_id'] ?? '',
      userId: json['userId'] ?? '',
      authorName: json['authorName'] ?? 'Athlete',
      authorAvatar: json['authorAvatar'],
      content: json['content'] ?? '',
      mediaUrl: json['mediaUrl'],
      challengeId: json['challengeId'],
      challengeName: json['challengeName'],
      likesCount: json['likesCount'] ?? 0,
      likedBy: lList.map((e) => e.toString()).toList(),
      comments: cList.map((c) => SocialCommentModel.fromJson(c)).toList(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class ChallengeModel {
  final String id;
  final String title;
  final String category;
  final int participantsCount;
  final int daysRemaining;
  final String imageUrl;
  final String description;
  bool isJoined;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.participantsCount,
    required this.daysRemaining,
    required this.imageUrl,
    required this.description,
    this.isJoined = false,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? 'General',
      participantsCount: json['participantsCount'] ?? 100,
      daysRemaining: json['daysRemaining'] ?? 14,
      imageUrl: json['imageUrl'] ?? '',
      description: json['description'] ?? '',
      isJoined: json['isJoined'] ?? false,
    );
  }
}
