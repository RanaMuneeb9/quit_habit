import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen> {
  // TODO: Add animation/timer logic
  // For now, this is the static UI from the screenshot
  final String _currentState = "Breathe In";
  final String _currentCount = "4";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        automaticallyImplyLeading: false, // No back arrow
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Breathing Exercise',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '4-4-6 breathing pattern',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32), // Compacted from 48
              // 1. Breathing Circle (Now a Stack)
              Stack(
                alignment: Alignment.center,
                children: [
                  // New Outer, larger, more transparent circle (drawn first = "underneath")
                  Container(
                    width: 280, // Compacted from 300
                    height: 280, // Compacted from 300
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.lightPrimary.withAlpha(
                        10,
                      ), // More transparent
                    ),
                  ),
                  // Original Inner Circle
                  Container(
                    width: 240, // Compacted from 260
                    height: 240, // Compacted from 260
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.lightPrimary.withAlpha(13),
                          AppColors.lightBackground,
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentCount,
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontSize: 80, // Compacted from 96
                              fontWeight: FontWeight.w300,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                          Text(
                            _currentState,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w500,
                              fontSize: 18, // Compacted from 20
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40), // Compacted from 48
              // 2. Info Box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12, // Compacted from 14
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Follow the breathing pattern to calm your mind and reduce cravings',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightPrimary.withAlpha(229),
                    fontWeight: FontWeight.w500,
                    height: 1.4, // Tighter line height
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. Start Button
              SizedBox(
                width: 200, // Match Meditation screen button width
                height: 50, // Compacted from 52
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement breathing animation logic
                  },
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.lightPrimary,
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.play_arrow_rounded,
                        color: AppColors.white,
                        size: 26,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Start',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40), // Compacted from 48
              // 4. Tips Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20), // Compacted from 24
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tips for best results:',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12), // Compacted from 16
                    _buildTipRow(theme, 'Find a quiet, comfortable place'),
                    _buildTipRow(theme, 'Close your eyes or soften your gaze'),
                    _buildTipRow(
                      theme,
                      'Complete at least 5 cycles for maximum benefit',
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

  Widget _buildTipRow(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0), // Compacted from 10.0
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                height: 1.4, // Tighter line height
              ),
            ),
          ),
        ],
      ),
    );
  }
}
