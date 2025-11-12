import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _postController = TextEditingController();
  bool _showStreak = true;

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 16),
                _buildHeader(theme),
                const SizedBox(height: 16),
                _buildCustomAppBar(context, theme),
                const SizedBox(height: 24),
                _buildTextField(theme),
                const SizedBox(height: 16),
                _buildShowStreakToggle(theme),
                const SizedBox(height: 24),
                _buildPostButton(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header (copied from home_screen.dart for consistency)
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        _buildStatBadge(
          theme,
          icon: Icons.health_and_safety_outlined,
          label: '0%',
          bgColor: AppColors.badgeGreen,
          iconColor: AppColors.lightSuccess,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.diamond_outlined,
          label: '1',
          bgColor: AppColors.badgeBlue,
          iconColor: AppColors.lightPrimary,
        ),
        const SizedBox(width: 8),
        _buildStatBadge(
          theme,
          icon: Icons.monetization_on_outlined,
          label: '0',
          bgColor: AppColors.badgeOrange,
          iconColor: AppColors.lightWarning,
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.lightWarning,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.workspace_premium_outlined,
                color: AppColors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                'Pro',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper for the small stat badges (copied from home_screen.dart)
  Widget _buildStatBadge(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.lightTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the custom app bar with "New Post" title and "Cancel" button
  Widget _buildCustomAppBar(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'New Post',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 28,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the main text input field
  Widget _buildTextField(ThemeData theme) {
    return Container(
      height: 150, // Give the text field some height
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: TextField(
        controller: _postController,
        maxLines: null, // Allows the text field to expand
        keyboardType: TextInputType.multiline,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.lightTextPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: "What's on your mind?",
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextTertiary,
            fontSize: 15,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
      ),
    );
  }

  /// Builds the "Show Streak" toggle switch
  Widget _buildShowStreakToggle(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: SwitchListTile(
        value: _showStreak,
        onChanged: (val) {
          setState(() {
            _showStreak = val;
          });
        },
        title: Text(
          'Show Streak',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Show your 34 day streak on this post', // Hardcoded from design
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
          ),
        ),
        activeColor: AppColors.lightPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  /// Builds the "Post" button
  Widget _buildPostButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement post logic
          Navigator.pop(context); // Close screen after posting
        },
        style: theme.elevatedButtonTheme.style?.copyWith(
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 50)),
        ),
        child: Text(
          'Post',
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
