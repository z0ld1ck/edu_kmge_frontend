import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';

class UserRemoteDataSource {
  final ApiClient _api;

  UserRemoteDataSource(this._api);

  Future<List<UserModel>> list({String? q}) async {
    final data = await _api.get('/api/users', query: {
      if (q != null && q.isNotEmpty) 'q': q,
    });
    return (data as List)
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> create(Map<String, dynamic> body) async {
    final data = await _api.post('/api/users', body: body);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> update(int id, Map<String, dynamic> body) =>
      _api.patch('/api/users/$id', body: body);

  Future<void> delete(int id) => _api.delete('/api/users/$id');
}
