import 'package:flutter/foundation.dart';

import '../../../ai/domain/repositories/ai_repository.dart';
import '../../../learning/domain/repositories/learning_repository.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

class CourseDetailController extends ChangeNotifier {
  final CourseRepository _courseRepo;
  final LearningRepository _learningRepo;
  final AiRepository _aiRepo;

  CourseDetailController(this._courseRepo, this._learningRepo, this._aiRepo);

  CourseDetail? course;
  bool enrolled = false;
  bool courseCompleted = false;
  Set<int> completedLessonIds = {};
  bool aiEnabled = false;
  bool loading = true;
  String? error;

  Future<void> load(int courseId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final detail = await _courseRepo.detail(courseId);
      final my = await _learningRepo.myCourses();
      final mine = my.where((m) => m.course.id == courseId).toList();
      final isEnrolled = mine.isNotEmpty;
      final completedCourse =
          isEnrolled && mine.first.enrollment.status.isCompleted;
      Set<int> completed = {};
      if (isEnrolled) {
        completed = (await _learningRepo.completedLessonIds(courseId)).toSet();
      }
      final ai = await _aiRepo.isEnabled();
      course = detail;
      enrolled = isEnrolled;
      courseCompleted = completedCourse;
      completedLessonIds = completed;
      aiEnabled = ai;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> enroll(int courseId) async {
    await _learningRepo.enroll(courseId);
    await load(courseId);
  }

  Future<void> completeLesson(int lessonId) async {
    await _learningRepo.completeLesson(lessonId);
    completedLessonIds.add(lessonId);
    notifyListeners();
  }

  int get totalLessons => course?.lessons.length ?? 0;
  int get doneLessons =>
      course?.lessons.where((l) => completedLessonIds.contains(l.id)).length ?? 0;
  bool get allLessonsDone => totalLessons > 0 && doneLessons == totalLessons;

  bool isLessonDone(int lessonId) => completedLessonIds.contains(lessonId);

  /// Урок с индексом [index] открыт, если пройдены все предыдущие уроки.
  bool isLessonUnlocked(int index) {
    if (!enrolled) return false;
    final lessons = course?.lessons ?? const [];
    for (var i = 0; i < index && i < lessons.length; i++) {
      if (!completedLessonIds.contains(lessons[i].id)) return false;
    }
    return true;
  }

  /// Индекс текущего (первого доступного и не пройденного) урока, иначе null.
  int? get currentLessonIndex {
    final lessons = course?.lessons ?? const [];
    for (var i = 0; i < lessons.length; i++) {
      if (!completedLessonIds.contains(lessons[i].id)) {
        return isLessonUnlocked(i) ? i : null;
      }
    }
    return null;
  }
}