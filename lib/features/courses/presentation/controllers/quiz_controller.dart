import 'package:flutter/foundation.dart';

import '../../../learning/domain/entities/quiz_result.dart';
import '../../../learning/domain/repositories/learning_repository.dart';
import '../../domain/entities/quiz.dart';
import '../../domain/repositories/course_repository.dart';

class QuizController extends ChangeNotifier {
  final CourseRepository _courseRepo;
  final LearningRepository _learningRepo;

  QuizController(this._courseRepo, this._learningRepo);

  Quiz? quiz;
  final Map<int, int> selected = {}; // questionId -> answerId
  bool loading = true;
  bool submitting = false;
  String? error;
  QuizResult? result;

  Future<void> load(int courseId) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      quiz = await _courseRepo.quiz(courseId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void select(int questionId, int answerId) {
    selected[questionId] = answerId;
    notifyListeners();
  }

  bool get allAnswered =>
      quiz != null && selected.length >= quiz!.questions.length;

  Future<void> submit(int courseId) async {
    submitting = true;
    notifyListeners();
    try {
      result = await _learningRepo.submitQuiz(courseId, selected);
    } catch (e) {
      error = e.toString();
    } finally {
      submitting = false;
      notifyListeners();
    }
  }

  void reset() {
    result = null;
    selected.clear();
    notifyListeners();
  }
}
