import 'package:flutter/foundation.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/repositories/course_repository.dart';
import '../../../users/domain/repositories/user_repository.dart';
import '../../domain/entities/assignment.dart';
import '../../domain/repositories/assignment_repository.dart';

class AssignmentsController extends ChangeNotifier {
  final AssignmentRepository _repo;
  final CourseRepository _courses;
  final UserRepository _users;

  AssignmentsController(this._repo, this._courses, this._users);

  bool loading = false;
  String? error;
  List<Assignment> items = [];

  // Справочники для диалога назначения.
  List<Course> courses = [];
  List<User> allUsers = [];

  // Фильтры списка.
  int? filterCourseId;
  String? filterStatus; // overdue | pending | completed

  List<String> get departments {
    final set = <String>{};
    for (final u in allUsers) {
      final d = u.department;
      if (d != null && d.trim().isNotEmpty) set.add(d.trim());
    }
    final list = set.toList()..sort();
    return list;
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.list(
        courseId: filterCourseId,
        status: filterStatus,
      );
      // Справочники грузим один раз.
      if (courses.isEmpty) {
        courses = await _courses.list(publishedOnly: false);
      }
      if (allUsers.isEmpty) {
        allUsers = await _users.list();
      }
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setCourseFilter(int? id) async {
    filterCourseId = id;
    await load();
  }

  Future<void> setStatusFilter(String? status) async {
    filterStatus = status;
    await load();
  }

  /// Назначение курса. Возвращает число назначенных или null при ошибке.
  Future<int?> assign({
    required int courseId,
    required List<int> userIds,
    String? department,
    DateTime? dueDate,
    required bool isMandatory,
  }) async {
    try {
      final n = await _repo.assign(
        courseId: courseId,
        userIds: userIds,
        department: department,
        dueDate: dueDate,
        isMandatory: isMandatory,
      );
      await load();
      return n;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> remove(int enrollmentId) async {
    try {
      await _repo.remove(enrollmentId);
      items = items.where((a) => a.enrollmentId != enrollmentId).toList();
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
