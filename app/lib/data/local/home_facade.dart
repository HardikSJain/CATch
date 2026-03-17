import '../../data/models/daily_target.dart';
import '../../domain/repositories/daily_target_repository.dart';
import '../../domain/repositories/stats_repository.dart';
import '../../domain/repositories/concept_repository.dart';
import '../../domain/repositories/settings_repository.dart';

/// Aggregated home screen data.
class HomeData {
  final DailyTarget todayTarget;
  final int streak;
  final Map<String, dynamic> stats;
  final int conceptsToReview;
  final int? daysToExam;

  const HomeData({
    required this.todayTarget,
    required this.streak,
    required this.stats,
    required this.conceptsToReview,
    this.daysToExam,
  });
}

/// Aggregates data from multiple repositories for the home screen.
class HomeFacade {
  final DailyTargetRepository dailyTargetRepo;
  final StatsRepository statsRepo;
  final ConceptRepository conceptRepo;
  final SettingsRepository settingsRepo;

  HomeFacade({
    required this.dailyTargetRepo,
    required this.statsRepo,
    required this.conceptRepo,
    required this.settingsRepo,
  });

  Future<HomeData> loadHomeData() async {
    final target = await dailyTargetRepo.getOrCreateTodayTarget();
    final streak = await dailyTargetRepo.getStreak();
    final stats = await statsRepo.getOverallStats();
    final reviewCount = await conceptRepo.getDueForReviewCount();
    final examDate = await settingsRepo.getCatExamDate();

    int? daysToExam;
    if (examDate != null) {
      daysToExam = examDate.difference(DateTime.now()).inDays;
      if (daysToExam < 0) daysToExam = null;
    }

    return HomeData(
      todayTarget: target,
      streak: streak,
      stats: stats,
      conceptsToReview: reviewCount,
      daysToExam: daysToExam,
    );
  }
}
