import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../pose/pose_skeleton_painter.dart';
import '../workout/squat_analyzer.dart';
import '../workout/workout_controller.dart';
import 'result_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  late final WorkoutController _workout;

  @override
  void initState() {
    super.initState();
    _workout = WorkoutController()..start();
  }

  @override
  void dispose() {
    _workout.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final summary = await _workout.finish();
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(summary: summary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Squat Workout'),
        actions: [
          AnimatedBuilder(
            animation: _workout,
            builder: (context, _) => TextButton.icon(
              onPressed: _workout.isStarting ? null : _finish,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Finish'),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _workout,
        builder: (context, _) {
          final controller = _workout.cameraController;
          return Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: const Color(0xFF14231F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _cameraView(controller),
                ),
              ),
              if (_workout.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _workout.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              _statsPanel(),
            ],
          );
        },
      ),
    );
  }

  Widget _cameraView(CameraController? controller) {
    if (_workout.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _workout.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    if (_workout.isStarting || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    final previewSize = controller.value.previewSize;
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        if (previewSize != null)
          CustomPaint(
            painter: PoseSkeletonPainter(
              poses: _workout.poses,
              imageSize: previewSize,
              mirror: controller.description.lensDirection ==
                  CameraLensDirection.front,
            ),
          ),
        Positioned(
          left: 12,
          top: 12,
          child: _tag('SQUAT  /  LIVE', const Color(0xFF14231F)),
        ),
      ],
    );
  }

  Widget _tag(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.88),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  Widget _statsPanel() {
    final isDown = _workout.assessment.phase == SquatPhase.down;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _stat('REPS', '${_workout.totalReps}', large: true),
              ),
              Expanded(child: _stat('CORRECT', '${_workout.correctReps}')),
              Expanded(child: _stat('INCORRECT', '${_workout.incorrectReps}')),
              Expanded(child: _stat('ACCURACY', '${_workout.accuracyPercent}%')),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDown
                      ? const Color(0xFFE6F5CD)
                      : const Color(0xFFE7EAE4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _workout.assessment.phase.name.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 10),
              if (_workout.assessment.kneeAngle != null)
                Text('${_workout.assessment.kneeAngle!.round()}°'),
              const Spacer(),
              Flexible(
                child: Text(
                  _workout.assessment.feedback,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, {bool large = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF68736D),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF14231F),
              fontSize: large ? 30 : 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      );
}