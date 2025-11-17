import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/chat/chat_screen.dart';
import 'package:quit_habit/utils/app_colors.dart';

class ChatOnboardingScreen extends StatelessWidget {
  const ChatOnboardingScreen({super.key});

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
            Icons.arrow_back,
            color: AppColors.lightTextPrimary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo with Gradient
              SizedBox(
                    width: 130,
                    height: 100,
                    child: SvgPicture.asset(
                      'images/icons/app_icon.svg',
                    ),
                  ),
              // Container(
              //   width: 80,
              //   height: 80,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(20),
              //     gradient: const LinearGradient(
              //       begin: Alignment.topLeft,
              //       end: Alignment.bottomRight,
              //       colors: [
              //         AppColors.lightSecondary, // Purple
              //         AppColors.lightPrimary,   // Blue
              //       ],
              //     ),
              //     boxShadow: [
              //       BoxShadow(
              //         color: AppColors.lightSecondary.withOpacity(0.3),
              //         blurRadius: 20,
              //         offset: const Offset(0, 10),
              //       ),
              //     ],
              //   ),
              //   child: const Icon(
              //     Icons.history_toggle_off_rounded, // Closest approximation to the icon in image
              //     color: AppColors.white,
              //     size: 40,
              //   ),
              // ),

              const SizedBox(height: 10),

              // Title
              Text(
                'Welcome to\nQUIT AI',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: AppColors.lightTextPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Start chatting with ChattyAI now.\nYou can ask me anything.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.lightTextSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56, // Slightly taller for emphasis
                child: ElevatedButton(
                  onPressed: () {
                    PersistentNavBarNavigator.pushNewScreen(
                      context,
                      screen: const ChatScreen(),
                      withNavBar: false,
                      pageTransitionAnimation:
                          PageTransitionAnimation.cupertino,
                    );
                  },
                  style: theme.elevatedButtonTheme.style?.copyWith(
                    backgroundColor: WidgetStateProperty.all(AppColors.lightPrimary),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    elevation: WidgetStateProperty.all(0),
                  ),
                  child: Text(
                    'Get Started',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}