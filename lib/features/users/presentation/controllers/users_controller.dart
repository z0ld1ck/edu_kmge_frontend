import 'package:flutter/foundation.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/import_result.dart';
import '../../domain/repositories/user_repository.dart';

class UsersController extends ChangeNotifier {
  final UserRepository _repo;

  UsersController(this._repo);

  List<User> users = [];
  bool loading = true;
  String? error;
  String query = '';

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      users = await _repo.list(q: query);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    query = q;
    load();
  }

  Future<void> create({
    required String email,
    required String fullName,
    String? department,
    String? position,
    required UserRole role,
    required String password,
  }) async {
    await _repo.create(
      email: email,
      fullName: fullName,
      department: department,
      position: position,
      role: role,
      password: password,
    );
    await load();
  }

  Future<void> update(
      int id, {
        String? fullName,
        String? department,
        String? position,
        UserRole? role,
        String? password,
      }) async {
    await _repo.update(
      id,
      fullName: fullName,
      department: department,
      position: position,
      role: role,
      password: password,
    );
    await load();
  }

  Future<void> delete(int id) async {
    await _repo.delete(id);
    await load();
  }

  Future<UserImportResult> importUsers(
      {required List<int> bytes, required String filename}) async {
    final result = await _repo.importUsers(bytes: bytes, filename: filename);
    await load();
    return result;
  }
}
