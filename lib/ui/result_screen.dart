import 'package:flutter/material.dart';

import '../ai/ai_analysis_service.dart';
import '../models/workout_summary.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({required this.summary, super.key});

  final WorkoutSummary summary;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _ai = AiAnalysisService();
  String? _analysis;
  String? _error;
  bool _loading = false;

  Future<void> _analyze() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _ai.analyze(widget.summary);
      if (mounted) setState(() => _analysis = result);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ai.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    return Scaffold(
      appBar: AppBar(title: const Text('Workout Result')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              'Session complete',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF14231F),
                  ),
            ),
            const SizedBox(height: 5),
            Text('Exercise: Squat  •  ${summary.completedAt.toLocal()}'),
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _resultRow('Total Reps', '${summary.totalReps}'),
                    _resultRow('Correct', '${summary.correctReps}'),
                    _resultRow('Incorrect', '${summary.incorrectReps}'),
                    _resultRow('Accuracy', '${summary.accuracyPercent}%'),
                    _resultRow('Duration', _duration(summary.durationSeconds)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loading ? null : _analyze,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_loading ? 'กำลังวิเคราะห์...' : 'Analyze with AI'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
              if (!_ai.isConfigured)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'ตั้งค่า key ด้วย --dart-define=GEMINI_API_KEY=... ก่อนรันแอป',
                  ),
                ),
            ],
            if (_analysis != null) ...[
              const SizedBox(height: 14),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(_analysis!, style: const TextStyle(height: 1.5)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const HistoryScreen(),
                ),
                (route) => route.isFirst,
              ),
              icon: const Icon(Icons.history),
              label: const Text('View workout history'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      );

  String _duration(int seconds) => '${seconds ~/ 60} min ${seconds % 60} sec';
}