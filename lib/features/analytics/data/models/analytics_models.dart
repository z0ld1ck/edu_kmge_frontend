import '../../domain/entities/analytics.dart';

class OverviewStatsModel extends OverviewStats {
  const OverviewStatsModel({
    required super.totalUsers,
    required super.totalCourses,
    required super.totalEnrollments,
    required super.completedEnrollments,
    required super.certificatesIssued,
    required super.completionRate,
  });

  factory OverviewStatsModel.fromJson(Map<String, dynamic> j) =>
      OverviewStatsModel(
        totalUsers: (j['total_users'] ?? 0) as int,
        totalCourses: (j['total_courses'] ?? 0) as int,
        totalEnrollments: (j['total_enrollments'] ?? 0) as int,
        completedEnrollments: (j['completed_enrollments'] ?? 0) as int,
        certificatesIssued: (j['certificates_issued'] ?? 0) as int,
        completionRate: ((j['completion_rate'] ?? 0) as num).toDouble(),
      );
}

class CourseStatModel extends CourseStat {
  const CourseStatModel({
    required super.courseId,
    required super.title,
    required super.category,
    required super.enrolled,
    required super.completed,
    required super.avgProgress,
    super.avgScore,
  });

  factory CourseStatModel.fromJson(Map<String, dynamic> j) => CourseStatModel(
    courseId: j['course_id'] as int,
    title: j['title'] as String,
    category: j['category'] as String,
    enrolled: (j['enrolled'] ?? 0) as int,
    completed: (j['completed'] ?? 0) as int,
    avgProgress: ((j['avg_progress'] ?? 0) as num).toDouble(),
    avgScore: j['avg_score'] == null
        ? null
        : (j['avg_score'] as num).toDouble(),
  );
}

class UserProgressStatModel extends UserProgressStat {
  const UserProgressStatModel({
    required super.userId,
    required super.fullName,
    super.department,
    required super.enrolled,
    required super.completed,
    required super.avgProgress,
  });

  factory UserProgressStatModel.fromJson(Map<String, dynamic> j) =>
      UserProgressStatModel(
        userId: j['user_id'] as int,
        fullName: j['full_name'] as String,
        department: j['department'] as String?,
        enrolled: (j['enrolled'] ?? 0) as int,
        completed: (j['completed'] ?? 0) as int,
        avgProgress: ((j['avg_progress'] ?? 0) as num).toDouble(),
      );
}
