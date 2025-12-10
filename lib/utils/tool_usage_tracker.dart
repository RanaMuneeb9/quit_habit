import 'package:shared_preferences/shared_preferences.dart';

class ToolUsageTracker {
  static const String _breathing = 'Breathing';
  static const String _workout = 'Physical Workout';
  static const String _meditation = 'Meditation';
  static const String _inspiration = 'Inspiration';
  static const String _resources = 'Resources';
  static const String _mood = 'Mood Check-in';

  static final List<String> allTools = [
    _breathing,
    _workout,
    _meditation,
    _inspiration,
    _resources,
    _mood,
  ];

  /// Tracks usage for a specific tool
  static Future<void> trackUsage(String toolName) async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('tool_usage_$toolName') ?? 0;
    await prefs.setInt('tool_usage_$toolName', current + 1);
  }

  /// Loads usage stats and returns the tool with the most usage and its count.
  /// Returns a Map with 'name' (String) and 'count' (int).
  static Future<Map<String, dynamic>> getMostUsedTool() async {
    final prefs = await SharedPreferences.getInstance();
    
    int max = -1;
    String most = _breathing; // Default

    for (var t in allTools) {
      int count = prefs.getInt('tool_usage_$t') ?? 0;
      if (count > max) {
        max = count;
        most = t;
      }
    }

    if (max <= 0) {
       max = 0;
       // Could stick with default or return null/empty if logic requires
    }

    return {'name': most, 'count': max};
  }
}
