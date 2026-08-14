import 'package:get_it/get_it.dart';

import '../../features/users/domain/repositories/user_repository.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

// AI
import '../../features/ai/data/sources//ai_remote_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';

// Auth
import '../../features/auth/data/sources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';

// Courses
import '../../features/courses/data/sources//course_remote_datasource.dart';
import '../../features/courses/data/repositories/course_repository_impl.dart';
import '../../features/courses/domain/repositories/course_repository.dart';
import '../../features/courses/presentation/controllers/catalog_controller.dart';
import '../../features/courses/presentation/controllers/course_detail_controller.dart';
import '../../features/courses/presentation/controllers/course_edit_controller.dart';
import '../../features/courses/presentation/controllers/quiz_controller.dart';

// Learning
import '../../features/learning/data/sources/learning_remote_datasource.dart';
import '../../features/learning/data/repositories/learning_repository_impl.dart';
import '../../features/learning/domain/repositories/learning_repository.dart';
import '../../features/learning/presentation/controllers/my_courses_controller.dart';

// Certificates
import '../../features/certificates/data/sources/certificate_remote_datasource.dart';
import '../../features/certificates/data/repositories/certificate_repository_impl.dart';
import '../../features/certificates/domain/repositories/certificate_repository.dart';
import '../../features/certificates/presentation/controllers/certificates_controller.dart';

// Analytics
import '../../features/analytics/data/sources/analytics_remote_datasource.dart';
import '../../features/analytics/data/repositories/analytics_repository_impl.dart';
import '../../features/analytics/domain/repositories/analytics_repository.dart';
import '../../features/analytics/presentation/controllers/dashboard_controller.dart';

// Users
import '../../features/users/data/sources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/presentation/controllers/users_controller.dart';

/// Глобальный service locator.
final sl = GetIt.instance;

void setupDependencies() {
  // ---- Core ----
  sl.registerLazySingleton(() => TokenStorage());
  sl.registerLazySingleton(() => ApiClient(sl()));

  // ---- Data sources ----
  sl.registerLazySingleton(() => AuthRemoteDataSource(sl()));
  sl.registerLazySingleton(() => CourseRemoteDataSource(sl()));
  sl.registerLazySingleton(() => LearningRemoteDataSource(sl()));
  sl.registerLazySingleton(() => CertificateRemoteDataSource(sl()));
  sl.registerLazySingleton(() => AnalyticsRemoteDataSource(sl()));
  sl.registerLazySingleton(() => UserRemoteDataSource(sl()));
  sl.registerLazySingleton(() => AiRemoteDataSource(sl()));

  // ---- Repositories ----
  sl.registerLazySingleton<AuthRepository>(
          () => AuthRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<CourseRepository>(() => CourseRepositoryImpl(sl()));
  sl.registerLazySingleton<LearningRepository>(
          () => LearningRepositoryImpl(sl()));
  sl.registerLazySingleton<CertificateRepository>(
          () => CertificateRepositoryImpl(sl()));
  sl.registerLazySingleton<AnalyticsRepository>(
          () => AnalyticsRepositoryImpl(sl()));
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(sl()));
  sl.registerLazySingleton<AiRepository>(() => AiRepositoryImpl(sl()));

  // ---- Global session ----
  sl.registerLazySingleton(() => AuthController(sl()));

  // ---- Page controllers (новый экземпляр на каждый экран) ----
  sl.registerFactory(() => CatalogController(sl()));
  sl.registerFactory(() => CourseDetailController(sl(), sl(), sl()));
  sl.registerFactory(() => QuizController(sl(), sl()));
  sl.registerFactory(() => CourseEditController(sl(), sl()));
  sl.registerFactory(() => MyCoursesController(sl()));
  sl.registerFactory(() => CertificatesController(sl()));
  sl.registerFactory(() => DashboardController(sl(), sl()));
  sl.registerFactory(() => UsersController(sl()));
}
