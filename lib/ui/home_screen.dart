import 'package:flutter/material.dart';

import '../data/workout_history_store.dart';
import 'history_screen.dart';
import 'workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.fitness_center, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'AI FITNESS COACH',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'ประวัติการออกกำลังกาย',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const HistoryScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.history),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 52,
                height: 6,
                color: const Color(0xFFC6F36B),
              ),
              const SizedBox(height: 22),
              Text(
                'Train with\nbetter form.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: const Color(0xFF14231F),
                      fontWeight: FontWeight.w800,
                      height: 1.02,
                    ),
              ),
              const SizedBox(height: 14),
              Text(
                'โค้ชท่า Squat แบบเรียลไทม์\nพร้อมสรุปผลทุกครั้งที่ฝึก',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF5E6B65),
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const WorkoutScreen(),
                  ),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Workout'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryScreen(),
                  ),
                ),
                icon: const Icon(Icons.history),
                label: const Text('History'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF14231F),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(),
              FutureBuilder(
                future: WorkoutHistoryStore().load(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length ?? 0;
                  return Text(
                    '$count WORKOUT${count == 1 ? '' : 'S'} SAVED',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF77817B),
                          fontWeight: FontWeight.w700,
                        ),
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