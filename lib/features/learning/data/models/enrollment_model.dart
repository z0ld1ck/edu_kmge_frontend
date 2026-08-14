import '../../domain/entities/enrollment.dart';

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.id,
    required super.courseId,
    required super.status,
    required super.progress,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> j) => EnrollmentModel(
    id: j['id'] as int,
    courseId: j['course_id'] as int,
    status: EnrollmentStatus.fromString(j['status'] as String?),
    progress: ((j['progress'] ?? 0) as num).toDouble(),
  );
}
