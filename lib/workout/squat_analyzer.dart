import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'angle_calculator.dart';

enum SquatPhase { up, down, transition, unavailable }

class SquatAssessment {
  const SquatAssessment({
    required this.phase,
    required this.kneeAngle,
    required this.feedback,
    required this.hasFullBody,
    required this.goodDepth,
  });

  final SquatPhase phase;
  final double? kneeAngle;
  final String feedback;
  final bool hasFullBody;
  final bool goodDepth;
}

class SquatAnalyzer {
  SquatAnalyzer({AngleCalculator angleCalculator = const AngleCalculator()})
      : _angleCalculator = angleCalculator;

  final AngleCalculator _angleCalculator;

  SquatAssessment analyze(Pose pose) {
    final requiredTypes = [
      PoseLandmarkType.leftHip,
      PoseLandmarkType.leftKnee,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.rightKnee,
      PoseLandmarkType.rightAnkle,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
    ];
    final landmarks = requiredTypes.map((type) => pose.landmarks[type]);
    if (landmarks.any((landmark) => landmark == null)) {
      return const SquatAssessment(
        phase: SquatPhase.unavailable,
        kneeAngle: null,
        feedback: 'กรุณาอยู่หน้ากล้องและให้เห็นร่างกายเต็มตัว',
        hasFullBody: false,
        goodDepth: false,
      );
    }

    final leftAngle = _angleCalculator.between(
      pose.landmarks[PoseLandmarkType.leftHip]!,
      pose.landmarks[PoseLandmarkType.leftKnee]!,
      pose.landmarks[PoseLandmarkType.leftAnkle]!,
    );
    final rightAngle = _angleCalculator.between(
      pose.landmarks[PoseLandmarkType.rightHip]!,
      pose.landmarks[PoseLandmarkType.rightKnee]!,
      pose.landmarks[PoseLandmarkType.rightAnkle]!,
    );
    if (!leftAngle.isFinite || !rightAngle.isFinite) {
      return const SquatAssessment(
        phase: SquatPhase.unavailable,
        kneeAngle: null,
        feedback: 'ขยับให้เห็นแนวขาและข้อเท้าชัดเจน',
        hasFullBody: false,
        goodDepth: false,
      );
    }

    final angle = (leftAngle + rightAngle) / 2;
    final phase = angle < 110
        ? SquatPhase.down
        : angle > 160
            ? SquatPhase.up
            : SquatPhase.transition;
    final goodDepth = angle >= 70 && angle < 110;
    final feedback = angle < 70
        ? 'ควบคุมการย่อตัว อย่าฝืนลงลึกเกินไป'
        : phase == SquatPhase.down
            ? 'ท่าถูกต้อง'
            : phase == SquatPhase.up
                ? 'ยืดตัวขึ้น'
                : 'ย่อตัวลงอีก';

    return SquatAssessment(
      phase: phase,
      kneeAngle: angle,
      feedback: feedback,
      hasFullBody: true,
      goodDepth: goodDepth,
    );
  }
}