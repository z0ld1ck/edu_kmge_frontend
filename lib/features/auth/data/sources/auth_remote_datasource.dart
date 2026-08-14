import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _api;

  AuthRemoteDataSource(this._api);

  Future<String> login(String email, String password) async {
    final data = await _api.postForm(
      '/api/auth/login',
      {'username': email, 'password': password},
    );
    return data['access_token'] as String;
  }

  Future<UserModel> register(
      String email, String fullName, String password) async {
    final data = await _api.post('/api/auth/register', body: {
      'email': email,
      'full_name': fullName,
      'password': password,
    });
    return UserModel.fromJson(data);
  }

  Future<UserModel> me() async {
    final data = await _api.get('/api/auth/me');
    return UserModel.fromJson(data);
  }

  Future<UserModel> updateMe(Map<String, dynamic> body) async {
    final data = await _api.patch('/api/auth/me', body: body);
    return UserModel.fromJson(data);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _api.post('/api/auth/change-password', body: {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
  }
}