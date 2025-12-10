import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/goal.dart';
import '../models/user_goal.dart';

class GoalService {
  static final GoalService _instance = GoalService._internal();
  factory GoalService() => _instance;
  GoalService._internal();
  static GoalService get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection References
  CollectionReference get _goalsCollection => _firestore.collection('goals');
  
  // Helper to get user's goals subcollection
  CollectionReference _getUserGoalsCollection(String userId) =>
      _firestore.collection('users').doc(userId).collection('goals');

  // Fetch Available Goals (Global) - Filtered
  // Returns goals that the user has NOT started or completed (unless repeatable)
  Stream<List<Goal>> getAvailableGoalsFiltered(String userId) {
    final controller = StreamController<List<Goal>>();

    // Combine global goals and user goals
    StreamSubscription? goalsSub;
    StreamSubscription? userGoalsSub;
    List<Goal> globalGoals = [];
    List<UserGoal> userGoals = [];
    bool globalLoaded = false;
    bool userLoaded = false;

    void emitFilteredGoals() {
      if (controller.isClosed) return;
      
      final filtered = globalGoals.where((g) {
        final relatedUserGoals = userGoals.where((ug) => ug.goalId == g.id).toList();
        final hasActive = relatedUserGoals.any((ug) => ug.status == UserGoalStatus.active);
        final hasCompleted = relatedUserGoals.any((ug) => ug.status == UserGoalStatus.completed);
        
        if (hasActive) return false; // Always hide if active
        
        if (g.isRepeatable) {
          return true; // Show if not active (even if completed)
        } else {
          return !hasCompleted; // Hide if completed and not repeatable
        }
      }).toList();
      
      controller.add(filtered);
    }

    goalsSub = _goalsCollection.snapshots().listen(
      (snapshot) {
        globalGoals = [];
        for (final doc in snapshot.docs) {
          try {
            globalGoals.add(Goal.fromFirestore(doc));
          } catch (e) {
            debugPrint('GoalService: Failed to parse Goal ${doc.id}: $e');
          }
        }
        globalLoaded = true;
        if (globalLoaded && userLoaded) emitFilteredGoals();
      },
      onError: controller.addError,
    );

    userGoalsSub = _getUserGoalsCollection(userId).snapshots().listen(
      (snapshot) {
        userGoals = [];
        for (final doc in snapshot.docs) {
          try {
            userGoals.add(UserGoal.fromFirestore(doc));
          } catch (e) {
            debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
          }
        }
        userLoaded = true;
        if (globalLoaded && userLoaded) emitFilteredGoals();
      },
      onError: controller.addError,
    );

    controller.onCancel = () {
      goalsSub?.cancel();
      userGoalsSub?.cancel();
      controller.close();
    };

    return controller.stream;
  }

  // Fetch All Goals (Unfiltered)
  Stream<List<Goal>> getAllGoals() {
    return _goalsCollection.snapshots().map((snapshot) {
      final goals = <Goal>[];
      for (final doc in snapshot.docs) {
        try {
          goals.add(Goal.fromFirestore(doc));
        } catch (e) {
          debugPrint('GoalService: Failed to parse Goal ${doc.id}: $e');
        }
      }
      return goals;
    });
  }

