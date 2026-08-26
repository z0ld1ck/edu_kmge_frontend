import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/analytics/presentation/pages/admin_dashboard_page.dart';
import '../../features/assignments/presentation/pages/admin_assignments_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/certificates/presentation/pages/certificates_page.dart';
import '../../features/courses/presentation/pages/admin_course_edit_page.dart';
import '../../features/courses/presentation/pages/catalog_page.dart';
import '../../features/courses/presentation/pages/course_path_page.dart';
import '../../features/learning/presentation/pages/my_courses_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/users/presentation/pages/admin_users_page.dart';

/// Маршрут без анимации перехода (страницы не «накладываются» при смене).
GoRoute _route(String path, Widget child) => GoRoute(
  path: path,
  pageBuilder: (c, s) => NoTransitionPage(child: child),
);

GoRouter buildRouter(AuthController auth) {
  return GoRouter(
    initialLocation: '/catalog',
    refreshListenable: auth,
    redirect: (context, state) {
      if (auth.isLoading) return null;
      final loc = state.matchedLocation;
      final loggingIn = loc == '/login' || loc == '/register';
      if (!auth.isAuthenticated) return loggingIn ? null : '/login';
      if (loggingIn) return '/catalog';
      if (loc.startsWith('/admin') && !(auth.user?.isStaff ?? false)) {
        return '/catalog';
      }
      return null;
    },
    routes: [
      _route('/login', const LoginPage()),
      _route('/register', const RegisterPage()),
      _route('/catalog', const CatalogPage()),
      _route('/my', const MyCoursesPage()),
      _route('/certificates', const CertificatesPage()),
      _route('/profile', const ProfilePage()),
      GoRoute(
        path: '/courses/:id',
        pageBuilder: (c, s) => NoTransitionPage(
          child: CoursePathPage(courseId: int.parse(s.pathParameters['id']!)),
        ),
      ),
      _route('/admin', const AdminDashboardPage()),
      _route('/admin/users', const AdminUsersPage()),
      _route('/admin/assignments', const AdminAssignmentsPage()),
      GoRoute(
        path: '/admin/courses/new',
        pageBuilder: (c, s) =>
            const NoTransitionPage(child: AdminCourseEditPage(courseId: null)),
      ),
      GoRoute(
        path: '/admin/courses/:id',
        pageBuilder: (c, s) => NoTransitionPage(
          child: AdminCourseEditPage(
            courseId: int.parse(s.pathParameters['id']!),
          ),
        ),
      ),
    ],
    errorBuilder: (c, s) =>
        Scaffold(body: Center(child: Text('Страница не найдена: ${s.uri}'))),
  );
}
