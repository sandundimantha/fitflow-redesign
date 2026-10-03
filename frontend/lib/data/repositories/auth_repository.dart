import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../models/user_model.dart';

abstract class IAuthRepository {
  Future<UserModel> syncUser({String? firebaseUid, String? email, String? displayName});
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> payload);
}

class AuthRepository implements IAuthRepository {
  final ApiClient _client;

  AuthRepository(this._client);

  @override
  Future<UserModel> syncUser({String? firebaseUid, String? email, String? displayName}) async {
    final data = await _client.post(ApiConstants.authSync, {
      'firebaseUid': firebaseUid,
      'email': email,
      'displayName': displayName,
    });
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> getProfile() async {
    final data = await _client.get(ApiConstants.userProfile);
    return UserModel.fromJson(data);
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> payload) async {
    final data = await _client.patch(ApiConstants.userProfile, payload);
    return UserModel.fromJson(data);
  }
}
