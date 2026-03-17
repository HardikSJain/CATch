class DailyTarget {
  final int id;
  final String date; // 'yyyy-MM-dd'
  final int dilrMinTarget;
  final int qaMinTarget;
  final int varcMinTarget;
  final int dilrMinCompleted;
  final int qaMinCompleted;
  final int varcMinCompleted;
  final String? focusSection;
  final String? focusTopic;
  final int focusTarget;
  final int focusCompleted;
  final bool isComplete;

  DailyTarget({
    required this.id,
    required this.date,
    this.dilrMinTarget = 3,
    this.qaMinTarget = 5,
    this.varcMinTarget = 3,
    this.dilrMinCompleted = 0,
    this.qaMinCompleted = 0,
    this.varcMinCompleted = 0,
    this.focusSection,
    this.focusTopic,
    this.focusTarget = 30,
    this.focusCompleted = 0,
    this.isComplete = false,
  });

  bool get isDailyMinComplete =>
      dilrMinCompleted >= dilrMinTarget &&
      qaMinCompleted >= qaMinTarget &&
      varcMinCompleted >= varcMinTarget;

  double get dailyMinProgress {
    final total = dilrMinTarget + qaMinTarget + varcMinTarget;
    final completed = dilrMinCompleted + qaMinCompleted + varcMinCompleted;
    return total > 0 ? completed / total : 0;
  }

  factory DailyTarget.fromMap(Map<String, dynamic> map) {
    return DailyTarget(
      id: map['id'] as int,
      date: map['date'] as String,
      dilrMinTarget: map['dilr_min_target'] as int? ?? 3,
      qaMinTarget: map['qa_min_target'] as int? ?? 5,
      varcMinTarget: map['varc_min_target'] as int? ?? 3,
      dilrMinCompleted: map['dilr_min_completed'] as int? ?? 0,
      qaMinCompleted: map['qa_min_completed'] as int? ?? 0,
      varcMinCompleted: map['varc_min_completed'] as int? ?? 0,
      focusSection: map['focus_section'] as String?,
      focusTopic: map['focus_topic'] as String?,
      focusTarget: map['focus_target'] as int? ?? 30,
      focusCompleted: map['focus_completed'] as int? ?? 0,
      isComplete: (map['is_complete'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'dilr_min_target': dilrMinTarget,
      'qa_min_target': qaMinTarget,
      'varc_min_target': varcMinTarget,
      'dilr_min_completed': dilrMinCompleted,
      'qa_min_completed': qaMinCompleted,
      'varc_min_completed': varcMinCompleted,
      'focus_section': focusSection,
      'focus_topic': focusTopic,
      'focus_target': focusTarget,
      'focus_completed': focusCompleted,
      'is_complete': isComplete ? 1 : 0,
    };
  }
}
