import '../../../auth/domain/entities/user.dart';
import '../entities/import_result.dart';

abstract class UserRepository {
  Future<List<User>> list({String? q});

  Future<User> create({
    required String email,
    required String fullName,
    String? department,
    String? position,
    required UserRole role,
    required String password,
  });

  Future<void> update(
      int id, {
        String? fullName,
        String? department,
        String? position,
        UserRole? role,
        String? password,
      });

  Future<void> delete(int id);

  Future<UserImportResult> importUsers(
      {required List<int> bytes, required String filename});
}
