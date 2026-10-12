import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/workout_history_store.dart';
import '../models/workout_summary.dart';
import '../pose/pose_detector_service.dart';
import 'squat_analyzer.dart';
import 'squat_rep_counter.dart';

class WorkoutController extends ChangeNotifier {
  WorkoutController({WorkoutHistoryStore? historyStore})
      : _historyStore = historyStore ?? WorkoutHistoryStore();

  final WorkoutHistoryStore _historyStore;
  final PoseDetectorService _poseDetector = PoseDetectorService();
  final SquatAnalyzer _analyzer = SquatAnalyzer();
  final SquatRepCounter _repCounter = SquatRepCounter();
  CameraController? cameraController;
  CameraDescription? _cameraDescription;
  List<Pose> poses = const [];
  SquatAssessment assessment = const SquatAssessment(
    phase: SquatPhase.unavailable,
    kneeAngle: null,
    feedback: 'กำลังเตรียมกล้อง',
    hasFullBody: false,
    goodDepth: false,
  );
  String? errorMessage;
  bool isStarting = true;
  bool isProcessing = false;
  bool _disposed = false;
  DateTime? _startedAt;

  int get totalReps => _repCounter.totalReps;
  int get correctReps => _repCounter.correctReps;
  int get incorrectReps => totalReps - correctReps;
  int get accuracyPercent =>
      totalReps == 0 ? 0 : (correctReps * 100 / totalReps).round();

  Future<void> start() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        errorMessage = 'ต้องอนุญาตให้ใช้กล้องเพื่อเริ่มออกกำลังกาย';
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        errorMessage = 'ไม่พบกล้องในอุปกรณ์นี้';
        return;
      }
      _cameraDescription = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        _cameraDescription!,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      cameraController = controller;
      await controller.initialize();
      _startedAt = DateTime.now();
      await controller.startImageStream(_onImage);
    } catch (error) {
      errorMessage = 'เปิดกล้องไม่สำเร็จ: $error';
    } finally {
      isStarting = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _onImage(CameraImage image) async {
    if (_disposed || isProcessing || _cameraDescription == null) return;
    isProcessing = true;
    try {
      final detected = await _poseDetector.process(
        image,
        _cameraDescription!.sensorOrientation,
      );
      poses = detected;
      if (detected.isEmpty) {
        assessment = const SquatAssessment(
          phase: SquatPhase.unavailable,
          kneeAngle: null,
          feedback: 'กรุณาอยู่หน้ากล้องและให้เห็นร่างกายเต็มตัว',
          hasFullBody: false,
          goodDepth: false,
        );
      } else {
        assessment = _analyzer.analyze(detected.first);
      }
      _repCounter.update(assessment);
    } catch (error) {
      errorMessage = 'ตรวจจับท่าทางไม่สำเร็จ: $error';
      assessment = const SquatAssessment(
        phase: SquatPhase.unavailable,
        kneeAngle: null,
        feedback: 'ตรวจจับท่าทางไม่สำเร็จ กรุณาจัดตำแหน่งกล้องใหม่',
        hasFullBody: false,
        goodDepth: false,
      );
      _repCounter.update(assessment);
    } finally {
      isProcessing = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<WorkoutSummary> finish() async {
    final controller = cameraController;
    if (controller != null && controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    final now = DateTime.now();
    final summary = WorkoutSummary(
      totalReps: totalReps,
      correctReps: correctReps,
      completedAt: now,
      durationSeconds: now.difference(_startedAt ?? now).inSeconds,
    );
    await _historyStore.save(summary);
    return summary;
  }

  @override
  void dispose() {
    _disposed = true;
    final controller = cameraController;
    if (controller != null) {
      if (controller.value.isStreamingImages) {
        unawaited(controller.stopImageStream());
      }
      unawaited(controller.dispose());
    }
    unawaited(_poseDetector.close());
    super.dispose();
  }
}