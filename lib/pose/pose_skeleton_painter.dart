import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseSkeletonPainter extends CustomPainter {
  const PoseSkeletonPainter({
    required this.poses,
    required this.imageSize,
    required this.mirror,
  });

  final List<Pose> poses;
  final Size imageSize;
  final bool mirror;

  static const _connections = <(PoseLandmarkType, PoseLandmarkType)>[
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow),
    (PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow),
    (PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist),
    (PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip),
    (PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.rightHip),
    (PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee),
    (PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle),
    (PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee),
    (PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.isEmpty) return;
    final scaleX = size.width / imageSize.height;
    final scaleY = size.height / imageSize.width;
    Offset point(PoseLandmark landmark) {
      final x = landmark.x * scaleX;
      return Offset(mirror ? size.width - x : x, landmark.y * scaleY);
    }

    final linePaint = Paint()
      ..color = const Color(0xFFC6F36B)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final dotPaint = Paint()..color = Colors.white;

    for (final pose in poses) {
      for (final (startType, endType) in _connections) {
        final start = pose.landmarks[startType];
        final end = pose.landmarks[endType];
        if (start != null && end != null) {
          canvas.drawLine(point(start), point(end), linePaint);
        }
      }
      for (final landmark in pose.landmarks.values) {
        canvas.drawCircle(point(landmark), 4, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PoseSkeletonPainter oldDelegate) =>
      oldDelegate.poses != poses ||
      oldDelegate.imageSize != imageSize ||
      oldDelegate.mirror != mirror;
}