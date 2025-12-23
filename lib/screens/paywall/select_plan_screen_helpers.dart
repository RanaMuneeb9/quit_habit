import 'package:flutter/material.dart';
import 'package:quit_habit/utils/app_colors.dart';

extension SelectPlanScreenHelpers on State {
  Widget buildFooterLink(BuildContext context, String title, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.lightTextSecondary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        "•",
        style: TextStyle(color: AppColors.lightTextTertiary),
      ),
    );
  }
}
