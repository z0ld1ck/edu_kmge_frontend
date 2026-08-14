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
      final isEnrolled = my.any((m) => m.course.id == courseId);
      Set<int> completed = {};
      if (isEnrolled) {
        completed = (await _learningRepo.completedLessonIds(courseId)).toSet();
      }
      final ai = await _aiRepo.isEnabled();
      course = detail;
      enrolled = isEnrolled;
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
}
