import '../../../courses/data/models/course_model.dart';
import '../../domain/entities/my_course.dart';
import 'enrollment_model.dart';

class MyCourseModel extends MyCourse {
  const MyCourseModel({required super.course, required super.enrollment});

  factory MyCourseModel.fromJson(Map<String, dynamic> j) => MyCourseModel(
    course: CourseModel.fromJson(j['course'] as Map<String, dynamic>),
    enrollment:
    EnrollmentModel.fromJson(j['enrollment'] as Map<String, dynamic>),
  );
}
