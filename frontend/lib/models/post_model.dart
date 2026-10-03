import 'package:flutter/foundation.dart';

@immutable
class SocialCommentModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String text;
  final DateTime createdAt;

  const SocialCommentModel({
    required this.id,
    required this.userId,
    required this.authorName,
    this.authorAvatar,
    required this.text,
    required this.createdAt,
  });

  factory SocialCommentModel.fromJson(Map<String, dynamic> json) {
    return SocialCommentModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'User',
      authorAvatar: json['authorAvatar']?.toString(),
      text: json['text']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SocialCommentModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? text,
    DateTime? createdAt,
  }) {
    return SocialCommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialCommentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class SocialPostModel {
  final String id;
  final String userId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String? mediaUrl;
  final String? challengeId;
  final String? challengeName;
  final int likesCount;
  final List<String> likedBy;
  final List<SocialCommentModel> comments;
  final DateTime createdAt;

  const SocialPostModel({
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

  bool isLikedBy(String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return likedBy.contains(currentUserId);
  }

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    final cList = (json['comments'] as List?) ?? [];
    final lList = (json['likedBy'] as List?) ?? [];

    return SocialPostModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      authorName: json['authorName']?.toString() ?? 'User',
      authorAvatar: json['authorAvatar']?.toString(),
      content: json['content']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString(),
      challengeId: json['challengeId']?.toString(),
      challengeName: json['challengeName']?.toString(),
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      likedBy: List<String>.unmodifiable(lList.map((e) => e.toString())),
      comments: List<SocialCommentModel>.unmodifiable(
        cList.map((c) => SocialCommentModel.fromJson(Map<String, dynamic>.from(c))),
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'mediaUrl': mediaUrl,
      'challengeId': challengeId,
      'challengeName': challengeName,
      'likesCount': likesCount,
      'likedBy': likedBy,
      'comments': comments.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SocialPostModel copyWith({
    String? id,
    String? userId,
    String? authorName,
    String? authorAvatar,
    String? content,
    String? mediaUrl,
    String? challengeId,
    String? challengeName,
    int? likesCount,
    List<String>? likedBy,
    List<SocialCommentModel>? comments,
    DateTime? createdAt,
  }) {
    return SocialPostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      challengeId: challengeId ?? this.challengeId,
      challengeName: challengeName ?? this.challengeName,
      likesCount: likesCount ?? this.likesCount,
      likedBy: likedBy != null ? List<String>.unmodifiable(likedBy) : this.likedBy,
      comments: comments != null ? List<SocialCommentModel>.unmodifiable(comments) : this.comments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialPostModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class ChallengeModel {
  final String id;
  final String title;
  final String category;
  final int participantsCount;
  final int daysRemaining;
  final String imageUrl;
  final String description;
  final bool isJoined;

  const ChallengeModel({
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
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      category: json['category']?.toString() ?? 'General',
      participantsCount: (json['participantsCount'] as num?)?.toInt() ?? 0,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isJoined: json['isJoined'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'participantsCount': participantsCount,
      'daysRemaining': daysRemaining,
      'imageUrl': imageUrl,
      'description': description,
      'isJoined': isJoined,
    };
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? category,
    int? participantsCount,
    int? daysRemaining,
    String? imageUrl,
    String? description,
    bool? isJoined,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      participantsCount: participantsCount ?? this.participantsCount,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
