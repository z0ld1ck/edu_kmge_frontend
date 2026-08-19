import '../../../learning/domain/entities/enrollment.dart';
import '../../domain/entities/assignment.dart';

class AssignmentModel extends Assignment {
  const AssignmentModel({
    required super.enrollmentId,
    required super.userId,
    required super.userName,
    required super.department,
    required super.courseId,
    required super.courseTitle,
    required super.status,
    required super.progress,
    required super.dueDate,
    required super.isMandatory,
    required super.isOverdue,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> j) => AssignmentModel(
    enrollmentId: j['enrollment_id'] as int,
    userId: j['user_id'] as int,
    userName: j['user_name'] as String,
    department: j['department'] as String?,
    courseId: j['course_id'] as int,
    courseTitle: j['course_title'] as String,
    status: EnrollmentStatus.fromString(j['status'] as String?),
    progress: ((j['progress'] ?? 0) as num).toDouble(),
    dueDate: j['due_date'] != null
        ? DateTime.tryParse(j['due_date'] as String)
        : null,
    isMandatory: (j['is_mandatory'] ?? false) as bool,
    isOverdue: (j['is_overdue'] ?? false) as bool,
  );
}
