import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:permission_handler/permission_handler.dart';

import 'video_route.dart';

class CameraView extends StatefulWidget {
  const CameraView(
      {Key? key,
      required this.customPaint,
      required this.onImage,
      this.onCameraFeedReady,
      this.onDetectorViewModeChanged,
      this.onCameraLensDirectionChanged,
      this.initialCameraLensDirection = CameraLensDirection.back})
      : super(key: key);

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  late CameraController _controller;
  int _cameraIndex = -1;
  bool _changingCameraLens = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();

   _initialize();
  }

  Future<void> _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _liveFeedBody());
  }

  Widget _liveFeedBody() {
    if (_cameras.isEmpty) return Container();
    if (_controller.value.isInitialized == false) return Container();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : CameraPreview(
                    _controller,
                    child: widget.customPaint,
                  ),
          ),
          _uploadFromGallery(),
          _recordButton(),
          _flipCamera(),
        ],
      ),
    );
  }

  Widget _uploadFromGallery() => Positioned(
    bottom: 16,
    left: 16,
    child: FloatingActionButton(
      heroTag: Object(),
      onPressed: () => widget.onDetectorViewModeChanged,
      child: const Icon(
        Icons.photo_library_outlined,
      ),
    ),
  );

  Widget _recordButton() => Positioned(
    bottom: 16,
    left: 128, // TO DO: use proper centering
    right: 128,
    child: FloatingActionButton(
      heroTag: Object(),
      onPressed: () => _recordVideo(),
      child: Icon(
        _isRecording ? Icons.square : Icons.circle,
      )
    ),
  );

  Widget _flipCamera() => Positioned(
    bottom: 16,
    right: 16,
    child: FloatingActionButton(
      heroTag: Object(),
      onPressed: _switchLiveCamera,
      child: Icon(
        Platform.isAndroid
            ? Icons.flip_camera_android_outlined
            : Icons.flip_camera_ios_outlined,
      ),
    ),
  );

  // handle permission restrictions
  _handlePerms(Object e) {
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
                  onPressed: () => { openAppSettings() },
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
                  onPressed: () => { openAppSettings() },
                  child: const Text("Grant Access"),
                )
              ]
            )
          );
          break;
      }
    }
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high, // max does not work on some phones
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller.initialize().then((_) async {
      if (!mounted) return;
       setState(() {});

      await _controller.prepareForVideoRecording();
      _controller.startImageStream(_processCameraImage).then((value) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
        if (widget.onCameraLensDirectionChanged != null) {
          widget.onCameraLensDirectionChanged!(camera.lensDirection);
        }
      });
    }).catchError((Object e) {
      _handlePerms(e);
    });
  }

  Future _stopLiveFeed() async {
    try{
      await _controller.stopImageStream();
    } on CameraException {
      return;
    }
    await _controller.dispose();
    _controller.dispose();
  }

  _recordVideo() async {
    if( _isRecording ) {
      final file = await _controller.stopVideoRecording();
      setState( () => _isRecording = false );
      final route = MaterialPageRoute(
        builder: (_) => VideoRoute( filePath: file.path ),
      );
      if( context.mounted ) {
        Navigator.push( context, route );
      }
    } else {
      setState( () => _isRecording = true );
      await _controller.startVideoRecording(); // TO DO: causes multiple camera previews, need to end previous preview before starting new one
    }
  }

  Future _switchLiveCamera() async {
    if( _isRecording ) return;

    setState(() => _changingCameraLens = true);
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    await _startLiveFeed();
    setState(() => _changingCameraLens = false);
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}