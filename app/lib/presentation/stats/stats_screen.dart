import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Placeholder — will be implemented in Phase 6 with StatsCubit + fl_chart.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Your performance analytics',
                style: TextStyle(fontSize: 14, color: AppColors.grey500),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Analytics coming in Phase 6',
                    style: TextStyle(color: AppColors.grey500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
