import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a single relapse entry
class RelapsePeriod {
  final DateTime date;
  final String trigger;

  RelapsePeriod({
    required this.date,
    required this.trigger,
  });

  /// Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'date': Timestamp.fromDate(date),
      'trigger': trigger,
    };
  }

  /// Create from Firestore format
  factory RelapsePeriod.fromFirestore(Map<String, dynamic> data) {
    return RelapsePeriod(
      date: (data['date'] as Timestamp).toDate(),
      trigger: data['trigger'] as String,
    );
  }

  /// Create from JSON (for testing)
  factory RelapsePeriod.fromJson(Map<String, dynamic> json) {
    return RelapsePeriod(
      date: json['date'] is DateTime
          ? json['date'] as DateTime
          : (json['date'] as Timestamp).toDate(),
      trigger: json['trigger'] as String,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'trigger': trigger,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RelapsePeriod &&
        date.year == other.date.year &&
        date.month == other.date.month &&
        date.day == other.date.day &&
        trigger == other.trigger;
  }

  @override
  int get hashCode => Object.hash(date.year, date.month, date.day, trigger);
}

/// Main habit data model containing all habit tracking information
class HabitData {
  final DateTime? startDate;
  final int coins;

  HabitData({
    this.startDate,
    this.coins = 0,
  });

  /// Create from Firestore document
  factory HabitData.fromFirestore(Map<String, dynamic> data) {
    final startDateTimestamp = data['startDate'] as Timestamp?;
    final coins = data['coins'] as int? ?? 0;

    return HabitData(
      startDate: startDateTimestamp?.toDate(),
      coins: coins,
    );
  }

  /// Convert to Firestore format (for updates)
  Map<String, dynamic> toFirestore() {
    return {
      if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
      'coins': coins,
    };
  }

  /// Create empty HabitData
  factory HabitData.empty() {
    return HabitData(
      startDate: null,
      coins: 0,
    );
  }

  /// Check if start date is set
  bool get hasStartDate => startDate != null;

  /// Get the most recent relapse date from a list of relapse periods
  static DateTime? getLastRelapseDate(List<RelapsePeriod> relapsePeriods) {
    if (relapsePeriods.isEmpty) return null;
    return relapsePeriods
        .map((p) => p.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Copy with method for immutability
  HabitData copyWith({
    DateTime? startDate,
    int? coins,
  }) {
    return HabitData(
      startDate: startDate ?? this.startDate,
      coins: coins ?? this.coins,
    );
  }
}

