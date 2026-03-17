import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Placeholder — will be implemented in Phase 5 with FlashcardBLoC + SM-2.
class FlashcardScreen extends StatelessWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Review',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Flashcard review — coming in Phase 5',
          style: TextStyle(color: AppColors.grey500),
        ),
      ),
    );
  }
}
