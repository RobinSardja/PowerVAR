import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'video_route.dart';

// CameraRoute holds the camera route
class CameraRoute extends StatefulWidget {
  const CameraRoute({
    super.key,
    required this.camDesc,
    required this.camRes,
    required this.navBar,
  });

  // initialize properties of camera in use
  final CameraDescription camDesc;
  final ResolutionPreset camRes;
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
                    onPressed: () => exit(0),
                    child: const Text("Exit"),
                  ),
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text("Grant Access"),
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
                    onPressed: () => exit(0),
                    child: const Text("Exit"),
                  ),
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text("Grant Access"),
                  )
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
    _camControl.dispose();
    super.dispose();
  }

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
    // show loading screen while initializing camera
    return Scaffold(
      appBar: AppBar( title: const Text('PowerVAR') ),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeCamControlFuture,
          builder: (context, snapshot) {
            if( snapshot.connectionState == ConnectionState.done ) {
              // if Future is complete, display cam preview
              return CameraPreview( _camControl );
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