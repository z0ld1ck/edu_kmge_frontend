import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

void main() {
  setupDependencies();
  runApp(const KmgeEduApp());
}

class KmgeEduApp extends StatefulWidget {
  const KmgeEduApp({super.key});

  @override
  State<KmgeEduApp> createState() => _KmgeEduAppState();
}

class _KmgeEduAppState extends State<KmgeEduApp> {
  final AuthController _auth = sl<AuthController>();
  late final _router = buildRouter(_auth);

  @override
  void initState() {
    super.initState();
    _auth.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
      ],
      child: MaterialApp.router(
        title: 'KMGE Edu — СДО',
        debugShowCheckedModeBanner: false,
        theme: buildLightTheme(),
        themeMode: ThemeMode.light,
        routerConfig: _router,
      ),
    );
  }
}