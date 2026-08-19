import '../../domain/entities/enrollment.dart';

class EnrollmentModel extends Enrollment {
  const EnrollmentModel({
    required super.id,
    required super.courseId,
    required super.status,
    required super.progress,
    super.dueDate,
    super.isMandatory,
    super.assigned,
    super.isOverdue,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> j) => EnrollmentModel(
    id: j['id'] as int,
    courseId: j['course_id'] as int,
    status: EnrollmentStatus.fromString(j['status'] as String?),
    progress: ((j['progress'] ?? 0) as num).toDouble(),
    dueDate: j['due_date'] != null
        ? DateTime.tryParse(j['due_date'] as String)
        : null,
    isMandatory: (j['is_mandatory'] ?? false) as bool,
    assigned: (j['assigned'] ?? false) as bool,
    isOverdue: (j['is_overdue'] ?? false) as bool,
  );
}