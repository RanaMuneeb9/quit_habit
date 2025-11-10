import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/tools/breathing/breathing_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            PersistentNavBarNavigator.pushNewScreen(
              context,
              screen: const BreathingScreen(),
              withNavBar: false, // Hide nav bar on the relapse screen
              pageTransitionAnimation: PageTransitionAnimation.sizeUp,
            );
          },
          child: Text("Tools Screen"),
        ),
      ),
    );
  }
}
