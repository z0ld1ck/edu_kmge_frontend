import 'package:flutter/foundation.dart';

import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/repositories/course_repository.dart';
import '../../domain/entities/analytics.dart';
import '../../domain/repositories/analytics_repository.dart';

class DashboardController extends ChangeNotifier {
  final AnalyticsRepository _analytics;
  final CourseRepository _courseRepo;

  DashboardController(this._analytics, this._courseRepo);

  OverviewStats? overview;
  List<CourseStat> courseStats = [];
  List<Course> courses = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _analytics.overview(),
        _analytics.courseStats(),
        _courseRepo.list(publishedOnly: false),
      ]);
      overview = results[0] as OverviewStats;
      courseStats = results[1] as List<CourseStat>;
      courses = results[2] as List<Course>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourse(int id) async {
    await _courseRepo.deleteCourse(id);
    await load();
  }

  Future<void> exportUsers() => _analytics.exportUsersXlsx();

  CourseStat? statFor(int courseId) {
    for (final s in courseStats) {
      if (s.courseId == courseId) return s;
    }
    return null;
  }
}
