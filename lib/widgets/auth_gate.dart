import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quit_habit/providers/auth_provider.dart';
import 'package:quit_habit/screens/after_login_questionnaire/questionnaire1_screen.dart';
import 'package:quit_habit/screens/auth/login/login_screen.dart';
import 'package:quit_habit/screens/navbar/navbar.dart';
import 'package:quit_habit/utils/app_colors.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading indicator while checking auth status
        if (authProvider.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.lightBackground,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Not authenticated - show login screen
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        // Authenticated but hasn't completed questionnaire - show questionnaire
        if (!authProvider.hasCompletedQuestionnaire) {
          return const Questionnaire1Screen();
        }

        // Authenticated and completed questionnaire - show main app
        return const NavBar();
      },
    );
  }
}

