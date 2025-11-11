import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/profile/faq/faq_screen.dart';
import 'package:quit_habit/screens/navbar/profile/my_data/my_data_screen.dart';
import 'package:quit_habit/screens/navbar/profile/notifications/notifications_screen.dart';
import 'package:quit_habit/screens/navbar/profile/redeem/redeem_code_screen.dart';
import 'package:quit_habit/screens/navbar/profile/subscription_status/subscription_status_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                // 1. Header
                _buildHeader(theme),
                const SizedBox(height: 16), // Reduced
                // 2. Stats
                _buildStats(theme),
                const SizedBox(height: 16), // Reduced
                // 3. Share Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share_outlined, size: 20),
                    label: const Text('Share Your Progress'),
                    style: theme.elevatedButtonTheme.style?.copyWith(
                      padding: WidgetStateProperty.all(
                        // Reduced
                        const EdgeInsets.symmetric(vertical: 12),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.lightPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Reduced
                // 4. Account & Profile
                _buildSectionHeader(theme, 'ACCOUNT & PROFILE'),
                const SizedBox(height: 8), // Reduced
                _buildSettingsCard(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.person_outline,
                      iconColor: AppColors.lightPrimary,
                      title: 'My Data',
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const MyDataScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                    _ProfileMenuItem(
                      icon: Icons.notifications_none_outlined,
                      iconColor: AppColors.lightWarning,
                      title: 'Notifications',
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const NotificationsScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced
                // 5. Subscription
                _buildSectionHeader(theme, 'SUBSCRIPTION'),
                const SizedBox(height: 8), // Reduced
                _buildSettingsCard(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.diamond_outlined,
                      iconColor: AppColors.lightError,
                      title: 'Subscription Status',
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const SubscriptionStatusScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                      trailing: _buildProBadge(theme),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.card_giftcard_outlined,
                      iconColor: AppColors.lightSuccess,
                      title: 'Redeem Code',
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const RedeemCodeScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced
                // 6. Learning & Support
                _buildSectionHeader(theme, 'LEARNING & SUPPORT'),
                const SizedBox(height: 8), // Reduced
                _buildSettingsCard(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.book_outlined,
                      iconColor: const Color(0xFF0E9F6E), // Darker green
                      title: 'Books to Quit Smoking',
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Icons.help_outline,
                      iconColor: const Color(0xFF3F83F8), // Lighter blue
                      title: 'Help & FAQ',
                      onTap: () {
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: const FaqScreen(),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced
                // 7. Data & Privacy
                _buildSectionHeader(theme, 'DATA & PRIVACY'),
                const SizedBox(height: 8), // Reduced
                _buildSettingsCard(
                  children: [
                    // _ProfileMenuItem(
                    //   icon: Icons.cloud_upload_outlined,
                    //   iconColor: AppColors.lightPrimary,
                    //   title: 'Online Backup',
                    //   onTap: () {},
                    // ),
                    _ProfileMenuItem(
                      icon: Icons.shield_outlined,
                      iconColor: AppColors.lightTextSecondary,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Icons.description_outlined,
                      iconColor: AppColors.lightTextTertiary,
                      title: 'Terms of Service',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced
                // 8. About
                _buildSectionHeader(theme, 'ABOUT'),
                const SizedBox(height: 8), // Reduced
                _buildSettingsCard(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.star_outline,
                      iconColor: AppColors.lightWarning,
                      title: 'Rate App',
                      onTap: () {},
                    ),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      iconColor: AppColors.lightTextSecondary,
                      title: 'About Quit Habit',
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16), // Reduced
                // 9. Sign Out
                _buildSignOutButton(theme),
                const SizedBox(height: 16), // Reduced Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top header with Avatar, Name, and Member Status
  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28, // Reduced
          backgroundColor: AppColors.lightPrimary.withOpacity(0.1),
          // In a real app, this would be an Image.network
          child: const Icon(
            Icons.person,
            color: AppColors.lightPrimary,
            size: 32, // Reduced
          ),
        ),
        const SizedBox(width: 12), // Reduced
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sarah Johnson', // Hardcoded from image
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 20, // Reduced
                fontWeight: FontWeight.w700,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Yearly Pro Member', // Hardcoded from image
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontSize: 14, // Reduced
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the stats row (Days, Saved, Not Smoked)
  Widget _buildStats(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12), // Reduced
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(theme: theme, value: '15', label: 'Days Quit'),
          _buildStatDivider(),
          _StatItem(theme: theme, value: '\$75', label: 'Saved'),
          _buildStatDivider(),
          _StatItem(theme: theme, value: '300', label: 'Not Smoked'),
        ],
      ),
    );
  }

  /// A vertical divider for the stats card
  Widget _buildStatDivider() {
    return Container(
      width: 1.5,
      height: 32,
      color: AppColors.lightBorder,
    ); // Reduced
  }

  /// Builds the grey section header (e.g., "ACCOUNT & PROFILE")
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.labelMedium?.copyWith(
        color: AppColors.lightTextSecondary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        fontSize: 13,
      ),
    );
  }

  /// Builds the "Pro" badge
  Widget _buildProBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.lightError, // Solid red
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Pro',
        style: theme.textTheme.labelSmall?.copyWith(
          color: AppColors.white, // White text
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Builds a white card to hold list items
  Widget _buildSettingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: ListView.separated(
        itemCount: children.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          // Apply clipping for rounded corners on InkWell
          return ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: index == 0 ? const Radius.circular(15) : Radius.zero,
              bottom: index == children.length - 1
                  ? const Radius.circular(15)
                  : Radius.zero,
            ),
            child: children[index],
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          color: AppColors.lightBorder,
          indent: 64, // 16 (pad) + 36 (icon) + 12 (pad)
        ),
      ),
    );
  }

  /// Builds the "Sign Out" button card
  Widget _buildSignOutButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Handle Sign Out
          },
          borderRadius: BorderRadius.circular(15), // match parent
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ), // Reduced
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content
              children: [
                const Icon(Icons.logout, color: AppColors.lightError, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Sign Out',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightError,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper widget for an individual stat item in the stats card
class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.theme,
    required this.value,
    required this.label,
  });

  final ThemeData theme;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18, // Reduced
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.lightTextSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

/// Helper widget for a single menu item in a settings card
class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ), // Reduced
          child: Row(
            children: [
              Container(
                width: 36, // Reduced
                height: 36, // Reduced
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10), // Reduced
                ),
                child: Icon(icon, color: iconColor, size: 20), // Reduced
              ),
              const SizedBox(width: 12), // Reduced
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.lightTextTertiary,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
