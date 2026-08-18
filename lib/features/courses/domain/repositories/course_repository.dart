import '../entities/course.dart';
import '../entities/lesson.dart';
import '../entities/quiz.dart';
import '../entities/quiz_draft.dart';

abstract class CourseRepository {
  Future<List<Course>> list({String? q, String? category, bool publishedOnly});

  Future<List<String>> categories();

  Future<CourseDetail> detail(int id);

  Future<CourseDetail> create({
    required String title,
    required String description,
    required String category,
    required int passScore,
    required bool certificateEnabled,
  });

  Future<CourseDetail> update(
      int id, {
        String? title,
        String? description,
        String? category,
        int? passScore,
        bool? certificateEnabled,
        bool? isPublished,
      });

  Future<void> deleteCourse(int id);

  Future<Lesson> addLesson(
      int courseId, {
        required String title,
        required String content,
        String? videoUrl,
        required int order,
      });

  Future<void> updateLesson(
      int lessonId, {
        String? title,
        String? content,
        String? videoUrl,
      });

  Future<void> deleteLesson(int lessonId);

  Future<Quiz> quiz(int courseId);

  Future<Quiz> setQuiz(
      int courseId, {
        required String title,
        required int timeLimitMinutes,
        required List<QuestionDraft> questions,
      });
}