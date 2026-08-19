import '../../../learning/domain/entities/enrollment.dart';

/// Строка списка назначений (курс, назначенный сотруднику).
class Assignment {
  final int enrollmentId;
  final int userId;
  final String userName;
  final String? department;
  final int courseId;
  final String courseTitle;
  final EnrollmentStatus status;
  final double progress; // 0..100
  final DateTime? dueDate;
  final bool isMandatory;
  final bool isOverdue;

  const Assignment({
    required this.enrollmentId,
    required this.userId,
    required this.userName,
    required this.department,
    required this.courseId,
    required this.courseTitle,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.isMandatory,
    required this.isOverdue,
  });

  int? get daysLeft {
    final d = dueDate;
    if (d == null) return null;
    final now = DateTime.now();
    final due = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }
}
