import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl(this._remote, this._tokenStorage);

  @override
  String? get token => _tokenStorage.token;

  @override
  Future<void> login(String email, String password) async {
    final token = await _remote.login(email, password);
    _tokenStorage.save(token);
  }

  @override
  Future<void> register(String email, String fullName, String password) async {
    await _remote.register(email, fullName, password);
    await login(email, password);
  }

  @override
  Future<User> currentUser() => _remote.me();

  @override
  Future<User> updateProfile({
    String? fullName,
    String? department,
    String? position,
  }) {
    final body = <String, dynamic>{};
    if (fullName != null) body['full_name'] = fullName;
    if (department != null) body['department'] = department;
    if (position != null) body['position'] = position;
    return _remote.updateMe(body);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) =>
      _remote.changePassword(oldPassword, newPassword);

  @override
  void logout() => _tokenStorage.clear();
}