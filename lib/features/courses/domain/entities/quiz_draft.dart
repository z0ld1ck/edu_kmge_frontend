/// Черновик вопроса для создания/замены теста (админ + AI-генерация).
class AnswerDraft {
  String text;
  bool isCorrect;
  AnswerDraft({this.text = '', this.isCorrect = false});
}

class QuestionDraft {
  String text;
  List<AnswerDraft> answers;
  QuestionDraft({this.text = '', List<AnswerDraft>? answers})
      : answers = answers ?? [];
}