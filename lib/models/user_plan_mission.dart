import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:quit_habit/models/plan_mission.dart';

/// Status of a user's plan mission
enum UserPlanMissionStatus {
  /// Mission is locked (previous day not completed)
  locked,
  /// Mission is available to start
  available,
  /// Mission has been started but not completed
  inProgress,
  /// Mission has been completed
  completed,
}

/// User's personal copy of a plan mission with progress tracking.
/// Stored in `users/{uid}/userPlanMissions` subcollection.
class UserPlanMission {
  /// Firestore document ID
  final String id;
  
  /// User ID who owns this mission
  final String userId;
  
  // ---- Denormalized from PlanMission ----
  /// Day number in the plan (1-90)
  final int dayNumber;
  
  /// Phase this mission belongs to
  final PlanPhaseType phase;
  
  /// Mission title
  final String missionTitle;
  
  /// Mission description/goal
  final String missionDescription;
  
  /// List of tasks to complete
  final List<String> tasks;
  
  /// List of reflection questions
  final List<String> reflectionQuestions;
  
  /// Whether this day is a milestone
  final bool isMilestone;
  
  /// Whether this day requires a contract signature
  final bool requiresContract;
  
  /// Optional badge ID for milestone days
  final String? badgeId;
  
  // ---- User-specific progress ----
  /// Current status of this mission
  final UserPlanMissionStatus status;
  
  /// Map of task index to completion status
  final Map<int, bool> taskCompletions;
  
  /// Map of reflection question index to user's answer
  final Map<int, String> reflectionAnswers;
  
  /// User's signature for contract (Day 1) - stored as base64 PNG
  final String? contractSignature;
  
  /// When the user started this mission
  final DateTime? startedAt;
  
  /// When the user completed this mission
  /// When the user completed this mission
  final DateTime? completedAt;

  /// When this mission will unlock
  final DateTime? unlocksAt;

  UserPlanMission({
    required this.id,
    required this.userId,
    required this.dayNumber,
    required this.phase,
    required this.missionTitle,
    required this.missionDescription,
    required this.tasks,
    required this.reflectionQuestions,
    this.isMilestone = false,
    this.requiresContract = false,
    this.badgeId,
    required this.status,
    this.taskCompletions = const {},
    this.reflectionAnswers = const {},
    this.contractSignature,
    this.startedAt,
    this.completedAt,
    this.unlocksAt,
  });

  /// Create from a PlanMission template (for initial unlock)
  factory UserPlanMission.fromTemplate({
    required PlanMission mission,
    required String userId,
    required UserPlanMissionStatus initialStatus,
  }) {
    return UserPlanMission(
      id: mission.id,
      userId: userId,
      dayNumber: mission.dayNumber,
      phase: mission.phase,
      missionTitle: mission.missionTitle,
      missionDescription: mission.missionDescription,
      tasks: List.from(mission.tasks),
      reflectionQuestions: List.from(mission.reflectionQuestions),
      isMilestone: mission.isMilestone,
      requiresContract: mission.requiresContract,
      badgeId: mission.badgeId,
      status: initialStatus,
      taskCompletions: {},
      reflectionAnswers: {},
      unlocksAt: null,
    );
  }

