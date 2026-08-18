import 'package:flutter/foundation.dart';

import '../../../certificates/domain/repositories/certificate_repository.dart';
import '../../../learning/domain/repositories/learning_repository.dart';

/// Ранг по компетенции (порог в «очках безопасности»).
enum Rank {
  novice(0, 'Новичок'),
  trainee(300, 'Стажёр'),
  specialist(800, 'Специалист'),
  expert(1500, 'Эксперт'),
  mentor(2500, 'Наставник');

  final int threshold;
  final String label;
  const Rank(this.threshold, this.label);

  static const all = [novice, trainee, specialist, expert, mentor];

  int get level => all.indexOf(this) + 1;
}

/// Считает «геймификацию» на клиенте из реальных данных обучения:
/// пройденные курсы, попытки тестов, сертификаты. Бэк дорабатывать не нужно.
class ProfileController extends ChangeNotifier {
  final LearningRepository _learning;
  final CertificateRepository _certs;

  ProfileController(this._learning, this._certs);

  bool loading = true;
  String? error;

  int completedCourses = 0;
  int passedAttempts = 0;
  int certificates = 0;
  bool perfectScore = false;

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _learning.myCourses(),
        _learning.myAttempts(),
        _certs.myCertificates(),
      ]);
      final my = results[0] as List;
      final attempts = results[1] as List;
      final certs = results[2] as List;

      completedCourses = my.where((m) => m.enrollment.status.isCompleted).length;
      passedAttempts = attempts.where((a) => a.passed).length;
      certificates = certs.length;
      perfectScore = attempts.any((a) => a.score >= 100);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Очки безопасности: за пройденные курсы, сданные тесты и сертификаты.
  int get points =>
      completedCourses * 200 + passedAttempts * 50 + certificates * 100;

  Rank get rank {
    var current = Rank.novice;
    for (final r in Rank.all) {
      if (points >= r.threshold) current = r;
    }
    return current;
  }

  Rank? get nextRank {
    final idx = Rank.all.indexOf(rank);
    return idx < Rank.all.length - 1 ? Rank.all[idx + 1] : null;
  }

  /// Прогресс до следующего ранга (0..1). Для максимального ранга — 1.
  double get progressToNext {
    final next = nextRank;
    if (next == null) return 1;
    final span = next.threshold - rank.threshold;
    if (span <= 0) return 1;
    return ((points - rank.threshold) / span).clamp(0, 1);
  }

  int get pointsToNext => nextRank == null ? 0 : nextRank!.threshold - points;
}