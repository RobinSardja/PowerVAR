import "dart:async";
import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart";

import "package:camera/camera.dart";
import "package:gal/gal.dart";
import "package:image_picker/image_picker.dart";
import "package:path_provider/path_provider.dart";
import "package:share_plus/share_plus.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:video_player/video_player.dart";

import "pose_detection/pose_painter.dart";

class CameraPage extends StatefulWidget {
	const CameraPage({
        super.key,
        required this.cameras,
        required this.settings
    });

    final List<CameraDescription> cameras;
    final SharedPreferences settings;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
    late bool frontOrBack;
    late int resolutionPreset;
    late CameraController cameraController;
    late Future<void> initalizeControllerFuture;

    final imagePicker = ImagePicker();

    bool isFlipping = false;
    bool isRecording = false;
    bool isBusy = false;

    late bool enableTracking;
    late PoseDetectionModel poseModel;
    PoseDetector? poseDetector;
    CustomPaint? customPaint;
    List<CustomPaint?> paintList = [];
    double opacity = 1;

    final orientations = {
        DeviceOrientation.portraitUp: 0,
        DeviceOrientation.landscapeLeft: 90,
        DeviceOrientation.portraitDown: 180,
        DeviceOrientation.landscapeRight: 270
    };

    void simpleSnackBar( String content ) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text( content ),
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true
            )
        );
    }

    InputImage? inputImageFromCameraImage( CameraImage image ) {
        final camera = cameraController.description;
        final sensorOrientation = camera.sensorOrientation;

        InputImageRotation? rotation;
        if( Platform.isIOS ) {
            rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
        } else {
            var rotationCompensation = orientations[ cameraController.value.deviceOrientation ];
            if( rotationCompensation == null ) return null;
            if( camera.lensDirection == CameraLensDirection.front ) {
                rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
            } else {
                rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
            }
            rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
        }
        if( rotation == null ) return null;

        final format = InputImageFormatValue.fromRawValue(image.format.raw);

        if( format == null || (Platform.isAndroid && format != InputImageFormat.nv21) || (Platform.isIOS && format != InputImageFormat.bgra8888) ) return null;
        if( image.planes.length != 1 ) return null;

        final plane = image.planes.first;

        return InputImage.fromBytes(
            bytes: plane.bytes,
            metadata: InputImageMetadata(
                size: Size( image.width.toDouble(), image.height.toDouble() ),
                rotation: rotation,
                format: format,
                bytesPerRow: plane.bytesPerRow
            )
        );
    }

    Future<void> processImage( InputImage inputImage ) async {
        if( isBusy ) return;

        setState( () => isBusy = true );

        final poses = await poseDetector!.processImage(inputImage);

        if( inputImage.metadata?.size != null && inputImage.metadata?.rotation != null ) {
            final painter = PosePainter(
                poses,
                inputImage.metadata!.size,
                inputImage.metadata!.rotation,
                frontOrBack ? CameraLensDirection.front : CameraLensDirection.back,
                opacity
            );
            customPaint = CustomPaint( painter: painter );
        } else {
            customPaint = null;
        }

        if( isRecording ) {
            paintList.add(customPaint);
        }

        if( mounted ) {
            setState( () => isBusy = false );
        }
    }

    void processCameraImage( CameraImage image ) {
        final inputImage = inputImageFromCameraImage(image);
        if( inputImage == null ) return;
        processImage(inputImage);
    }

    void initCamera() {
        cameraController = CameraController(
            widget.cameras[ frontOrBack ? 0 : 1 ],
            ResolutionPreset.values[ resolutionPreset ],
            imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.nv21
        );

        initalizeControllerFuture = cameraController.initialize().then((_) {
            if( enableTracking ) cameraController.startImageStream(processCameraImage);
        });
    }

    void initLiftPreview( XFile source, bool fromGal ) async {
        if( !mounted ) return;

        await Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => LiftPreview(
                    fromGal: fromGal,
                    paintList: paintList,
                    settings: widget.settings,
                    source: source,
                )
            )
        );
    }

    void initPoseDetector() {
        poseDetector = PoseDetector(
            options: PoseDetectorOptions(
                model: poseModel,
            )
        );
    }

    @override
    void initState() {
        super.initState();

        enableTracking = widget.settings.getBool( "enableTracking" ) ?? true;
        frontOrBack = widget.settings.getBool( "frontOrBack" ) ?? true;
        poseModel = (widget.settings.getBool( "hyperAccuracy" ) ?? false) ? PoseDetectionModel.accurate : PoseDetectionModel.base;
        resolutionPreset = widget.settings.getInt( "resolutionPreset" ) ?? 1;

        if( enableTracking ) initPoseDetector();
        initCamera();
    }

    @override
    void dispose() {
        cameraController.dispose();
        if( enableTracking ) poseDetector?.close();

        super.dispose();
    }

	@override
	Widget build(BuildContext context) {

		return Scaffold(
            body: Stack(
                children: [
                    Center(
                        child: FutureBuilder<void>(
                            future: initalizeControllerFuture,
                            builder: (context, snapshot) {
                                return snapshot.connectionState == ConnectionState.done ?
                                CameraPreview(
                                    cameraController,
                                    child: customPaint
                                ) :
                                const Center( child: CircularProgressIndicator.adaptive() );
                            }
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton( // Gallery button
                                onPressed: () async {
                                    if( isRecording ) {
                                        simpleSnackBar( "Gallery locked while recording" );
                                    } else {
                                        paintList.clear();
                                        try {
                                            final galleryVideo = await imagePicker.pickVideo( source: ImageSource.gallery );

                                            if( galleryVideo != null ) initLiftPreview( galleryVideo, true );
                                        } catch (e) {
                                            // HANDLE ERROR
                                        }
                                    }
                                },
                                child: const Icon( Icons.photo )
                            )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton( // Record button
                                onPressed: () async {
                                    try {
                                        if( isRecording ) {
                                            setState( () => isRecording = false );
                                            initLiftPreview( await cameraController.stopVideoRecording(), false );
                                            if( enableTracking ) cameraController.startImageStream(processCameraImage);
                                        } else {
                                            setState( () => isRecording = true );
                                            if( enableTracking ) {
                                                paintList.clear();
                                                cameraController.stopImageStream();
                                            } 
                                            await cameraController.prepareForVideoRecording();
                                            await cameraController.startVideoRecording( onAvailable: enableTracking ? processCameraImage : null );
                                        }
                                    } catch (e) {
                                        // HANDLE ERROR
                                    }
                                },
                                child: Icon( isRecording ? Icons.check : Icons.videocam )
                            )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton( // Flip camera button
                                onPressed: () async {
                                    if( isFlipping ) return;

                                    setState( () => isFlipping = true );

                                    if( isRecording ) {
                                        simpleSnackBar( "Flipping locked while recording" );
                                    } else {
                                        try {
                                            if( enableTracking ) {
                                                setState( () => opacity = 0 );
                                                await cameraController.stopImageStream();
                                            }

                                            setState( () {
                                                frontOrBack = !frontOrBack;
                                                widget.settings.setBool( "frontOrBack", frontOrBack );
                                            });

                                            await cameraController.setDescription( widget.cameras[ frontOrBack ? 0 : 1 ] ).then((_) {
                                                if( enableTracking ) {
                                                    cameraController.startImageStream(processCameraImage);
                                                    setState( () => opacity = 1 );
                                                }
                                            });
                                        } catch (e) {
                                            // HANDLE ERROR
                                        }
                                    }

                                    setState( () => isFlipping = false );
                                },
                                child: Icon( Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android )
                            )
                        )
                    )
                ] 
            )
        );
	}
}

