import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'dart:math' as math; // For rotating the arrow

// --- Converted to StatefulWidget ---
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  // --- Added FAQ data ---
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I reset my quit date?',
      'answer':
          'You can reset your quit date by going to Profile > My Data > Update Information. Select a new date and confirm your changes.'
    },
    {
      'question': 'What are the benefits of Pro?',
      'answer':
          'Pro benefits include advanced statistics, unlimited access to all tools (like meditation and challenges), and a personalized quit plan.'
    },
    {
      'question': 'How does backup work?',
      'answer':
          'Your data is automatically backed up to the cloud if you are signed in. This ensures your progress is safe even if you change devices.'
    },
    {
      'question': 'Can I use the app offline?',
      'answer':
          'Yes, most features like streak tracking and basic tools work offline. An internet connection is only required for syncing your data.'
    },
    {
      'question': 'How do I share my progress?',
      'answer':
          'You can share your progress from the Home screen or Profile screen. Look for the "Share" icon to create a custom image of your achievements.'
    },
  ];

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
                'Help & FAQ',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Get answers to common questions',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 32),

              // Support Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightSecondary.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.help_outline_rounded,
                      color: AppColors.lightSecondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Can't find your answer? Contact our support team.",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- Using new _FaqItem widget ---
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _faqs.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _FaqItem(
                    theme: theme,
                    question: _faqs[index]['question']!,
                    answer: _faqs[index]['answer']!,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW StatefulWidget for the FAQ item ---
class _FaqItem extends StatefulWidget {
  final ThemeData theme;
  final String question;
  final String answer;

  const _FaqItem({
    required this.theme,
    required this.question,
    required this.answer,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = Tween(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleExpand,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Leading icon in a circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.lightBackground,
                        shape: BoxShape.circle,
                      ),
                      // --- Animated Arrow ---
                      child: RotationTransition(
                        turns: _animation,
                        child: Icon(
                          Icons.chevron_right_rounded, // Original icon
                          color: _isExpanded
                              ? AppColors.lightPrimary
                              : AppColors.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Question text
                    Expanded(
                      child: Text(
                        widget.question,
                        style: widget.theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                // --- Animated Answer Section ---
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Container(
                    height: _isExpanded ? null : 0,
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 32 + 16, // Align with question text
                      right: 0,
                    ),
                    child: Text(
                      widget.answer,
                      style: widget.theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightTextSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
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