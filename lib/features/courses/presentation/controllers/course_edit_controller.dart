import 'package:flutter/foundation.dart';

import '../../../ai/domain/repositories/ai_repository.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/entities/quiz_draft.dart';
import '../../domain/repositories/course_repository.dart';

class CourseEditController extends ChangeNotifier {
  final CourseRepository _repo;
  final AiRepository _aiRepo;

  CourseEditController(this._repo, this._aiRepo);

  int? courseId;
  CourseDetail? course;
  bool loading = false;
  String? error;

  Future<void> load(int id) async {
    courseId = id;
    loading = true;
    error = null;
    notifyListeners();
    try {
      course = await _repo.detail(id);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<CourseDetail> saveMeta({
    required String title,
    required String description,
    required String category,
    required int passScore,
    required bool certificateEnabled,
    required bool isPublished,
  }) async {
    final int id;
    if (courseId == null) {
      final created = await _repo.create(
        title: title,
        description: description,
        category: category,
        passScore: passScore,
        certificateEnabled: certificateEnabled,
      );
      id = created.id;
      // После создания сразу применяем флаг публикации.
      if (isPublished) {
        await _repo.update(id, isPublished: true);
      }
    } else {
      id = courseId!;
      await _repo.update(
        id,
        title: title,
        description: description,
        category: category,
        passScore: passScore,
        certificateEnabled: certificateEnabled,
        isPublished: isPublished,
      );
    }
    final saved = await _repo.detail(id);
    courseId = saved.id;
    course = saved;
    notifyListeners();
    return saved;
  }

  Future<void> addLesson({
    required String title,
    required String content,
    String? videoUrl,
  }) async {
    await _repo.addLesson(
      courseId!,
      title: title,
      content: content,
      videoUrl: videoUrl,
      order: course?.lessons.length ?? 0,
    );
    await load(courseId!);
  }

  Future<void> updateLesson(
      int lessonId, {
        required String title,
        required String content,
        String? videoUrl,
      }) async {
    await _repo.updateLesson(lessonId,
        title: title, content: content, videoUrl: videoUrl);
    await load(courseId!);
  }

  Future<void> deleteLesson(int lessonId) async {
    await _repo.deleteLesson(lessonId);
    await load(courseId!);
  }

  Future<Quiz?> loadQuiz() async {
    try {
      return await _repo.quiz(courseId!);
    } catch (_) {
      return null; // теста ещё нет
    }
  }

  Future<List<QuestionDraft>> generateQuizAI(int numQuestions) =>
      _aiRepo.generateQuiz(courseId!, numQuestions);

  Future<void> saveQuiz(List<QuestionDraft> questions) async {
    await _repo.setQuiz(
      courseId!,
      title: 'Итоговый тест',
      timeLimitMinutes: 0,
      questions: questions,
    );
  }
}