class LiftPreview extends StatefulWidget {
    const LiftPreview({
        super.key,
        required this.fromGal,
        required this.paintList,
        required this.settings,
        required this.source
    });

    final bool fromGal;
    final List<CustomPaint?> paintList;
    final SharedPreferences settings; 
    final XFile source;

    @override
    State<LiftPreview> createState() => _LiftPreviewState();
}

class _LiftPreviewState extends State<LiftPreview> with TickerProviderStateMixin {

    late VideoPlayerController videoController;
    late Future<void> initializeVideoPlayerFuture;
    late AnimationController linearProgressController;

    late bool enableTracking;
    late bool frontOrBack;

    bool renamedFiles = false;
    bool saved = false;

    late Directory tempDir;
    late File newFile;
    late XFile finalFile;

    void simpleSnackBar( String content ) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text( content ),
                behavior: SnackBarBehavior.floating,
                showCloseIcon: true
            )
        );
    }

    @override
    void initState() {
        super.initState();

        videoController = VideoPlayerController.file( File(widget.source.path) );
        initializeVideoPlayerFuture = videoController.initialize().then((_) {
            linearProgressController = AnimationController( // TODO: fix slight offset in progress line and video duration
                vsync: this,
                duration: videoController.value.duration
            )..addListener(() {
                setState( () {} );
            })
            ..repeat();
        });
        videoController..setLooping(true)..play();

        enableTracking = widget.settings.getBool( "enableTracking" ) ?? true;
        frontOrBack = widget.settings.getBool( "frontOrBack" ) ?? true;
    }

    @override
    void dispose() {
        linearProgressController.dispose();
        videoController.dispose();

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text( "Your lift" )
            ),
            body: FutureBuilder(
                future: initializeVideoPlayerFuture,
                builder: ( context, snapshot ) {
                    if( snapshot.connectionState == ConnectionState.done ) {
                        return Stack(
                            children: [
                                Center(
                                    child: AspectRatio(
                                        aspectRatio: videoController.value.aspectRatio,
                                        child: VideoPlayer( videoController )
                                    )
                                ),
                                Center(
                                    child: ValueListenableBuilder(
                                        valueListenable: linearProgressController,
                                        builder: ( context, value, child ) {
                                            return Transform.flip(
                                                flipX: !frontOrBack, // TODO: frontOrBack incompatible with gallery videos
                                                child: AspectRatio(
                                                    aspectRatio: videoController.value.aspectRatio,
                                                    child: widget.paintList.isNotEmpty && enableTracking ? widget.paintList[ (value * widget.paintList.length).floor() ] : null // TODO: fix delay
                                                )
                                            );
                                        }
                                    )
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: LinearProgressIndicator(
                                        value: linearProgressController.value
                                    )
                                ),
                                Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: FloatingActionButton( // Tracking button
                                            onPressed: () {
                                                setState( () => enableTracking = !enableTracking );
                                            },
                                            child: Icon( enableTracking ? Icons.visibility : Icons.visibility_off )
                                        )
                                    )
                                ),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: FloatingActionButton( // Play button
                                            onPressed: () {
                                                if( videoController.value.isPlaying ) {
                                                    linearProgressController.stop();
                                                    videoController.pause();
                                                } else {
                                                    linearProgressController
                                                        ..forward()
                                                        ..repeat();
                                                    videoController.play();
                                                }
                                                setState( () {} );
                                            },
                                            child: Icon( videoController.value.isPlaying ? Icons.pause : Icons.play_arrow )
                                        )
                                    )
                                ),
                                Align(
                                    alignment: Alignment.bottomRight,
                                    child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: FloatingActionButton( // Mute button
                                            onPressed: () {
                                                videoController.setVolume( 1 - videoController.value.volume );
                                            },
                                            child: Icon( videoController.value.volume == 0 ? Icons.volume_off : Icons.volume_up )
                                        )
                                    )
                                )
                            ]
                        );
                    } else {
                        return const Center( child: CircularProgressIndicator.adaptive() );
                    }
                }
            ),
            bottomNavigationBar: NavigationBar(
                onDestinationSelected: (value) async {
                    if( !renamedFiles ) {
                        tempDir = await getTemporaryDirectory();
                        newFile = File(widget.source.path).renameSync("${tempDir.path}/${DateTime.now()}.mp4");
                        finalFile = XFile(newFile.path);
                        setState( () => renamedFiles = true );
                    }

                    switch(value) {
                        case 0:
                            if( saved || widget.fromGal ) {
                                simpleSnackBar( "Lift already saved!" );
                            } else {
                                await Gal.putVideo( newFile.path, album: "PowerVAR" );

                                simpleSnackBar( "Lift saved!" );
                                setState( () => saved = true );
                            }
                            break;
                        case 1:
                            final result = await Share.shareXFiles( [finalFile] );

                            if( result.status == ShareResultStatus.success ) {
                                simpleSnackBar( "Lift shared!" );
                            }
                            break;
                        case 2:
                            if( !saved ) {
                                simpleSnackBar( "Lift discarded" );
                            }

                            if( !context.mounted ) return;
                            Navigator.pop(context);
                    }
                },
                destinations: [
                    const NavigationDestination(
                        icon: Icon( Icons.download ),
                        label: "Save lift"
                    ),
                    const NavigationDestination(
                        icon: Icon( Icons.share ),
                        label: "Share lift"
                    ),
                    NavigationDestination(
                        icon: Icon( saved || widget.fromGal ? Icons.keyboard_return : Icons.delete ),
                        label: saved || widget.fromGal ? "Exit" : "Discard"
                    )
                ]
            )
        );   
    }
}