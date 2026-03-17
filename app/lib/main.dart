import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/local/seed_service.dart';
import 'di/injection.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize DI (database + repositories)
  await initDependencies();

  // Seed questions & concepts from JSON
  await sl<SeedService>().seedIfNeeded();

  runApp(const CatchApp());
}

class CatchApp extends StatelessWidget {
  const CatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CATch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorSchemeSeed: Colors.black,
        useMaterial3: true,
        fontFamily: '.SF Pro Text',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
