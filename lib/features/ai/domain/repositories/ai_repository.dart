import '../../../courses/domain/entities/quiz_draft.dart';

abstract class AiRepository {
  Future<bool> isEnabled();

  Future<String> chat(
      int courseId,
      String message,
      List<Map<String, String>> history,
      );

  /// Черновик вопросов теста, сгенерированный AI из материалов курса.
  Future<List<QuestionDraft>> generateQuiz(int courseId, int numQuestions);
}
