import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'coordinates_translator.dart';

class PosePainter extends CustomPainter {
  PosePainter(
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  );

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // TO DO: let user customize overlay
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0
      ..color = Colors.red;

    for (final pose in poses) {
      pose.landmarks.forEach((_, landmark) {
        // ignore face, fingers, and toes
        if( landmark == pose.landmarks[PoseLandmarkType.nose] ||
            landmark == pose.landmarks[PoseLandmarkType.leftEyeInner] ||
            landmark == pose.landmarks[PoseLandmarkType.leftEye] ||
            landmark == pose.landmarks[PoseLandmarkType.leftEyeOuter] ||
            landmark == pose.landmarks[PoseLandmarkType.rightEyeInner] ||
            landmark == pose.landmarks[PoseLandmarkType.rightEye] ||
            landmark == pose.landmarks[PoseLandmarkType.rightEyeOuter] ||
            landmark == pose.landmarks[PoseLandmarkType.leftEar] ||
            landmark == pose.landmarks[PoseLandmarkType.rightEar] ||
            landmark == pose.landmarks[PoseLandmarkType.leftMouth] ||
            landmark == pose.landmarks[PoseLandmarkType.rightMouth] ||
            landmark == pose.landmarks[PoseLandmarkType.leftPinky] ||
            landmark == pose.landmarks[PoseLandmarkType.rightPinky] ||
            landmark == pose.landmarks[PoseLandmarkType.leftIndex] ||
            landmark == pose.landmarks[PoseLandmarkType.rightIndex] ||
            landmark == pose.landmarks[PoseLandmarkType.leftThumb] ||
            landmark == pose.landmarks[PoseLandmarkType.rightThumb] ||
            landmark == pose.landmarks[PoseLandmarkType.leftHeel] ||
            landmark == pose.landmarks[PoseLandmarkType.rightHeel] ||
            landmark == pose.landmarks[PoseLandmarkType.leftFootIndex] ||
            landmark == pose.landmarks[PoseLandmarkType.rightFootIndex] ) {
          return;
        }
        canvas.drawCircle(
            Offset(
              translateX(
                landmark.x,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
              translateY(
                landmark.y,
                size,
                imageSize,
                rotation,
                cameraLensDirection,
              ),
            ),
            5,
            paint);
      });

      void paintLine(
          PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;
        canvas.drawLine(
            Offset(
                translateX(
                  joint1.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint1.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            Offset(
                translateX(
                  joint2.x,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                ),
                translateY(
                  joint2.y,
                  size,
                  imageSize,
                  rotation,
                  cameraLensDirection,
                )),
            paintType);
      }

      // paint arms
      paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, paint );
      paintLine( PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, paint );
      paintLine( PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, paint );
      paintLine( PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, paint );

      // paint body
      paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, paint );
      paintLine( PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, paint );
      paintLine( PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, paint );
      paintLine( PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, paint );

      //paint legs
      paintLine( PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, paint );
      paintLine( PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, paint );
      paintLine( PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, paint );
      paintLine( PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, paint );
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
