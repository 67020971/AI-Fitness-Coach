import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_summary.dart';

class WorkoutHistoryStore {
  static const _key = 'workout_history_v1';

  Future<List<WorkoutSummary>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList(_key) ?? const <String>[];
    return entries.map((entry) {
      try {
        return WorkoutSummary.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
      } on FormatException {
        return null;
      } on TypeError {
        return null;
      }
    }).whereType<WorkoutSummary>().toList();
  }

  Future<void> save(WorkoutSummary summary) async {
    final preferences = await SharedPreferences.getInstance();
    final entries = preferences.getStringList(_key) ?? <String>[];
    entries.insert(0, jsonEncode(summary.toJson()));
    await preferences.setStringList(_key, entries.take(50).toList());
  }
}