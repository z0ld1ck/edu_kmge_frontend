class Answer {
  final int id;
  final String text;

  const Answer({required this.id, required this.text});
}

class Question {
  final int id;
  final String text;
  final int order;
  final List<Answer> answers;

  const Question({
    required this.id,
    required this.text,
    required this.order,
    required this.answers,
  });
}

class Quiz {
  final int id;
  final int courseId;
  final String title;
  final int timeLimitMinutes;
  final List<Question> questions;

  const Quiz({
    required this.id,
    required this.courseId,
    required this.title,
    required this.timeLimitMinutes,
    required this.questions,
  });
}