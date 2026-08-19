import '../../domain/entities/assignment.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../datasources/assignment_remote_datasource.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentRemoteDataSource _remote;

  AssignmentRepositoryImpl(this._remote);

  @override
  Future<List<Assignment>> list({
    int? courseId,
    String? department,
    String? status,
  }) =>
      _remote.list(courseId: courseId, department: department, status: status);

  @override
  Future<int> assign({
    required int courseId,
    List<int> userIds = const [],
    String? department,
    DateTime? dueDate,
    required bool isMandatory,
  }) =>
      _remote.create({
        'course_id': courseId,
        'user_ids': userIds,
        if (department != null && department.isNotEmpty)
          'department': department,
        if (dueDate != null)
          'due_date': DateTime(dueDate.year, dueDate.month, dueDate.day)
              .toIso8601String(),
        'is_mandatory': isMandatory,
      });

  @override
  Future<void> remove(int enrollmentId) => _remote.remove(enrollmentId);
}
