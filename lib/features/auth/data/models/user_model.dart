import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.department,
    super.position,
    super.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] as int,
    email: j['email'] as String,
    fullName: j['full_name'] as String,
    role: UserRole.fromString(j['role'] as String?),
    department: j['department'] as String?,
    position: j['position'] as String?,
    isActive: j['is_active'] as bool? ?? true,
  );
}