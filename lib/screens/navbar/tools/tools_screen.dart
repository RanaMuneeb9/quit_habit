import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:quit_habit/screens/navbar/tools/breathing/breathing_screen.dart';
import 'package:quit_habit/screens/navbar/tools/inspiration/inspiration_quotes_screen.dart';
import 'package:quit_habit/screens/navbar/tools/jumping_jacks/jumping_jacks_screen.dart';
import 'package:quit_habit/screens/navbar/tools/meditation/meditation_screen.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const BreathingScreen(),
                withNavBar: false, // Hide nav bar on the relapse screen
                pageTransitionAnimation: PageTransitionAnimation.sizeUp,
              );
            },
            child: Text("Breathing Screen"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const MeditationScreen(),
                withNavBar: false, // Hide nav bar on the relapse screen
                pageTransitionAnimation: PageTransitionAnimation.sizeUp,
              );
            },
            child: Text("Meditation Screen"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const JumpingJacksScreen(),
                withNavBar: false, // Hide nav bar on the relapse screen
                pageTransitionAnimation: PageTransitionAnimation.sizeUp,
              );
            },
            child: Text("Jumping Jacks"),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const InspirationQuotesScreen(),
                withNavBar: false, // Hide nav bar on the relapse screen
                pageTransitionAnimation: PageTransitionAnimation.sizeUp,
              );
            },
            child: Text("Quotes Screen"),
          ),
        ],
      ),
    );
  }
}
