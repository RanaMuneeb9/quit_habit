import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'dart:async'; // For timer logic

class JumpingJacksScreen extends StatefulWidget {
  const JumpingJacksScreen({super.key});

  @override
  State<JumpingJacksScreen> createState() => _JumpingJacksScreenState();
}

class _JumpingJacksScreenState extends State<JumpingJacksScreen> {
  // State variables for the workout
  int _totalRounds = 0;
  int _countdown = 30; // Initial countdown value
  final int _currentExercise = 1;
  final int _totalExercises = 5;
  bool _isWorkoutStarted = false;

  Timer? _workoutTimer;
  Timer? _countdownTimer;

  int _totalSeconds = 0;

  @override
  void dispose() {
    _workoutTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  // --- Timer Logic ---

  void _toggleWorkout() {
    setState(() {
      _isWorkoutStarted = !_isWorkoutStarted;
    });

    if (_isWorkoutStarted) {
      // Start main duration timer
      _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _totalSeconds++;
        });
      });
      // Start countdown
      _startCountdown();
    } else {
      // Pause timers
      _workoutTimer?.cancel();
      _countdownTimer?.cancel();
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        // When countdown finishes, reset it (or move to next exercise)
        timer.cancel();
        setState(() {
          _countdown = 30; // Reset for next round/exercise
          // TODO: Add logic to move to next exercise or round
          // For this example, we just stop the workout
          _toggleWorkout(); // Stop the workout for demo
        });
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // --- UI Builder Methods ---

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String durationString = _formatDuration(_totalSeconds);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // Custom AppBar
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // No back arrow
        titleSpacing: 24.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Movement',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Quick Circuit',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 15,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.lightTextSecondary.withAlpha(25), // ~10%
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.lightTextPrimary,
                size: 20,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
        ],
        // Progress Bar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12.0),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 8.0),
            child: Row(
              children: List.generate(_totalExercises, (index) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: index < _currentExercise
                          ? AppColors.lightPrimary
                          : AppColors.lightBorder,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // 1. Stats Cards
              const SizedBox(height: 16), // Compacted
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: _totalRounds.toString(),
                      label: 'Rounds',
                      bgColor: AppColors.white,
                      textColor: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: durationString,
                      label: 'Duration',
                      bgColor: AppColors.lightSuccess.withAlpha(20), // ~8%
                      textColor: AppColors.lightSuccess,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24), // Compacted
              // 2. Main Exercise Info
              Text(
                'Exercise $_currentExercise of $_totalExercises',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16), // Compacted
              // Placeholder Icon (from screenshot)
              const Icon(
                Icons.accessibility_new_rounded,
                size: 60, // Compacted
                color: AppColors.lightTextPrimary,
              ),
              const SizedBox(height: 12), // Compacted
              Text(
                'Jumping Jacks',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontSize: 32, // Compacted
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Jump with legs apart, arms overhead',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24), // Compacted
              // 3. Timer Circle
              Container(
                width: 180, // Compacted
                height: 180, // Compacted
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lightBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.lightShadow,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _countdown.toString(),
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontSize: 72, // Compacted
                      fontWeight: FontWeight.w300,
                      color: AppColors.lightTextTertiary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32), // Compacted
              // 4. Start/Pause Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _toggleWorkout,
                  style: theme.elevatedButtonTheme.style,
                  icon: Icon(
                    _isWorkoutStarted
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 24,
                  ),
                  label: Text(
                    _isWorkoutStarted ? 'Pause Workout' : 'Start Workout',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Info Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ), // Compacted
                decoration: BoxDecoration(
                  color: AppColors.lightWarning.withAlpha(20), // ~8%
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.lightWarning.withAlpha(50), // ~20%
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: AppColors.lightWarning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Physical activity releases endorphins, reduces stress, and provides an immediate distraction from cravings. Complete at least one full round.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  /// Helper widget for the top stat cards
  Widget _buildStatCard(
    ThemeData theme, {
    required String value,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ), // Compacted
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (bgColor == AppColors.white)
              ? AppColors.lightBorder
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.displaySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 22, // Compacted
            ),
          ),
          const SizedBox(height: 2), // Compacted
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor.withAlpha(180), // ~70%
              fontSize: 13, // Compacted
            ),
          ),
        ],
      ),
    );
  }
}
