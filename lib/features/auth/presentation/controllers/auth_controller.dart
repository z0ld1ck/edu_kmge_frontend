import 'package:flutter/foundation.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Глобальное состояние сессии. Слушается роутером (redirect по auth).
class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  AuthController(this._repo);

  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get isLoading => _loading;
  bool get isAuthenticated => _user != null;

  Future<void> bootstrap() async {
    if (_repo.token != null) {
      try {
        _user = await _repo.currentUser();
      } catch (_) {
        _repo.logout();
      }
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _repo.login(email, password);
    _user = await _repo.currentUser();
    notifyListeners();
  }

  Future<void> register(String email, String fullName, String password) async {
    await _repo.register(email, fullName, password);
    _user = await _repo.currentUser();
    notifyListeners();
  }

  Future<void> refreshProfile({
    String? fullName,
    String? department,
    String? position,
  }) async {
    _user = await _repo.updateProfile(
      fullName: fullName,
      department: department,
      position: position,
    );
    notifyListeners();
  }

  Future<void> changePassword(String oldPassword, String newPassword) =>
      _repo.changePassword(oldPassword, newPassword);

  void logout() {
    _repo.logout();
    _user = null;
    notifyListeners();
  }
}