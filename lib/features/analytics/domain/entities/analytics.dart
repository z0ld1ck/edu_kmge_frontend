class OverviewStats {
  final int totalUsers;
  final int totalCourses;
  final int totalEnrollments;
  final int completedEnrollments;
  final int certificatesIssued;
  final double completionRate;

  const OverviewStats({
    required this.totalUsers,
    required this.totalCourses,
    required this.totalEnrollments,
    required this.completedEnrollments,
    required this.certificatesIssued,
    required this.completionRate,
  });
}

class CourseStat {
  final int courseId;
  final String title;
  final String category;
  final int enrolled;
  final int completed;
  final double avgProgress;
  final double? avgScore;

  const CourseStat({
    required this.courseId,
    required this.title,
    required this.category,
    required this.enrolled,
    required this.completed,
    required this.avgProgress,
    this.avgScore,
  });
}

class UserProgressStat {
  final int userId;
  final String fullName;
  final String? department;
  final int enrolled;
  final int completed;
  final double avgProgress;

  const UserProgressStat({
    required this.userId,
    required this.fullName,
    this.department,
    required this.enrolled,
    required this.completed,
    required this.avgProgress,
  });
}
