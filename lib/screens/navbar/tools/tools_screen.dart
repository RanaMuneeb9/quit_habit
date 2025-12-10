import 'package:flutter/material.dart';
import 'package:quit_habit/utils/tool_usage_tracker.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/tools/breathing/breathing_screen.dart';
import 'package:quit_habit/screens/navbar/tools/inspiration/inspiration_quotes_screen.dart';
import 'package:quit_habit/screens/navbar/tools/jumping_jacks/jumping_jacks_screen.dart';
import 'package:quit_habit/screens/navbar/tools/meditation/meditation_screen.dart';
import 'package:quit_habit/screens/navbar/tools/resources/resources_screen.dart';
import 'package:quit_habit/screens/navbar/tools/mood/mood_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

// --- Local Colors for Tool Cards (from design) ---
const Color _kBreathingColor = Color(0xFF1E88E5); // Blue
const Color _kBreathingBg = Color(0xFFE3F2FD);
const Color _kWorkoutColor = Color(0xFFFB8C00); // Orange
const Color _kWorkoutBg = Color(0xFFFFF8E1);
const Color _kMeditationColor = Color(0xFF8E24AA); // Purple
const Color _kMeditationBg = Color(0xFFF3E5F5);
const Color _kPuzzleColor = Color(0xFF43A047); // Green
const Color _kPuzzleBg = Color(0xFFE8F5E9);
const Color _kInspirationColor = Color(0xFFFFB300); // Yellow
const Color _kInspirationBg = Color(0xFFFFFDE7);

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  String _mostUsedTool = 'Breathing';
  int _mostUsedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final result = await ToolUsageTracker.getMostUsedTool();
    if (mounted) {
      setState(() {
        _mostUsedTool = result['name'] ?? 'Breathing';
        _mostUsedCount = result['count'] ?? 0;
      });
    }
  }

  Future<void> _trackUsage(String toolName) async {
    await ToolUsageTracker.trackUsage(toolName);
    _loadUsage();
  }

  void _handleToolTap(BuildContext context, Widget screen, String toolName) {
    _trackUsage(toolName);
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: screen,
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.sizeUp,
    );
  }

  Map<String, dynamic> _getToolData(String name) {
    switch (name) {
      case 'Breathing':
        return {'color': _kBreathingColor, 'icon': Icons.air};
      case 'Physical Workout':
        return {'color': _kWorkoutColor, 'icon': Icons.fitness_center_outlined};
      case 'Meditation':
        return {'color': _kMeditationColor, 'icon': Icons.self_improvement};
      case 'Inspiration':
        return {'color': _kInspirationColor, 'icon': Icons.star_outline_rounded};
      case 'Resources':
        return {'color': const Color(0xFF43A047), 'icon': Icons.menu_book_rounded};
      case 'Mood Check-in':
        return {'color': const Color(0xFFFF9800), 'icon': Icons.mood_rounded};
      default:
        return {'color': _kBreathingColor, 'icon': Icons.air};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      // The design doesn't have a main AppBar, it's part of the tab view
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildHeader(theme),
                const SizedBox(height: 24),
                _buildToolsGrid(context),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top "Cravings Defeated" card
  /// Builds the top "Most Used Exercise" card
  Widget _buildHeader(ThemeData theme) {
    final toolData = _getToolData(_mostUsedTool);
    final toolColor = toolData['color'] as Color;
    final toolIcon = toolData['icon'] as IconData;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Most Used Exercise',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: toolColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  toolIcon,
                  color: toolColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _mostUsedTool,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$_mostUsedCount sessions completed',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the grid of tool cards
  Widget _buildToolsGrid(BuildContext context) {
    // Calculate the width for two columns with spacing
    final double cardWidth =
        (MediaQuery.of(context).size.width - 24 * 2 - 16) / 2;

    return Wrap(
      spacing: 16, // Horizontal spacing
      runSpacing: 16, // Vertical spacing
      children: [
        _ToolCard(
          width: cardWidth,
          icon: Icons.air,
          title: 'Breathing',
          subtitle: 'Calm cravings',
          iconColor: _kBreathingColor,
          backgroundColor: _kBreathingBg,
          onTap: () => _handleToolTap(
              context, const BreathingScreen(), 'Breathing'),
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.fitness_center_outlined,
          title: 'Physical Workout',
          subtitle: 'Quick workouts',
          iconColor: _kWorkoutColor,
          backgroundColor: _kWorkoutBg,
          onTap: () => _handleToolTap(
              context, const JumpingJacksScreen(), 'Physical Workout'),
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.self_improvement,
          title: 'Meditation',
          subtitle: 'Find peace',
          iconColor: _kMeditationColor,
          backgroundColor: _kMeditationBg,
          onTap: () => _handleToolTap(
              context, const MeditationScreen(), 'Meditation'),
        ),
        // --- NEW CARD ADDED ---
        // _ToolCard(
        //   width: cardWidth,
        //   icon: Icons.apps_outlined, // Icon from design
        //   title: 'Word Puzzle',
        //   subtitle: 'Distract mind',
        //   iconColor: _kPuzzleColor,
        //   backgroundColor: _kPuzzleBg,
        //   onTap: () {
        //     // TODO: Navigate to Word Puzzle screen
        //     // PersistentNavBarNavigator.pushNewScreen(
        //     //   context,
        //     //   screen: const WordPuzzleScreen(), // Create this screen
        //     //   withNavBar: false,
        //     //   pageTransitionAnimation: PageTransitionAnimation.sizeUp,
        //     // );
        //   },
        // ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.star_outline_rounded,
          title: 'Inspiration',
          subtitle: 'Daily quotes',
          iconColor: _kInspirationColor,
          backgroundColor: _kInspirationBg,
          onTap: () => _handleToolTap(
              context, const InspirationQuotesScreen(), 'Inspiration'),
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.menu_book_rounded,
          title: 'Resources',
          subtitle: 'Learn & Grow',
          iconColor: const Color(0xFF43A047), // Green
          backgroundColor: const Color(0xFFE8F5E9),
          onTap: () => _handleToolTap(
              context, const ResourcesScreen(), 'Resources'),
        ),
        _ToolCard(
          width: cardWidth,
          icon: Icons.mood_rounded,
          title: 'Mood Check-in',
          subtitle: 'Track feelings',
          iconColor: const Color(0xFFFF9800), // Orange
          backgroundColor: const Color(0xFFFFF3E0),
          onTap: () =>
              _handleToolTap(context, const MoodScreen(), 'Mood Check-in'),
        ),
      ],
    );
  }
}

/// A reusable card widget for the Tools grid
class _ToolCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ToolCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      // REMOVED AspectRatio to make cards rectangular
      // child: AspectRatio(
      //   aspectRatio: 1.0, // Makes the card square
      child: Container(
        height: 130, // Set a fixed height
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12.0), // REDUCED padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // CHANGED
                mainAxisAlignment: MainAxisAlignment.center, // CHANGED
                children: [
                  Icon(icon, color: iconColor, size: 28),
                  const SizedBox(height: 12), // ADDED spacer
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center, // CHANGED
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15, // Tweaked font size
                        ),
                        textAlign: TextAlign.center, // ADDED
                      ),
                      const SizedBox(height: 2), // ADDED spacer
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                          fontSize: 13, // Tweaked font size
                        ),
                        textAlign: TextAlign.center, // ADDED
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ), // REMOVED AspectRatio closing
    );
  }
}