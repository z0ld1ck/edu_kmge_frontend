import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/pages/admin_dashboard_page.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/certificates/presentation/pages/certificates_page.dart';
import '../../features/courses/presentation/pages/admin_course_edit_page.dart';
import '../../features/courses/presentation/pages/catalog_page.dart';
import '../../features/courses/presentation/pages/course_detail_page.dart';
import '../../features/learning/presentation/pages/my_courses_page.dart';
import '../../features/users/presentation/pages/admin_users_page.dart';

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
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/catalog', builder: (c, s) => const CatalogPage()),
      GoRoute(path: '/my', builder: (c, s) => const MyCoursesPage()),
      GoRoute(
          path: '/certificates',
          builder: (c, s) => const CertificatesPage()),
      GoRoute(
        path: '/courses/:id',
        builder: (c, s) =>
            CourseDetailPage(courseId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(path: '/admin', builder: (c, s) => const AdminDashboardPage()),
      GoRoute(
          path: '/admin/users', builder: (c, s) => const AdminUsersPage()),
      GoRoute(
        path: '/admin/courses/new',
        builder: (c, s) => const AdminCourseEditPage(courseId: null),
      ),
      GoRoute(
        path: '/admin/courses/:id',
        builder: (c, s) => AdminCourseEditPage(
            courseId: int.parse(s.pathParameters['id']!)),
      ),
    ],
    errorBuilder: (c, s) => Scaffold(
      body: Center(child: Text('Страница не найдена: ${s.uri}')),
    ),
  );
}
