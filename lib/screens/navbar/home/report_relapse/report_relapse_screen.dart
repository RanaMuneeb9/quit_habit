import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/navbar/home/calendar/calendar_screen.dart';
import 'package:quit_habit/services/ads_service.dart';
import 'package:quit_habit/services/habit_service.dart';
import 'package:quit_habit/utils/app_colors.dart';

class ReportRelapseScreen extends StatefulWidget {
  final DateTime? initialDate;

  const ReportRelapseScreen({super.key, this.initialDate});

  @override
  State<ReportRelapseScreen> createState() => _ReportRelapseScreenState();
}

class _ReportRelapseScreenState extends State<ReportRelapseScreen> {
  String? _selectedTrigger;
  bool _coinPenaltyActive = true;
  late DateTime _relapseDate;
  bool _isLoading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _triggers = [
    {
      'icon': Icons.sentiment_dissatisfied_outlined,
      'label': 'Stress or anxiety',
    },
    {'icon': Icons.people_outline, 'label': 'Social pressure'},
    {'icon': Icons.sentiment_neutral_outlined, 'label': 'Boredom'},
    {'icon': Icons.celebration_outlined, 'label': 'Celebration/Party'},
    {'icon': Icons.replay_outlined, 'label': 'Old habits/routine'},
    {'icon': Icons.help_outline, 'label': 'Other reason'},
  ];

  final HabitService _habitService = HabitService();
  final AdsService _adsService = AdsService();

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _relapseDate = widget.initialDate ?? today;
    // Ensure date is not in the future
    final todayNormalized = DateTime(today.year, today.month, today.day);
    final dateNormalized = DateTime(
      _relapseDate.year,
      _relapseDate.month,
      _relapseDate.day,
    );
    if (dateNormalized.isAfter(todayNormalized)) {
      _relapseDate = today;
    }
  }

  Future<void> _selectDate() async {
    final today = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _relapseDate,
      firstDate: DateTime(2000),
      lastDate: today, // Cannot select future dates
      helpText: 'Select relapse date',
    );

    if (pickedDate != null) {
      setState(() {
        _relapseDate = pickedDate;
      });
    }
  }

  Future<void> _handleConfirm() async {
    // Validation: trigger must be selected
    if (_selectedTrigger == null || _selectedTrigger!.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please select a trigger for this relapse';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a trigger for this relapse'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to report a relapse'),
          backgroundColor: AppColors.lightError,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Apply coin penalty if enabled
      if (_coinPenaltyActive) {
        // Deduct coins first - this will throw if insufficient funds
        await _adsService.deductCoins(user.uid, 10);
      }

      // Add relapse
      await _habitService.addRelapse(
        user.uid,
        _relapseDate,
        _selectedTrigger!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relapse reported successfully'),
            backgroundColor: AppColors.lightSuccess,
          ),
        );

        // Navigate to calendar screen (historical report)
        Navigator.pop(context);
        PersistentNavBarNavigator.pushNewScreen(
          context,
          screen: const CalendarScreen(allowAddRelapse: true),
          withNavBar: false,
          pageTransitionAnimation: PageTransitionAnimation.cupertino,
        );
      }
    } on HabitServiceException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to report relapse: ${e.toString()}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to report relapse: ${e.toString()}'),
            backgroundColor: AppColors.lightError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Error Banner
            _buildTopBanner(context, theme),

            // 2. Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Relapse Date Card
                      _buildRelapseDateCard(theme),
                      const SizedBox(height: 12),

                      // Headers
                      Text(
                        'What triggered this relapse?',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Triggers Grid
                      _buildTriggersGrid(theme),
                      const SizedBox(height: 12),

                      // Coin Penalty Card
                      _buildCoinPenaltyCard(theme),
                      const SizedBox(height: 12),

                      // Error message if any
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.lightError.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.lightError.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.lightError,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.lightError,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Action Buttons
                      _buildActionButtons(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context, ThemeData theme) {
    return Container(
      // --- COMPACTED ---
      padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.lightError.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: AppColors.lightError.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.lightError,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Report Relapse",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.lightError,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "It's okay, setbacks happen. Let's learn from this.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.lightError.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.lightTextSecondary),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildRelapseDateCard(ThemeData theme) {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        // --- COMPACTED ---
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Relapse Date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(_relapseDate),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: AppColors.lightError,
                size: 24,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTriggersGrid(ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // --- UPDATED: Child Aspect Ratio to fix cutoff ---
        childAspectRatio: 1.5,
      ),
      itemCount: _triggers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final trigger = _triggers[index];
        final isSelected = _selectedTrigger == trigger['label'];
        return _TriggerOptionCard(
          icon: trigger['icon'],
          label: trigger['label'],
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedTrigger = trigger['label'];
            });
          },
        );
      },
    );
  }

  Widget _buildCoinPenaltyCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Padding(
            // --- COMPACTED ---
            padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightWarning.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time,
                    color: AppColors.lightWarning,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coin Penalty',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '10 coins will be deducted',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Switch(
                //   value: _coinPenaltyActive,
                //   onChanged: (val) {
                //     setState(() {
                //       _coinPenaltyActive = val;
                //     });
                //   },
                //   activeColor: AppColors.lightPrimary,
                // )
              ],
            ),
          ),
          const Divider(height: 1.5, color: AppColors.lightBorder),
          Padding(
            // --- COMPACTED ---
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.lightTextTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This helps you stay accountable to your recovery journey',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        // Cancel Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.white,
                side: const BorderSide(
                  color: AppColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Cancel',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Confirm Button
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: (_selectedTrigger == null || _isLoading)
                  ? null
                  : _handleConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                disabledBackgroundColor: AppColors.lightPrimary.withValues(
                  alpha: 0.4,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Confirm',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// Helper widget for the trigger option cards
class _TriggerOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TriggerOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? AppColors.lightPrimary
        : AppColors.lightTextPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.lightPrimary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.lightPrimary : AppColors.lightBorder,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.lightPrimary.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}