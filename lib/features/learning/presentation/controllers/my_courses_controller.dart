import 'package:flutter/foundation.dart';

import '../../domain/entities/my_course.dart';
import '../../domain/repositories/learning_repository.dart';

class MyCoursesController extends ChangeNotifier {
  final LearningRepository _repo;

  MyCoursesController(this._repo);

  List<MyCourse> items = [];
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      items = await _repo.myCourses();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
