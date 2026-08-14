import '../../../auth/domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../sources//user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl(this._remote);

  @override
  Future<List<User>> list({String? q}) => _remote.list(q: q);

  @override
  Future<User> create({
    required String email,
    required String fullName,
    String? department,
    String? position,
    required UserRole role,
    required String password,
  }) =>
      _remote.create({
        'email': email,
        'full_name': fullName,
        'department': department,
        'position': position,
        'role': role.apiValue,
        'password': password,
      });

  @override
  Future<void> update(
      int id, {
        String? fullName,
        String? department,
        String? position,
        UserRole? role,
        String? password,
      }) =>
      _remote.update(id, {
        if (fullName != null) 'full_name': fullName,
        if (department != null) 'department': department,
        if (position != null) 'position': position,
        if (role != null) 'role': role.apiValue,
        if (password != null && password.isNotEmpty) 'password': password,
      });

  @override
  Future<void> delete(int id) => _remote.delete(id);
}
