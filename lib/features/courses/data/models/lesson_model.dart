import '../../domain/entities/lesson.dart';

class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.title,
    required super.content,
    super.videoUrl,
    required super.order,
  });

  factory LessonModel.fromJson(Map<String, dynamic> j) => LessonModel(
    id: j['id'] as int,
    courseId: j['course_id'] as int,
    title: j['title'] as String,
    content: (j['content'] ?? '') as String,
    videoUrl: j['video_url'] as String?,
    order: (j['order'] ?? 0) as int,
  );
}