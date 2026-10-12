import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseDetectorService {
  final PoseDetector _detector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream),
  );

  Future<List<Pose>> process(CameraImage image, int sensorOrientation) async {
    final rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (rotation == null ||
        format == null ||
        image.planes.length != 1 ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return const [];
    }

    final plane = image.planes.single;
    final inputImage = InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
    return _detector.processImage(inputImage);
  }

  Future<void> close() => _detector.close();
}