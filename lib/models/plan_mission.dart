import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Represents a phase in the 90-day quit plan
enum PlanPhaseType {
  /// Phase 1: Awareness & Analysis (Days 1-7)
  awareness,
  /// Phase 2: Detox & Pattern Interrupt (Days 8-21)
  detox,
  /// Phase 3: Rewiring & Resilience (Days 22-66)
  rewiring,
  /// Phase 4: Mastery & Freedom (Days 67-90)
  mastery,
}

/// Extension to get phase metadata
extension PlanPhaseTypeExtension on PlanPhaseType {
  String get title {
    switch (this) {
      case PlanPhaseType.awareness:
        return 'Awareness & Analysis';
      case PlanPhaseType.detox:
        return 'Detox & Pattern Interrupt';
      case PlanPhaseType.rewiring:
        return 'Rewiring & Resilience';
      case PlanPhaseType.mastery:
        return 'Mastery & Freedom';
    }
  }

  String get subtitle {
    switch (this) {
      case PlanPhaseType.awareness:
        return 'Understand your triggers';
      case PlanPhaseType.detox:
        return 'Break the dopamine loop';
      case PlanPhaseType.rewiring:
        return 'Build lasting habits';
      case PlanPhaseType.mastery:
        return 'Celebrate your freedom';
    }
  }

  /// Get day range for this phase
  (int start, int end) get dayRange {
    switch (this) {
      case PlanPhaseType.awareness:
        return (1, 7);
      case PlanPhaseType.detox:
        return (8, 21);
      case PlanPhaseType.rewiring:
        return (22, 66);
      case PlanPhaseType.mastery:
        return (67, 90);
    }
  }

  /// Badge ID awarded upon phase completion
  String get badgeId {
    switch (this) {
      case PlanPhaseType.awareness:
        return 'phase_1_awareness';
      case PlanPhaseType.detox:
        return 'phase_2_detox';
      case PlanPhaseType.rewiring:
        return 'phase_3_rewiring';
      case PlanPhaseType.mastery:
        return 'phase_4_mastery';
    }
  }

  /// Get phase from day number
  static PlanPhaseType fromDayNumber(int day) {
    if (day <= 7) return PlanPhaseType.awareness;
    if (day <= 21) return PlanPhaseType.detox;
    if (day <= 66) return PlanPhaseType.rewiring;
    return PlanPhaseType.mastery;
  }
}

/// Master plan mission template stored in `planMissions` collection.
/// This is the admin-editable version that gets copied to user's collection.
class PlanMission {
  /// Firestore document ID (usually 'day_1', 'day_2', etc.)
  final String id;
  
  /// Day number in the plan (1-90)
  final int dayNumber;
  
  /// Phase this mission belongs to
  final PlanPhaseType phase;
  
  /// Mission title (e.g., "The Commitment Contract")
  final String missionTitle;
  
  /// Mission description/goal
  final String missionDescription;
  
  /// List of tasks to complete (checkbox items)
  final List<String> tasks;
  
  /// List of reflection questions to answer
  final List<String> reflectionQuestions;
  
  /// Whether this day is a milestone
  final bool isMilestone;
  
  /// Whether this day requires a contract signature (Day 1)
  final bool requiresContract;
  
  /// Optional badge ID for milestone days
  final String? badgeId;

  PlanMission({
    required this.id,
    required this.dayNumber,
    required this.phase,
    required this.missionTitle,
    required this.missionDescription,
    required this.tasks,
    required this.reflectionQuestions,
    this.isMilestone = false,
    this.requiresContract = false,
    this.badgeId,
  });

  /// Create from Firestore document
  factory PlanMission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('PlanMission document ${doc.id} has no data');
    }

    return PlanMission.fromMap(doc.id, data);
  }

  /// Create from Map (for both Firestore and JSON)
  factory PlanMission.fromMap(String id, Map<String, dynamic> data) {
    // Parse phase
    final phaseString = data['phase'] as String? ?? 'awareness';
    final phase = PlanPhaseType.values.firstWhere(
      (e) => e.name == phaseString,
      orElse: () {
        debugPrint('Warning: Invalid phase "$phaseString", defaulting to awareness');
        return PlanPhaseType.awareness;
      },
    );

    // Parse tasks list
    final tasksRaw = data['tasks'];
    final tasks = tasksRaw is List
        ? tasksRaw.map((e) => e.toString()).toList()
        : <String>[];

    // Parse reflection questions list
    final reflectionsRaw = data['reflectionQuestions'];
    final reflectionQuestions = reflectionsRaw is List
        ? reflectionsRaw.map((e) => e.toString()).toList()
        : <String>[];

    return PlanMission(
      id: id,
      dayNumber: data['dayNumber'] as int? ?? 1,
      phase: phase,
      missionTitle: data['missionTitle'] as String? ?? 'Unknown Mission',
      missionDescription: data['missionDescription'] as String? ?? '',
      tasks: tasks,
      reflectionQuestions: reflectionQuestions,
      isMilestone: data['isMilestone'] as bool? ?? false,
      requiresContract: data['requiresContract'] as bool? ?? false,
      badgeId: data['badgeId'] as String?,
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toMap() {
    return {
      'dayNumber': dayNumber,
      'phase': phase.name,
      'missionTitle': missionTitle,
      'missionDescription': missionDescription,
      'tasks': tasks,
      'reflectionQuestions': reflectionQuestions,
      'isMilestone': isMilestone,
      'requiresContract': requiresContract,
      if (badgeId != null) 'badgeId': badgeId,
    };
  }

  /// Create a copy with modified fields
  PlanMission copyWith({
    String? id,
    int? dayNumber,
    PlanPhaseType? phase,
    String? missionTitle,
    String? missionDescription,
    List<String>? tasks,
    List<String>? reflectionQuestions,
    bool? isMilestone,
    bool? requiresContract,
    String? badgeId,
  }) {
    return PlanMission(
      id: id ?? this.id,
      dayNumber: dayNumber ?? this.dayNumber,
      phase: phase ?? this.phase,
      missionTitle: missionTitle ?? this.missionTitle,
      missionDescription: missionDescription ?? this.missionDescription,
      tasks: tasks ?? this.tasks,
      reflectionQuestions: reflectionQuestions ?? this.reflectionQuestions,
      isMilestone: isMilestone ?? this.isMilestone,
      requiresContract: requiresContract ?? this.requiresContract,
      badgeId: badgeId ?? this.badgeId,
    );
  }

  /// Equality is based on mission identity (id and dayNumber) rather than full value equality.
  /// This is intentional: two PlanMission instances representing the same day are considered
  /// equal even if their content (title, tasks, etc.) differs. This design choice allows:
  /// - Efficient lookups in collections by day number
  /// - Proper behavior in Sets and Maps based on mission day
  /// - Content updates without breaking reference equality
  /// If you need to compare all fields, use a manual comparison or consider Equatable.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlanMission &&
        other.id == id &&
        other.dayNumber == dayNumber;
  }

  /// Hash based on mission identity (id and dayNumber) to match equality operator.
  /// This ensures consistent hashing behavior in Sets and Maps.
  @override
  int get hashCode => Object.hash(id, dayNumber);

  @override
  String toString() => 'PlanMission(day: $dayNumber, title: $missionTitle)';
}
