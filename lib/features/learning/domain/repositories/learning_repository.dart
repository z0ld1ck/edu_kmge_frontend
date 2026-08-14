import '../entities/attempt.dart';
import '../entities/enrollment.dart';
import '../entities/my_course.dart';
import '../entities/quiz_result.dart';

abstract class LearningRepository {
  Future<void> enroll(int courseId);

  Future<List<MyCourse>> myCourses();

  Future<List<int>> completedLessonIds(int courseId);

  Future<Enrollment> completeLesson(int lessonId);

  Future<QuizResult> submitQuiz(int courseId, Map<int, int> answers);

  Future<List<Attempt>> myAttempts();
}
