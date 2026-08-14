import '../../domain/entities/quiz.dart';

class AnswerModel extends Answer {
  const AnswerModel({required super.id, required super.text});

  factory AnswerModel.fromJson(Map<String, dynamic> j) =>
      AnswerModel(id: j['id'] as int, text: j['text'] as String);
}

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.order,
    required super.answers,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> j) => QuestionModel(
    id: j['id'] as int,
    text: j['text'] as String,
    order: (j['order'] ?? 0) as int,
    answers: ((j['answers'] as List?) ?? const [])
        .map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class QuizModel extends Quiz {
  const QuizModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.timeLimitMinutes,
    required super.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> j) => QuizModel(
    id: j['id'] as int,
    courseId: j['course_id'] as int,
    title: j['title'] as String,
    timeLimitMinutes: (j['time_limit_minutes'] ?? 0) as int,
    questions: ((j['questions'] as List?) ?? const [])
        .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
