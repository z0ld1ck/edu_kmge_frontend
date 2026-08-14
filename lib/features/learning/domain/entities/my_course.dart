import '../../../courses/domain/entities/course.dart';
import 'enrollment.dart';

/// Курс вместе с прогрессом текущего пользователя.
class MyCourse {
  final Course course;
  final Enrollment enrollment;

  const MyCourse({required this.course, required this.enrollment});
}
