import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:powervar/camera/pose_detection/detector_view.dart';

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

  // handles nav bar changing routes
  int _selectedIndex = 1;
  void _changeIndex(int index) {
    if( index == _selectedIndex ) return;
    setState( () {_selectedIndex = index;} );
    switch( index ) {
      case 0:
        Navigator.pushNamed( context, "Home" );
        break;
      case 1:
        Navigator.pushNamed( context, "Camera" );
        break;
      case 2:
        Navigator.pushNamed( context, "Settings" );
        break;
    }
  }

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    // show loading screen while initializing camera
    return SizedBox.expand(
      child: GestureDetector( // swiping to navigate between routes
        onHorizontalDragUpdate: (details) {
          const sensitivity = 10;
          if( details.delta.dx > sensitivity ) { // swipe right
            _changeIndex( _selectedIndex - 1);
          }
          if( details.delta.dx < -sensitivity ) { // swipe left
          _changeIndex( _selectedIndex + 1);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('PowerVAR'),
            automaticallyImplyLeading: false,
          ),
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
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_camera),
                label: 'Camera',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              )
            ],
            selectedFontSize: 0, // hide icon label
            iconSize: 32, // enlargen icon size
            currentIndex: _selectedIndex,
            onTap: (index) => _changeIndex(index),
          ),
        ),
      ),
    );
  }
}