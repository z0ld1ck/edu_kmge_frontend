class Lesson {
  final int id;
  final int courseId;
  final String title;
  final String content;
  final String? videoUrl;
  final int order;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.order,
  });
}
