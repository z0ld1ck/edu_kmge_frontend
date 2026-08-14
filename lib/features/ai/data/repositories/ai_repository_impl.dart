import '../../../courses/domain/entities/quiz_draft.dart';
import '../../domain/repositories/ai_repository.dart';
import '../sources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remote;

  AiRepositoryImpl(this._remote);

  @override
  Future<bool> isEnabled() async {
    try {
      return await _remote.status();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> chat(
      int courseId, String message, List<Map<String, String>> history) =>
      _remote.chat(courseId, message, history);

  @override
  Future<List<QuestionDraft>> generateQuiz(int courseId, int numQuestions) async {
    final data = await _remote.generateQuiz(courseId, numQuestions);
    final questions = (data['questions'] as List?) ?? const [];
    return [
      for (final q in questions)
        QuestionDraft(
          text: (q['text'] ?? '') as String,
          answers: [
            for (final a in (q['answers'] as List? ?? const []))
              AnswerDraft(
                text: (a['text'] ?? '') as String,
                isCorrect: (a['is_correct'] ?? false) as bool,
              ),
          ],
        ),
    ];
  }
}
