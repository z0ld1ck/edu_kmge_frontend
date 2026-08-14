import 'lesson.dart';

class Course {
  final int id;
  final String title;
  final String description;
  final String category;
  final bool isPublished;
  final int passScore;
  final bool certificateEnabled;
  final int lessonsCount;
  final bool hasQuiz;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isPublished,
    required this.passScore,
    required this.certificateEnabled,
    required this.lessonsCount,
    required this.hasQuiz,
  });
}

/// Курс с полным списком уроков (страница курса / редактирование).
class CourseDetail extends Course {
  final List<Lesson> lessons;

  const CourseDetail({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.isPublished,
    required super.passScore,
    required super.certificateEnabled,
    required super.lessonsCount,
    required super.hasQuiz,
    required this.lessons,
  });
}
