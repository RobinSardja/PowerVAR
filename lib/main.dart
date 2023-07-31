import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// asynchronous main function to compensate for camera feed delays
Future<void> main() async {

  // initialize cameras for use
  WidgetsFlutterBinding.ensureInitialized();
  final camList = await availableCameras();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // disable debug banner
      theme: ThemeData.dark(),
      home: MainApp(
        camDesc: camList.first, // TO DO: let user choose camera
        camRes: ResolutionPreset.max, // TO DO: let user choose quality
      )
    )
  );
}

// MainApp holds the camera route
class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    required this.camDesc,
    required this.camRes,
  });

  // initialize properties of camera in use
  final CameraDescription camDesc;
  final ResolutionPreset camRes;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  // initialize camera controls
  late CameraController _camControl;
  late Future<void> _initializeCamControlFuture;
  // create and initialize camera controller
  @override
  void initState() {
    super.initState();
    _camControl = CameraController(
      widget.camDesc, // choose specific camera to use
      widget.camRes, // define resolution quality to use
    );

    _initializeCamControlFuture = _camControl.initialize();
  }

  // dispose of the controller
  @override
  void dispose() {
    _camControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text('PowerVAR') ),
      body: FutureBuilder<void>(
        future: _initializeCamControlFuture,
        builder: (context, snapshot) {
          if( snapshot.connectionState == ConnectionState.done) {
            // if Future is complete, display cam preview
            return CameraPreview (_camControl );
          } else {
            // else display loading indicator
            return const Center( child: CircularProgressIndicator() );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // take picture when button is pressed
        onPressed: () async {
          try {
            // ensure camera is initialized
            await _initializeCamControlFuture;
            // take picture and get image file
            final image = await _camControl.takePicture();

            if( !mounted ) return;

            // if picture taken, display on new screen
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: image.path,
                )
              )
            );
          } catch(e) {
            // error code
          }
        },
        child: const Icon(Icons.camera_alt),  
      ),
    );
  }
}

// display the image taken
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    appBar: AppBar(
      title: const Text('Your Lift')),
      // display image stored as file on device with 'Image.file' constructor
      body: Image.file(File(imagePath)),
    );
  }
}