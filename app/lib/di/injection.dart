import 'package:get_it/get_it.dart';

import '../data/local/database_service.dart';
import '../data/local/local_question_repo.dart';
import '../data/local/local_attempt_repo.dart';
import '../data/local/local_daily_target_repo.dart';
import '../data/local/local_concept_repo.dart';
import '../data/local/local_stats_repo.dart';
import '../data/local/local_settings_repo.dart';
import '../data/local/seed_service.dart';
import '../data/local/home_facade.dart';
import '../domain/repositories/question_repository.dart';
import '../domain/repositories/attempt_repository.dart';
import '../domain/repositories/daily_target_repository.dart';
import '../domain/repositories/concept_repository.dart';
import '../domain/repositories/stats_repository.dart';
import '../domain/repositories/settings_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Database
  final dbService = DatabaseService();
  await dbService.database; // ensure DB is initialized + seeded
  sl.registerSingleton<DatabaseService>(dbService);

  // Seed service
  sl.registerLazySingleton<SeedService>(
    () => SeedService(dbService),
  );

  // Repositories
  sl.registerLazySingleton<QuestionRepository>(
    () => LocalQuestionRepository(dbService),
  );
  sl.registerLazySingleton<AttemptRepository>(
    () => LocalAttemptRepository(dbService),
  );
  sl.registerLazySingleton<DailyTargetRepository>(
    () => LocalDailyTargetRepository(dbService),
  );
  sl.registerLazySingleton<ConceptRepository>(
    () => LocalConceptRepository(dbService),
  );
  sl.registerLazySingleton<StatsRepository>(
    () => LocalStatsRepository(dbService),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => LocalSettingsRepository(dbService),
  );

  // Facades
  sl.registerLazySingleton<HomeFacade>(
    () => HomeFacade(
      dailyTargetRepo: sl<DailyTargetRepository>(),
      statsRepo: sl<StatsRepository>(),
      conceptRepo: sl<ConceptRepository>(),
      settingsRepo: sl<SettingsRepository>(),
    ),
  );
}
