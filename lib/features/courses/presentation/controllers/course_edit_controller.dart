import 'package:flutter/foundation.dart';

import '../../../ai/domain/repositories/ai_repository.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/lesson.dart';
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
    List<LessonMaterial> materials = const [],
  }) async {
    await _repo.addLesson(
      courseId!,
      title: title,
      content: content,
      videoUrl: videoUrl,
      order: course?.lessons.length ?? 0,
      materials: materials,
    );
    await load(courseId!);
  }

  Future<void> updateLesson(
    int lessonId, {
    required String title,
    required String content,
    String? videoUrl,
    List<LessonMaterial>? materials,
  }) async {
    await _repo.updateLesson(
      lessonId,
      title: title,
      content: content,
      videoUrl: videoUrl,
      materials: materials,
    );
    await load(courseId!);
  }

  // ---- Материалы (действия сразу применяются на сервере) ----
  Future<Lesson> addMaterialLink(
    int lessonId, {
    required String title,
    required String url,
    String type = 'link',
  }) async {
    final lesson = await _repo.addMaterialLink(
      lessonId,
      title: title,
      url: url,
      type: type,
    );
    await load(courseId!);
    return lesson;
  }

  Future<Lesson> uploadMaterial(
    int lessonId, {
    required List<int> bytes,
    required String filename,
    required String title,
  }) async {
    final lesson = await _repo.uploadMaterial(
      lessonId,
      bytes: bytes,
      filename: filename,
      title: title,
    );
    await load(courseId!);
    return lesson;
  }

  Future<Lesson> deleteMaterial(int lessonId, String materialId) async {
    final lesson = await _repo.deleteMaterial(lessonId, materialId);
    await load(courseId!);
    return lesson;
  }

  Future<void> deleteLesson(int lessonId) async {
    await _repo.deleteLesson(lessonId);
    await load(courseId!);
  }

  /// Перетаскивание урока: oldIndex → newIndex (индексы ReorderableListView).
  Future<void> reorderLessons(int oldIndex, int newIndex) async {
    final current = course;
    if (current == null) return;
    final list = List<Lesson>.of(current.lessons);
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    // Оптимистично показываем новый порядок сразу.
    course = current.copyWith(lessons: list);
    notifyListeners();
    try {
      await _repo.reorderLessons(courseId!, [for (final l in list) l.id]);
    } catch (e) {
      error = e.toString();
      await load(courseId!); // откатываемся к серверному порядку
    }
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
