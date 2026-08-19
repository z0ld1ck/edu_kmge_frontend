enum EnrollmentStatus {
  enrolled,
  inProgress,
  completed,
  unknown;

  static EnrollmentStatus fromString(String? v) => switch (v) {
    'enrolled' => EnrollmentStatus.enrolled,
    'in_progress' => EnrollmentStatus.inProgress,
    'completed' => EnrollmentStatus.completed,
    _ => EnrollmentStatus.unknown,
  };

  bool get isCompleted => this == EnrollmentStatus.completed;
}

class Enrollment {
  final int id;
  final int courseId;
  final EnrollmentStatus status;
  final double progress; // 0..100
  final DateTime? dueDate; // срок сдачи (если назначено)
  final bool isMandatory; // обязательный курс
  final bool assigned; // назначен админом (а не самозапись)
  final bool isOverdue; // срок истёк и курс не завершён

  const Enrollment({
    required this.id,
    required this.courseId,
    required this.status,
    required this.progress,
    this.dueDate,
    this.isMandatory = false,
    this.assigned = false,
    this.isOverdue = false,
  });

  /// Дней до дедлайна (отрицательное — просрочка). null — срока нет.
  int? get daysLeft {
    final d = dueDate;
    if (d == null) return null;
    final now = DateTime.now();
    final due = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }
}