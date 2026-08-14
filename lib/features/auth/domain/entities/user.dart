enum UserRole {
  admin,
  teacher,
  student,
  unknown;

  static UserRole fromString(String? value) => switch (value) {
    'admin' => UserRole.admin,
    'teacher' => UserRole.teacher,
    'student' => UserRole.student,
    _ => UserRole.unknown,
  };

  String get apiValue => switch (this) {
    UserRole.admin => 'admin',
    UserRole.teacher => 'teacher',
    UserRole.student => 'student',
    UserRole.unknown => 'student',
  };

  String get label => switch (this) {
    UserRole.admin => 'Администратор',
    UserRole.teacher => 'Преподаватель',
    UserRole.student => 'Студент',
    UserRole.unknown => 'Студент',
  };
}

class User {
  final int id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? department;
  final String? position;
  final bool isActive;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.department,
    this.position,
    this.isActive = true,
  });

  bool get isStaff => role == UserRole.admin || role == UserRole.teacher;
  bool get isAdmin => role == UserRole.admin;
}