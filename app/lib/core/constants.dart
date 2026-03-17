import 'package:flutter/material.dart';

class AppColors {
  static const black = Color(0xFF000000);
  static const white = Color(0xFFFFFFFF);
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey500 = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey900 = Color(0xFF212121);

  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
}

enum Section {
  qa('QA', 'Quant'),
  varc('VARC', 'VARC'),
  dilr('DILR', 'DILR');

  final String code;
  final String label;

  const Section(this.code, this.label);

  static Section fromCode(String code) {
    return Section.values.firstWhere(
      (s) => s.code == code,
      orElse: () => Section.qa,
    );
  }
}

enum PracticeMode {
  dailyMin('daily_min'),
  focused('focused'),
  retryMissed('retry_missed'),
  adaptive('adaptive');

  final String value;

  const PracticeMode(this.value);

  static PracticeMode fromValue(String value) {
    return PracticeMode.values.firstWhere(
      (m) => m.value == value,
      orElse: () => PracticeMode.focused,
    );
  }
}
