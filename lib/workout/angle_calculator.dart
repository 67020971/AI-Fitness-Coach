import 'dart:math' as math;

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  const AngleCalculator();

  double between(PoseLandmark first, PoseLandmark vertex, PoseLandmark last) {
    final firstX = first.x - vertex.x;
    final firstY = first.y - vertex.y;
    final lastX = last.x - vertex.x;
    final lastY = last.y - vertex.y;
    final firstLength = math.sqrt(firstX * firstX + firstY * firstY);
    final lastLength = math.sqrt(lastX * lastX + lastY * lastY);

    if (firstLength == 0 || lastLength == 0) return double.nan;

    final cosine = ((firstX * lastX + firstY * lastY) /
            (firstLength * lastLength))
        .clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }
}