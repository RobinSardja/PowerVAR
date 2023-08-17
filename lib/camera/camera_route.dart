import 'dart:async';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'pose_detection/detector_view.dart';
import 'pose_detection/pose_painter.dart';

// CameraRoute holds the camera route
class CameraRoute extends StatefulWidget {
  const CameraRoute({super.key});

  @override
  State<CameraRoute> createState() => _CameraRouteState();
}

class _CameraRouteState extends State<CameraRoute> {

  // initialize pose detection variables
  final _poseDetector = PoseDetector( options: PoseDetectorOptions() );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back; // TO DO: use camera lens direction from camDesc

  // dispose of the controller
  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    super.dispose();
  }

  // detect poses
  Future<void> _detectPoses(InputImage inputImage) async {
    if( !_canProcess || _isBusy ) return;
    _isBusy = true;
    setState( () {
      _text = "Processing Lift";
    });
    final poses = await _poseDetector.processImage(inputImage);
    if( inputImage.metadata?.size != null && inputImage.metadata?.rotation != null ) {
      final painter = PosePainter(
        poses,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      _text = "Poses found: ${poses.length}"; // TO DO: draw poses over imported videos from gallery
      _customPaint = null;
    }

    _isBusy = false;
    if( mounted ) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DetectorView(
          title: "",
          customPaint: _customPaint,
          text: _text,
          onImage: _detectPoses,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
      ),
    );
  }
}