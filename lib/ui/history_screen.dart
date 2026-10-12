import 'package:flutter/material.dart';

import '../data/workout_history_store.dart';
import '../models/workout_summary.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _store = WorkoutHistoryStore();
  late Future<List<WorkoutSummary>> _history;

  @override
  void initState() {
    super.initState();
    _history = _store.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: FutureBuilder<List<WorkoutSummary>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? const <WorkoutSummary>[];
          if (entries.isEmpty) {
            return const Center(child: Text('ยังไม่มีประวัติการออกกำลังกาย'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = entries[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE6F5CD),
                    child: Icon(Icons.fitness_center, color: Color(0xFF14231F)),
                  ),
                  title: Text(
                    '${session.totalReps} Squats  •  ${session.accuracyPercent}%',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${session.completedAt.toLocal()}\n'
                    'ถูก ${session.correctReps}  /  ผิด ${session.incorrectReps}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}