  /// Create from Firestore document
  factory UserPlanMission.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw StateError('UserPlanMission document ${doc.id} has no data');
    }

    final userId = data['userId'] as String?;
    if (userId == null || userId.isEmpty) {
      throw FormatException(
        'UserPlanMission.fromFirestore: Missing "userId" for document ${doc.id}'
      );
    }

    // Parse phase
    final phaseString = data['phase'] as String? ?? 'awareness';
    final phase = PlanPhaseType.values.firstWhere(
      (e) => e.name == phaseString,
      orElse: () => PlanPhaseType.awareness,
    );

    // Parse status
    final statusString = data['status'] as String? ?? 'locked';
    final status = UserPlanMissionStatus.values.firstWhere(
      (e) => e.name == statusString,
      orElse: () => UserPlanMissionStatus.locked,
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

    // Parse task completions map
    final taskCompletionsRaw = data['taskCompletions'] as Map<String, dynamic>?;
    final taskCompletions = <int, bool>{};
    if (taskCompletionsRaw != null) {
      taskCompletionsRaw.forEach((key, value) {
        final index = int.tryParse(key);
        if (index != null && value is bool) {
          taskCompletions[index] = value;
        }
      });
    }

    // Parse reflection answers map
    final reflectionAnswersRaw = data['reflectionAnswers'] as Map<String, dynamic>?;
    final reflectionAnswers = <int, String>{};
    if (reflectionAnswersRaw != null) {
      reflectionAnswersRaw.forEach((key, value) {
        final index = int.tryParse(key);
        if (index != null && value is String) {
          reflectionAnswers[index] = value;
        }
      });
    }

    // Parse dates
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    return UserPlanMission(
      id: doc.id,
      userId: userId,
      dayNumber: data['dayNumber'] as int? ?? 1,
      phase: phase,
      missionTitle: data['missionTitle'] as String? ?? 'Unknown Mission',
      missionDescription: data['missionDescription'] as String? ?? '',
      tasks: tasks,
      reflectionQuestions: reflectionQuestions,
      isMilestone: data['isMilestone'] as bool? ?? false,
      requiresContract: data['requiresContract'] as bool? ?? false,
      badgeId: data['badgeId'] as String?,
      status: status,
      taskCompletions: taskCompletions,
      reflectionAnswers: reflectionAnswers,
      contractSignature: data['contractSignature'] as String?,
      startedAt: parseDate(data['startedAt']),
      completedAt: parseDate(data['completedAt']),
      unlocksAt: parseDate(data['unlocksAt']),
    );
  }

  /// Convert to Firestore format
  Map<String, dynamic> toMap() {
    // Convert task completions to string-keyed map (Firestore requirement)
    final taskCompletionsMap = <String, bool>{};
    taskCompletions.forEach((key, value) {
      taskCompletionsMap[key.toString()] = value;
    });

    // Convert reflection answers to string-keyed map
    final reflectionAnswersMap = <String, String>{};
    reflectionAnswers.forEach((key, value) {
      reflectionAnswersMap[key.toString()] = value;
    });

    return {
      'userId': userId,
      'dayNumber': dayNumber,
      'phase': phase.name,
      'missionTitle': missionTitle,
      'missionDescription': missionDescription,
      'tasks': tasks,
      'reflectionQuestions': reflectionQuestions,
      'isMilestone': isMilestone,
      'requiresContract': requiresContract,
      if (badgeId != null) 'badgeId': badgeId,
      'status': status.name,
      'taskCompletions': taskCompletionsMap,
      'reflectionAnswers': reflectionAnswersMap,
      if (contractSignature != null) 'contractSignature': contractSignature,
      if (startedAt != null) 'startedAt': Timestamp.fromDate(startedAt!),
      if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
      if (unlocksAt != null) 'unlocksAt': Timestamp.fromDate(unlocksAt!),
    };
  }

  /// Check if all tasks are completed
  bool get allTasksCompleted {
    if (tasks.isEmpty) return true;
    for (int i = 0; i < tasks.length; i++) {
      if (taskCompletions[i] != true) return false;
    }
    return true;
  }

  /// Check if contract is signed (for Day 1)
  bool get isContractSigned {
    if (!requiresContract) return true;
    return contractSignature != null && contractSignature!.isNotEmpty;
  }

  /// Check if mission can be completed
  bool get canComplete {
    if (!allTasksCompleted) return false;
    if (requiresContract && !isContractSigned) return false;
    return true;
  }

  /// Get completion percentage (0.0 to 1.0)
  double get completionPercentage {
    if (tasks.isEmpty) return status == UserPlanMissionStatus.completed ? 1.0 : 0.0;
    
    int completed = 0;
    for (int i = 0; i < tasks.length; i++) {
      if (taskCompletions[i] == true) completed++;
    }
    return completed / tasks.length;
  }

  /// Decode contract signature from base64 to bytes
  Uint8List? get contractSignatureBytes {
    if (contractSignature == null || contractSignature!.isEmpty) return null;
    try {
      return base64Decode(contractSignature!);
    } catch (e) {
      debugPrint('Failed to decode contract signature: $e');
      return null;
    }
  }

  /// Create a copy with modified fields
  UserPlanMission copyWith({
    String? id,
    String? userId,
    int? dayNumber,
    PlanPhaseType? phase,
    String? missionTitle,
    String? missionDescription,
    List<String>? tasks,
    List<String>? reflectionQuestions,
    bool? isMilestone,
    bool? requiresContract,
    String? badgeId,
    UserPlanMissionStatus? status,
    Map<int, bool>? taskCompletions,
    Map<int, String>? reflectionAnswers,
    String? contractSignature,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? unlocksAt,
  }) {
    return UserPlanMission(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dayNumber: dayNumber ?? this.dayNumber,
      phase: phase ?? this.phase,
      missionTitle: missionTitle ?? this.missionTitle,
      missionDescription: missionDescription ?? this.missionDescription,
      tasks: tasks ?? this.tasks,
      reflectionQuestions: reflectionQuestions ?? this.reflectionQuestions,
      isMilestone: isMilestone ?? this.isMilestone,
      requiresContract: requiresContract ?? this.requiresContract,
      badgeId: badgeId ?? this.badgeId,
      status: status ?? this.status,
      taskCompletions: taskCompletions ?? this.taskCompletions,
      reflectionAnswers: reflectionAnswers ?? this.reflectionAnswers,
      contractSignature: contractSignature ?? this.contractSignature,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      unlocksAt: unlocksAt ?? this.unlocksAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserPlanMission &&
        other.id == id &&
        other.userId == userId &&
        other.dayNumber == dayNumber;
  }

  @override
  int get hashCode => Object.hash(id, userId, dayNumber);

  @override
  String toString() => 
      'UserPlanMission(day: $dayNumber, status: ${status.name}, user: $userId)';
}
