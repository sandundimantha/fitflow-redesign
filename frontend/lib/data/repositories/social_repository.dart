import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/post_model.dart';

abstract class ISocialRepository {
  Future<List<SocialPostModel>> getFeed({int page, int limit});
  Future<SocialPostModel> createPost(String content, {String? challengeId, String? challengeName});
  Future<void> toggleLike(String postId);
  Future<SocialCommentModel> addComment(String postId, String text);
  Future<List<ChallengeModel>> getChallenges();
  Future<void> joinChallenge(String challengeId);
}

class SocialRepository implements ISocialRepository {
  final ApiClient _client;

  SocialRepository(this._client);

  @override
  Future<List<SocialPostModel>> getFeed({int page = 1, int limit = 20}) async {
    final data = await _client.get('${ApiConstants.socialFeed}?page=$page&limit=$limit');
    final list = data as List;
    return list.map((e) => SocialPostModel.fromJson(e)).toList();
  }

  @override
  Future<SocialPostModel> createPost(String content, {String? challengeId, String? challengeName}) async {
    final data = await _client.post(ApiConstants.socialPosts, {
      'content': content,
      'challengeId': challengeId,
      'challengeName': challengeName,
    });
    return SocialPostModel.fromJson(data);
  }

  @override
  Future<void> toggleLike(String postId) async {
    await _client.post('${ApiConstants.socialPosts}/$postId/like', {});
  }

  @override
  Future<SocialCommentModel> addComment(String postId, String text) async {
    final data = await _client.post('${ApiConstants.socialPosts}/$postId/comments', {'text': text});
    return SocialCommentModel.fromJson(data);
  }

  @override
  Future<List<ChallengeModel>> getChallenges() async {
    final data = await _client.get(ApiConstants.socialChallenges);
    final list = data as List;
    return list.map((e) => ChallengeModel.fromJson(e)).toList();
  }

  @override
  Future<void> joinChallenge(String challengeId) async {
    await _client.post('${ApiConstants.socialChallenges}/$challengeId/join', {});
  }
}