  // Fetch User's Active Goals
  Stream<List<UserGoal>> getUserActiveGoals(String userId) {
    return _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
      final userGoals = <UserGoal>[];
      for (final doc in snapshot.docs) {
        try {
          userGoals.add(UserGoal.fromFirestore(doc));
        } catch (e) {
          debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
        }
      }
      return userGoals;
    });
  }

  // Fetch User's Completed Goals (Badges)
  Stream<List<UserGoal>> getUserCompletedGoals(String userId) {
    return _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snapshot) {
      final userGoals = <UserGoal>[];
      for (final doc in snapshot.docs) {
        try {
          userGoals.add(UserGoal.fromFirestore(doc));
        } catch (e) {
          debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
        }
      }
      return userGoals;
    });
  }

  // Start a Goal
  Future<void> startGoal(Goal goal, String userId) async {
    final userGoalsRef = _getUserGoalsCollection(userId);
    final userGoalDoc = userGoalsRef.doc(goal.id);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userGoalDoc);

      if (snapshot.exists) {
        final existingUserGoal = UserGoal.fromFirestore(snapshot);
        if (existingUserGoal.status == UserGoalStatus.active) {
          return; // Already active, idempotent
        }

        // Move completed/failed goal to history (new doc with random ID)
        final historyDoc = userGoalsRef.doc();
        transaction.set(historyDoc, existingUserGoal.toMap());
      }

      final userGoal = UserGoal(
        id: goal.id,
        goalId: goal.id,
        userId: userId,
        status: UserGoalStatus.active,
        progress: 0,
        startDate: DateTime.now(),
        goalTitle: goal.title,
        goalDescription: goal.description,
        goalTargetValue: goal.targetValue,
        badgeName: goal.badgeName,
        badgeIcon: goal.badgeIcon ?? '',
        unit: goal.unit,
        type: goal.type.toString().split('.').last,
        lastUpdateDate: null,
        lastUpdateDayString: null,
        lastServerTimestamp: null,
      );

      transaction.set(userGoalDoc, userGoal.toMap());
    });
  }

  // Seed Goals (Global Catalog)
  Future<void> seedGoals() async {
    final goals = [
      Goal(
        id: '',
        title: '30 Days of Mindfulness',
        description: 'Complete 30 days of mindfulness exercises.',
        type: GoalType.duration,
        targetValue: 30,
        badgeName: 'Mindfulness Master',
        badgeIcon: 'images/icons/cig_1.png',
        unit: 'days',
        requiresStreak: true,
      ),
      Goal(
        id: '',
        title: 'Breathing Expert',
        description: 'Use breathing exercise for 14 days.',
        type: GoalType.exercise,
        targetValue: 14,
        badgeName: 'Breath of Life',
        badgeIcon: 'images/icons/cig_2.png',
        unit: 'sessions',
        metadata: {'dailyLimit': true},
        isRepeatable: true,
      ),
      Goal(
        id: '',
        title: 'Consistency King',
        description: 'Use the app for 10 mins every day for 15 days.',
        type: GoalType.functionality,
        targetValue: 15,
        badgeName: 'Consistent',
        badgeIcon: 'images/icons/cig_3.png',
        unit: 'days',
        metadata: {'minDailyMinutes': 10},
        requiresStreak: true,
      ),
      Goal(
        id: '',
        title: 'Social Butterfly',
        description: 'Invite 3 friends to the app.',
        type: GoalType.social,
        targetValue: 3,
        badgeName: 'Connector',
        badgeIcon: 'images/icons/cig_4.png',
        unit: 'friends',
      ),
      Goal(
        id: '',
        title: 'Knowledge Seeker',
        description: 'Read 5 health articles.',
        type: GoalType.content,
        targetValue: 5,
        badgeName: 'Scholar',
        badgeIcon: 'images/icons/cig_5.png',
        unit: 'articles',
      ),
      Goal(
        id: '',
        title: 'Emotional Intelligence',
        description: 'Log your mood for 7 consecutive days.',
        type: GoalType.journaling,
        targetValue: 7,
        badgeName: 'Self Aware',
        badgeIcon: 'images/icons/header_diamond.png',
        unit: 'days',
        requiresStreak: true,
      ),
      Goal(
        id: '',
        title: 'Pro Achiever',
        description: 'Reach Pro status.',
        type: GoalType.milestone,
        targetValue: 1,
        badgeName: 'Pro Member',
        badgeIcon: 'images/icons/header_shield.png',
        unit: 'milestone',
      ),
    ];

    for (var goal in goals) {
      final existing =
          await _goalsCollection.where('title', isEqualTo: goal.title).get();
      if (existing.docs.isEmpty) {
        await _goalsCollection.add(goal.toMap());
      }
    }
  }

  // Seed User Goals (For Testing)
  Future<void> seedUserGoals(String userId) async {
    // Get available goals first
    final goalsSnapshot = await _goalsCollection.get();
    if (goalsSnapshot.docs.isEmpty) {
      await seedGoals(); // Ensure global goals exist
    }
    
    final goals = await _goalsCollection.get();
    if (goals.docs.isEmpty) return;

    // Start the first goal for the user if not already started
    final firstGoal = Goal.fromFirestore(goals.docs.first);
    await startGoal(firstGoal, userId);
  }

  // Helper to calculate days since epoch (UTC) for consistent streak tracking
  int _getDaysSinceEpoch(DateTime date) {
    return date.toUtc().difference(DateTime.utc(1970, 1, 1)).inDays;
  }

  // Update Goal Progress with Transaction
  Future<void> updateGoalProgress(
    String userId,
    String userGoalId,
    int amountToAdd, {
    bool checkDailyLimit = false,
  }) async {
    final userGoalRef = _getUserGoalsCollection(userId).doc(userGoalId);

    final now = DateTime.now();
    final currentDay = _getDaysSinceEpoch(now);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(userGoalRef);
      if (!snapshot.exists) return;

      final userGoal = UserGoal.fromFirestore(snapshot);
      if (userGoal.status != UserGoalStatus.active) return;

      // Fetch goal doc early to satisfy transaction read-before-write rule
      final goalDoc = await transaction.get(_goalsCollection.doc(userGoal.goalId));

      final Map<String, dynamic> updates = {};

      // Check daily limit using lastUpdateDayString
      if (checkDailyLimit) {
        final todayString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        
        if (userGoal.lastUpdateDayString == todayString) {
          return; // Already updated today
        }
        
        // Update lastUpdateDayString
        updates['lastUpdateDayString'] = todayString;
      }
      
      int currentProgress = userGoal.progress;

      // Check Streak Reset Logic
      // Only proceed if the global goal exists. If it was deleted, we skip streak checks to prevent crashes.
      if (goalDoc.exists) {
        final goal = Goal.fromFirestore(goalDoc);
        
        if (goal.requiresStreak) {
           // Use server timestamp if available, otherwise fall back to local lastUpdateDate
           // We prefer lastServerTimestamp for cheat prevention.
           final lastTimestamp = userGoal.lastServerTimestamp?.toDate() ?? userGoal.lastUpdateDate;
           
           if (lastTimestamp != null) {
             final lastDay = _getDaysSinceEpoch(lastTimestamp);
             
             // If the difference is > 1 (e.g. updated day 100, now day 102), reset.
             // Difference of 1 means consecutive days (good).
             // Difference of 0 means same day (already handled by checkDailyLimit if applicable, or allowed).
             if (currentDay - lastDay > 1) {
               currentProgress = 0;
               // We don't update Firestore here yet; we calculate the new progress first.
             }
           }
        }
      }

      int newProgress = currentProgress + amountToAdd;

      updates.addAll({
        'progress': newProgress,
        'lastUpdateDate': FieldValue.serverTimestamp(), // Use server time
        'lastServerTimestamp': FieldValue.serverTimestamp(),
      });

      // Check completion
      if (newProgress >= userGoal.goalTargetValue) {
        updates.addAll({
          'status': UserGoalStatus.completed.name,
          'completedDate': FieldValue.serverTimestamp(),
        });
      }

      transaction.update(userGoalRef, updates);
    });
  }

  // Check and update Functionality goals (e.g. daily usage)
  Future<void> checkFunctionalityGoals(String userId, int dailyUsageMinutes) async {
    final activeGoalsQuery = await _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in activeGoalsQuery.docs) {
      try {
        final userGoal = UserGoal.fromFirestore(doc);
        
        if (userGoal.type == 'functionality' || userGoal.type == 'GoalType.functionality') { 
          final goalDoc = await _goalsCollection.doc(userGoal.goalId).get();
          if (!goalDoc.exists) continue;
          try {
            final goal = Goal.fromFirestore(goalDoc);

            final minMinutes = (goal.metadata['minDailyMinutes'] as num?)?.toInt() ?? 10;

            if (dailyUsageMinutes >= minMinutes) {
                 await updateGoalProgress(
                   userId, 
                   userGoal.id, 
                   1, // Increment by 1
                   checkDailyLimit: true
                 );
            }
          } catch (e) {
            debugPrint('GoalService: Failed to parse Goal ${goalDoc.id}: $e');
          }
        }
      } catch (e) {
        debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
      }
    }
  }

  // Social Challenges
  Future<void> checkSocialGoals(String userId, int friendsInvited) async {
    await updateProgressForType(userId, GoalType.social, amount: friendsInvited);
  }

  // Content/Education Challenges
  Future<void> checkContentGoals(String userId, int articlesRead) async {
    await updateProgressForType(userId, GoalType.content, amount: articlesRead);
  }

  // Savings Challenges
  Future<void> checkSavingsGoals(String userId, int amountSaved) async {
    await updateProgressForType(userId, GoalType.savings, amount: amountSaved);
  }

  // Journaling/Mood Challenges
  Future<void> checkJournalingGoals(String userId) async {
    await updateProgressForType(userId, GoalType.journaling, amount: 1, checkDailyLimit: true);
  }

  // Milestone Challenges
  Future<void> checkMilestoneGoals(String userId, String milestoneId) async {
    final activeGoalsQuery = await _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in activeGoalsQuery.docs) {
      try {
        final userGoal = UserGoal.fromFirestore(doc);
        if (userGoal.type == 'milestone') {
           final goalDoc = await _goalsCollection.doc(userGoal.goalId).get();
           if (!goalDoc.exists) continue;
           try {
             final goal = Goal.fromFirestore(goalDoc);
             
             final requiredMilestone = goal.metadata['milestoneId'] as String?;
             if (requiredMilestone == milestoneId || (goal.title.contains('Pro') && milestoneId == 'pro_status')) {
               await updateGoalProgress(userId, userGoal.id, 1); 
             }
           } catch (e) {
             debugPrint('GoalService: Failed to parse Goal ${goalDoc.id}: $e');
           }
        }
      } catch (e) {
        debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
      }
    }
  }

  // Helper to increment progress for a specific type
  Future<void> updateProgressForType(
    String userId, 
    GoalType type, {
    int amount = 1,
    bool checkDailyLimit = false,
  }) async {
    final activeGoalsQuery = await _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in activeGoalsQuery.docs) {
      try {
        final userGoal = UserGoal.fromFirestore(doc);
        // Check type string match
        if (userGoal.type == type.toString().split('.').last) {
          
          // Check metadata for daily limit override
          bool shouldCheckDaily = checkDailyLimit;
          
          // We need to fetch the goal to check metadata
          final goalDoc = await _goalsCollection.doc(userGoal.goalId).get();
          if (goalDoc.exists) {
            try {
              final goal = Goal.fromFirestore(goalDoc);
              if (goal.metadata['dailyLimit'] == true) {
                shouldCheckDaily = true;
              }
            } catch (e) {
              debugPrint('GoalService: Failed to parse Goal ${goalDoc.id}: $e');
            }
          }

          await updateGoalProgress(
            userId, 
            userGoal.id, 
            amount, 
            checkDailyLimit: shouldCheckDaily
          );
        }
      } catch (e) {
        debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
      }
    }
  }
  
  // Check Duration Goals (Streak)
  Future<void> checkDurationGoals(String userId, int currentStreak) async {
    final activeGoalsQuery = await _getUserGoalsCollection(userId)
        .where('status', isEqualTo: 'active')
        .get();

    for (var doc in activeGoalsQuery.docs) {
      try {
        final userGoal = UserGoal.fromFirestore(doc);
        if (userGoal.type == 'duration') {
           // Use transaction for safety
           await _firestore.runTransaction((transaction) async {
             final freshSnapshot = await transaction.get(doc.reference);
             if (!freshSnapshot.exists) return;
             
             try {
               final freshUserGoal = UserGoal.fromFirestore(freshSnapshot);
               if (freshUserGoal.status != UserGoalStatus.active) return;

               if (freshUserGoal.progress != currentStreak) {
                 final Map<String, dynamic> updates = {
                   'progress': currentStreak,
                   'lastUpdateDate': FieldValue.serverTimestamp(),
                   'lastServerTimestamp': FieldValue.serverTimestamp(),
                 };
                 
                 // Check completion
                 if (currentStreak >= freshUserGoal.goalTargetValue) {
                   updates.addAll({
                     'status': UserGoalStatus.completed.name,
                     'completedDate': FieldValue.serverTimestamp(),
                   });
                 }
                 
                 transaction.update(doc.reference, updates);
               }
             } catch (e) {
               debugPrint('GoalService: Failed to parse fresh UserGoal ${freshSnapshot.id}: $e');
             }
           });
        }
      } catch (e) {
        debugPrint('GoalService: Failed to parse UserGoal ${doc.id}: $e');
      }
    }
  }
}
