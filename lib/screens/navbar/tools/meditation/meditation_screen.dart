import 'dart:async';
import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  int _selectedDuration = 5; // Default 5 minutes
  int _remainingSeconds = 300; // 5 * 60
  bool _isRunning = false;
  Timer? _timer;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remainingSeconds),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });
    _progressController.reverse(
      from: _progressController.value == 0.0 ? 1.0 : _progressController.value,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _progressController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _remainingSeconds = _selectedDuration * 60;
    });
    _progressController.duration = Duration(seconds: _remainingSeconds);
    _progressController.value = 1.0;
  }

  void _selectDuration(int minutes) {
    setState(() {
      _selectedDuration = minutes;
    });
    _resetTimer();
  }

  String get _timerText {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meditation',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Guided mindfulness',
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
                color: AppColors.lightTextSecondary.withOpacity(0.1),
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32), // Compacted from 48
              // Circular Timer
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240, // Compacted from 280
                    height: 240, // Compacted from 280
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 20,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.lightPrimary.withOpacity(0.1),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return SizedBox(
                        width: 240, // Compacted from 280
                        height: 240, // Compacted from 280
                        child: CircularProgressIndicator(
                          value: _progressController.value,
                          strokeWidth: 20,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.lightPrimary,
                          ),
                          backgroundColor: Colors.transparent,
                          strokeCap: StrokeCap.round,
                        ),
                      );
                    },
                  ),
                  Container(
                    width: 200, // Compacted from 240
                    height: 200, // Compacted from 240
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.lightPrimary.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _timerText,
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: 56, // Compacted from 64
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightTextPrimary,
                            letterSpacing: -2,
                          ),
                        ),
                        Text(
                          'remaining',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.lightTextTertiary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40), // Compacted from 64
              // Duration Selector
              Text(
                'Select duration',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDurationButton(3),
                  const SizedBox(width: 12),
                  _buildDurationButton(5),
                  const SizedBox(width: 12),
                  _buildDurationButton(10),
                ],
              ),

              const SizedBox(height: 24), // Compacted from 32
              // Start Button
              SizedBox(
                width: 200,
                height: 50, // Compacted from 56
                child: ElevatedButton(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 26, // Slightly smaller icon
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isRunning ? 'Pause' : 'Start',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 17, // Slightly smaller font
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // Compacted from 64
              // Guide Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20), // Compacted from 24
                decoration: BoxDecoration(
                  color: AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meditation guide:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12), // Compacted from 16
                    _buildGuideItem(
                      theme,
                      'Sit comfortably with a straight back',
                    ),
                    const SizedBox(height: 8), // Compacted from 12
                    _buildGuideItem(
                      theme,
                      'Close your eyes or lower your gaze',
                    ),
                    const SizedBox(height: 8), // Compacted from 12
                    _buildGuideItem(
                      theme,
                      'When your mind wanders, gently return focus',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24), // Compacted bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationButton(int minutes) {
    final isSelected = _selectedDuration == minutes;
    return GestureDetector(
      onTap: () => _selectDuration(minutes),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ), // Compacted padding
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          '$minutes min',
          style: TextStyle(
            fontSize: 14, // Compacted font size
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildGuideItem(ThemeData theme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7.0), // Adjusted for alignment
          child: Container(
            width: 5, // Smaller dot
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.lightTextTertiary,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              height: 1.4, // Slightly tighter line height
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
