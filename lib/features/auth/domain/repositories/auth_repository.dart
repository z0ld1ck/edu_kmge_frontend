import '../entities/user.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String fullName, String password);
  Future<User> currentUser();
  Future<User> updateProfile({
    String? fullName,
    String? department,
    String? position,
  });
  Future<void> changePassword(String oldPassword, String newPassword);
  String? get token;
  void logout();
}