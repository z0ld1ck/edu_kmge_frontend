import '../../domain/entities/course.dart';
import 'lesson_model.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.isPublished,
    required super.passScore,
    required super.certificateEnabled,
    required super.lessonsCount,
    required super.hasQuiz,
  });

  factory CourseModel.fromJson(Map<String, dynamic> j) => CourseModel(
    id: j['id'] as int,
    title: j['title'] as String,
    description: (j['description'] ?? '') as String,
    category: (j['category'] ?? 'Общее') as String,
    isPublished: (j['is_published'] ?? false) as bool,
    passScore: (j['pass_score'] ?? 80) as int,
    certificateEnabled: (j['certificate_enabled'] ?? true) as bool,
    lessonsCount: (j['lessons_count'] ?? 0) as int,
    hasQuiz: (j['has_quiz'] ?? false) as bool,
  );
}

class CourseDetailModel extends CourseDetail {
  const CourseDetailModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.isPublished,
    required super.passScore,
    required super.certificateEnabled,
    required super.lessonsCount,
    required super.hasQuiz,
    required super.lessons,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> j) =>
      CourseDetailModel(
        id: j['id'] as int,
        title: j['title'] as String,
        description: (j['description'] ?? '') as String,
        category: (j['category'] ?? 'Общее') as String,
        isPublished: (j['is_published'] ?? false) as bool,
        passScore: (j['pass_score'] ?? 80) as int,
        certificateEnabled: (j['certificate_enabled'] ?? true) as bool,
        lessonsCount: (j['lessons_count'] ?? 0) as int,
        hasQuiz: (j['has_quiz'] ?? false) as bool,
        lessons: ((j['lessons'] as List?) ?? const [])
            .map((e) => LessonModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
