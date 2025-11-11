import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';
import 'dart:math'; // For a bit of variety in quotes

// A simple model for our quotes
class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});
}

class InspirationQuotesScreen extends StatefulWidget {
  const InspirationQuotesScreen({super.key});

  @override
  State<InspirationQuotesScreen> createState() =>
      _InspirationQuotesScreenState();
}

class _InspirationQuotesScreenState extends State<InspirationQuotesScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  final Set<String> _favorites = {}; // Use a Set for efficient lookups

  // Dummy quote data
  final List<Quote> _quotes = [
    Quote(
      text: "The secret of getting ahead is getting started.",
      author: "Mark Twain",
    ),
    Quote(
      text: "It does not matter how slowly you go as long as you do not stop.",
      author: "Confucius",
    ),
    Quote(
      text:
          "Our greatest weakness lies in giving up. The most certain way to succeed is always to try just one more time.",
      author: "Thomas A. Edison",
    ),
    Quote(
      text: "Believe you can and you're halfway there.",
      author: "Theodore Roosevelt",
    ),
    Quote(
      text: "The future depends on what you do today.",
      author: "Mahatma Gandhi",
    ),
    Quote(
      text: "Success is the sum of small efforts, repeated day in and day out.",
      author: "Robert Collier",
    ),
    Quote(
      text:
          "Strength does not come from physical capacity. It comes from an indomitable will.",
      author: "Mahatma Gandhi",
    ),
    Quote(
      text: "Either you run the day, or the day runs you.",
      author: "Jim Rohn",
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start at a random quote for variety
    _currentIndex = Random().nextInt(_quotes.length);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _nextQuote() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _previousQuote() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _toggleFavorite() {
    final currentQuote = _quotes[_currentIndex];
    setState(() {
      if (_favorites.contains(currentQuote.text)) {
        _favorites.remove(currentQuote.text);
      } else {
        _favorites.add(currentQuote.text);
      }
    });
  }

  void _shareQuote() {
    // TODO: Implement sharing logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing not implemented yet!')),
    );
  }

  bool get _isFavorite {
    return _favorites.contains(_quotes[_currentIndex].text);
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
        titleSpacing: 24.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inspiration',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: AppColors.lightTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Daily Motivation',
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
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16), // Compacted
              // 1. Stats Cards
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: '${_currentIndex + 1} of ${_quotes.length}',
                      label: 'Daily Quote',
                      bgColor: AppColors.white,
                      textColor: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      value: _favorites.length.toString(),
                      label: 'Favorites',
                      bgColor: AppColors.lightError.withAlpha(20), // ~8%
                      textColor: AppColors.lightError,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Compacted
              // 2. Category Chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightPrimary.withAlpha(25), // ~10%
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_outlined,
                      color: AppColors.lightPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Motivation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.lightPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Compacted
              // 3. Quote PageView
              SizedBox(
                height: 220, // Fixed height for PageView
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _quotes.length,
                  itemBuilder: (context, index) {
                    return _buildQuoteCard(theme, quote: _quotes[index]);
                  },
                ),
              ),
              const SizedBox(height: 16), // Compacted
              // 4. Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    theme,
                    icon: _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: _toggleFavorite,
                    color: _isFavorite
                        ? AppColors.lightError
                        : AppColors.lightTextSecondary,
                  ),
                  const SizedBox(width: 16),
                  _buildActionButton(
                    theme,
                    icon: Icons.share_outlined,
                    onTap: _shareQuote,
                    color: AppColors.lightTextSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16), // Compacted
              // 5. Navigation
              Row(
                children: [
                  _buildNavArrow(
                    theme,
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: _previousQuote,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _quotes.length,
                        (index) => _buildPageIndicator(
                          theme,
                          isActive: index == _currentIndex,
                        ),
                      ),
                    ),
                  ),
                  _buildNavArrow(
                    theme,
                    icon: Icons.arrow_forward_ios_rounded,
                    onTap: _nextQuote,
                    isPrimary: true,
                  ),
                ],
              ),
              const SizedBox(height: 24), // Compacted
              // 6. Info Box
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
                        'Read one inspiring message daily to reinforce your commitment. Save favorites to revisit when motivation is low.',
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

  /// Helper for top stat cards
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

  /// Helper for the quote card
  Widget _buildQuoteCard(ThemeData theme, {required Quote quote}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), // For shadow
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"',
            style: theme.textTheme.displayLarge?.copyWith(
              color: AppColors.lightPrimary,
              fontSize: 48,
              height: 1.0,
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                quote.text,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontSize: 18, // Compacted
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "— ${quote.author}",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Helper for action buttons (Favorite, Share)
  Widget _buildActionButton(
    ThemeData theme, {
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Container(
      width: 52, // Compacted
      height: 52, // Compacted
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(26),
          child: Icon(icon, color: color, size: 24), // Compacted
        ),
      ),
    );
  }

  /// Helper for navigation arrows
  Widget _buildNavArrow(
    ThemeData theme, {
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Container(
      width: 44, // Compacted
      height: 44, // Compacted
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.lightPrimary : AppColors.white,
        shape: BoxShape.circle,
        border: isPrimary
            ? null
            : Border.all(color: AppColors.lightBorder, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.lightShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Icon(
            icon,
            color: isPrimary ? AppColors.white : AppColors.lightTextPrimary,
            size: 18, // Compacted
          ),
        ),
      ),
    );
  }

  /// Helper for page indicator dots
  Widget _buildPageIndicator(ThemeData theme, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: isActive ? 16 : 6, // Compacted
      height: 6, // Compacted
      decoration: BoxDecoration(
        color: isActive ? AppColors.lightPrimary : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
