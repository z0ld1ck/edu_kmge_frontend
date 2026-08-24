/// Материал урока — ссылка на внешний ресурс (файл в приложении не хранится).
class LessonMaterial {
  final String? id;
  final String title;
  final String url;
  final String type; // pdf | doc | video | image | link
  final bool file; // true — загруженный файл (встроенный просмотр)


  const LessonMaterial({
    this.id,
    required this.title,
    required this.url,
    this.type = 'link',
    this.file = false,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'url': url, 'type': type, 'file': file};

  factory LessonMaterial.fromJson(Map<String, dynamic> j) => LessonMaterial(
    id: j['id']?.toString(),
    title: (j['title'] ?? '').toString(),
    url: (j['url'] ?? '').toString(),
    type: (j['type'] ?? 'link').toString(),
    file: j['file'] == true, // устойчиво к null / отсутствию поля
  );
}

class Lesson {
  final int id;
  final int courseId;
  final String title;
  final String content;
  final String? videoUrl;
  final int order;
  final List<LessonMaterial> materials;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.content,
    this.videoUrl,
    required this.order,
    this.materials = const [],
  });
}
