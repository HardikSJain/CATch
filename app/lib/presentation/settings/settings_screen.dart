import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Placeholder — will be implemented in Phase 6.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Settings coming in Phase 6',
          style: TextStyle(color: AppColors.grey500),
        ),
      ),
    );
  }
}
