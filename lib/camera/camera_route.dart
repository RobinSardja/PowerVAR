import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:powervar/camera/pose_detection/detector_view.dart';

import 'pose_detection/pose_painter.dart';
import 'video_route.dart';

// CameraRoute holds the camera route
class CameraRoute extends StatefulWidget {
  const CameraRoute({
    super.key,
    required this.camDesc,
    required this.navBar,
  });

  // initialize properties of camera in use
  final CameraDescription camDesc; // TO DO: let user choose front or back cam
  final ResolutionPreset camRes = ResolutionPreset.max; // TO DO: let user choose quality
  final BottomNavigationBar navBar;

  @override
  State<CameraRoute> createState() => _CameraRouteState();
}

class _CameraRouteState extends State<CameraRoute> {

  // initialize camera controls
  late CameraController _camControl;
  late Future<void> _initializeCamControlFuture;

  // initialize flag variable to detect when user is recording
  bool _isRecording = false;

  // initialize pose detection variables
  final _poseDetector = PoseDetector( options: PoseDetectorOptions() );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back; // TO DO: use camera lens direction from camDesc
  
  // create and initialize camera controller
  @override
  void initState() {
    super.initState();
    _camControl = CameraController(
      widget.camDesc, // choose specific camera to use
      widget.camRes, // define resolution quality to use
    );

    _initializeCamControlFuture = _camControl.initialize().then( (_) {
      if( !mounted ) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      // handle permission restrictions
      if( e is CameraException ) {
        switch( e.code ) {
          case 'CameraAccessDenied':
            showAdaptiveDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog.adaptive(
                title: const Text("Camera Denied"),
                content: const Text("PowerVAR needs your camera to record your lifts"),
                actions: [
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text("Grant Access"),
                  ),
                  TextButton(
                    onPressed: () => exit(0),
                    child: const Text("Exit"),
                  ),
                ]
              )
            );
            break;
          case 'AudioAccessDenied':
            showAdaptiveDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog.adaptive(
                title: const Text("Microphone Denied"),
                content: const Text("PowerVAR needs your microphone to record your lifts"),
                actions: [
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text("Grant Access"),
                  ),
                  TextButton(
                    onPressed: () => exit(0),
                    child: const Text("Exit"),
                  ),
                ]
              )
            );
        }
      }
    });
  }

  // dispose of the controller
  @override
  void dispose() {
    _canProcess = false;
    _poseDetector.close();
    _camControl.dispose();
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

  // record video
  _recordVideo() async {
    if( _isRecording ) {
      final file = await _camControl.stopVideoRecording();
      setState( () => _isRecording = false );
      final route = MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => VideoRoute( filePath: file.path ),
      );
      if(context.mounted) {
        Navigator.push( context, route );
      }
    } else {
      await _camControl.prepareForVideoRecording();
      await _camControl.startVideoRecording();
      setState( () => _isRecording = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    // show loading screen while initializing camera
    return Scaffold(
      appBar: AppBar( title: const Text('PowerVAR') ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeCamControlFuture,
          builder: (context, snapshot) {
            if( snapshot.connectionState == ConnectionState.done ) {
              // if Future is complete, display cam preview w/ pose detection
              return DetectorView(
                title: "Upload from Gallery",
                customPaint: _customPaint,
                text: _text,
                onImage: _detectPoses,
                initialCameraLensDirection: _cameraLensDirection,
                onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
              );
            } else {
              // else display loading indicator
              return const Center( child: CircularProgressIndicator.adaptive() );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // record video when button is pressed
        child: Icon( _isRecording ? Icons.stop : Icons.circle ),
        onPressed: () => _recordVideo(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: widget.navBar,
    );
  }
}