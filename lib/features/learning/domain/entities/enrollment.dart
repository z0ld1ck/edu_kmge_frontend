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

  const Enrollment({
    required this.id,
    required this.courseId,
    required this.status,
    required this.progress,
  });
}
