import '../entities/assignment.dart';

abstract class AssignmentRepository {
  Future<List<Assignment>> list({
    int? courseId,
    String? department,
    String? status, // overdue | pending | completed
  });

  /// Возвращает число созданных/обновлённых назначений.
  Future<int> assign({
    required int courseId,
    List<int> userIds,
    String? department,
    DateTime? dueDate,
    required bool isMandatory,
  });

  Future<void> remove(int enrollmentId);
}
