import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/home/report_relapse/report_relapse_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

// --- UPDATED: Converted to StatefulWidget ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 0 = Free Mode, 1 = Challenge Mode
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20), // Reduced padding
                _buildHeader(theme),
                const SizedBox(height: 24), // Reduced padding
                _buildStreakCard(theme),
                const SizedBox(height: 24),
                _buildModeTabs(theme),
                const SizedBox(height: 24),

                // --- UPDATED: Swappable content based on tab ---
                IndexedStack(
                  index: _selectedTabIndex,
                  children: [
                    _buildFreeModeView(theme),
                    _buildChallengeModeView(theme),
                  ],
                ),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header with "QUIT" and profile icon
  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'QUIT',
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.lightTextPrimary,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
          child: const Icon(
            Icons.person_outline,
            color: AppColors.lightPrimary,
            size: 28,
          ),
        ),
      ],
    );
  }

  /// Builds the main gradient streak card
  Widget _buildStreakCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // Reduced padding
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B7FFF), Color(0xFFAD46FF)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightPrimary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CURRENT STREAK',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced padding
          Text(
            '14',
            style: theme.textTheme.displayLarge?.copyWith(
              fontSize: 52, // Reduced font size
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              height: 1.0,
            ),
          ),
          Text(
            'Days Smoke-Free',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20), // Reduced padding
          Row(
            children: [
              Expanded(
                child: _StatItem(value: '130', label: 'Cigarettes Not Smoked'),
              ),
              Expanded(
                child: _StatItem(value: '\$65', label: 'Money Saved'),
              ),
              Expanded(
                child: _StatItem(value: '+12%', label: 'Health Gained'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// --- NEW: Builds the animated "Free Mode" / "Challenge Mode" tab switcher ---
  Widget _buildModeTabs(ThemeData theme) {
    return Container(
      height: 44, // Reduced height
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.lightInputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Animated pill
          AnimatedAlign(
            alignment: _selectedTabIndex == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: (MediaQuery.of(context).size.width - 48 - 8) / 2,
              height: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Text buttons
          Row(
            children: [
              Expanded(child: _buildTabItem(theme, 'Free Mode', 0)),
              Expanded(child: _buildTabItem(theme, 'Challenge Mode', 1)),
            ],
          ),
        ],
      ),
    );
  }

  /// --- NEW: Helper for a single tab item ---
  Widget _buildTabItem(ThemeData theme, String title, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: theme.textTheme.labelLarge!.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? AppColors.lightPrimary
                : AppColors.lightTextSecondary,
          ),
          child: Text(title),
        ),
      ),
    );
  }

  /// --- NEW: Builds the content for "Free Mode" ---
  Widget _buildFreeModeView(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Need a Distraction Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Need a Distraction?',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: const ReportRelapseScreen(),
                  withNavBar: false,
                  pageTransitionAnimation: PageTransitionAnimation.cupertino,
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See All',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Distraction Cards
        Row(
          children: [
            Expanded(
              child: _DistractionCard(
                icon: Icons.air,
                label: 'Breathing',
                color: const Color(0xFFFF6B6B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DistractionCard(
                icon: Icons.trending_up,
                label: 'Exercise',
                color: const Color(0xFF4B7BFF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DistractionCard(
                icon: Icons.self_improvement,
                label: 'Meditate',
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Why This Matters Section
        Text(
          'Why This Matters',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16), // Reduced padding
          decoration: BoxDecoration(
            color: AppColors.lightSuccess.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.lightSuccess.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'After 2 weeks smoke-free, your lung function increases by up to 30% and your circulation improves.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  color: AppColors.lightTextPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Learn More..',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// --- NEW: Builds the content for "Challenge Mode" ---
  Widget _buildChallengeModeView(ThemeData theme) {
    return Column(
      children: [
        // Active Challenge Section
        Container(
          padding: const EdgeInsets.all(16), // Reduced padding
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.lightBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44, // Reduced size
                    height: 44, // Reduced size
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_fire_department,
                        color: AppColors.lightPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Challenge: 3-Day Breath Fresh',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'With Alex',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2 of 3 days completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: AppColors.lightTextSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '66%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.lightBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.66,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightPrimary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                    ), // Reduced padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Continue Challenge',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 18, // Reduced font size
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2), // Reduced padding
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10, // Reduced font size
            color: AppColors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DistractionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DistractionCard({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16), // Reduced padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 44, // Reduced size
            height: 44, // Reduced size
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.white, size: 22), // Reduced size
          ),
          const SizedBox(height: 10), // Reduced padding
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
