import 'package:flutter/foundation.dart';

import '../../domain/entities/course.dart';
import '../../domain/repositories/course_repository.dart';

class CatalogController extends ChangeNotifier {
  final CourseRepository _repo;

  CatalogController(this._repo);

  List<Course> courses = [];
  List<String> categories = [];
  String? category;
  String query = '';
  bool loading = true;
  String? error;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repo.list(q: query, category: category),
        _repo.categories(),
      ]);
      courses = results[0] as List<Course>;
      categories = results[1] as List<String>;
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    query = q;
    load();
  }

  void setCategory(String? c) {
    category = c;
    load();
  }
}