import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/services/plan_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  const SubscriptionStatusScreen({super.key});

  @override
  State<SubscriptionStatusScreen> createState() => _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  bool _isCancelling = false;

  Future<void> _cancelSubscription() async {
    if (_isCancelling) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your Pro subscription? You will lose access to:\n\n• 90-Day Quit Plan\n• Unlimited Challenges\n• Advanced Analytics\n• Expert Support',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Pro'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.lightError,
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.uid;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Remove Pro status
      await PlanService.instance.cancelSubscription(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription cancelled. You\'ve been downgraded to a free account.'),
            backgroundColor: AppColors.lightSuccess,
          ),
        );
        // Pop back to profile screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel subscription: $e'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.lightTextPrimary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Subscription',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage your plan',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 32),

              // Subscription Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.lightPrimary, width: 1.5),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Plan Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Yearly Plan',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: AppColors.lightPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Price
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '\$49.99',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: AppColors.lightPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 36,
                            ),
                          ),
                          TextSpan(
                            text: ' / per year',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: AppColors.lightTextSecondary,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: AppColors.lightBorder),
                    const SizedBox(height: 24),
                    // Benefits List
                    _buildBenefitItem(
                      theme,
                      icon: Icons.calendar_today_outlined,
                      iconColor: AppColors.lightPrimary,
                      title: 'Your 90-Day Journey Begins',
                      subtitle: 'Personalized daily plan ready for you',
                    ),
                    const SizedBox(height: 20),
                    _buildBenefitItem(
                      theme,
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.lightSuccess,
                      title: 'Track Your Progress',
                      subtitle: 'Watch your success grow every day',
                    ),
                    const SizedBox(height: 20),
                    _buildBenefitItem(
                      theme,
                      icon: Icons.favorite_border_rounded,
                      iconColor: const Color(0xFF9B6CF6), // Purple from design
                      title: 'Expert Support',
                      subtitle: 'Guidance whenever you need it',
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Handle manage subscription
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.lightTextPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Manage Subscription',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: _isCancelling ? null : _cancelSubscription,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lightError.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.lightError),
                          ),
                        )
                      : Text(
                          'Cancel Subscription',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightError,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(
    ThemeData theme, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
