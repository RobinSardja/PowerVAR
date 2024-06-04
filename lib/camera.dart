import "dart:async";
import "dart:io";
import "dart:math";

import "package:flutter/material.dart";

import "package:camera/camera.dart";
import "package:video_player/video_player.dart";

class CameraPage extends StatefulWidget {
	const CameraPage({
        super.key,
        required this.cameras
    });

    final List<CameraDescription> cameras;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
    late CameraController _cameraController;
    late Future<void> _initalizeControllerFuture;
    VideoPlayerController? _videoController;
    Future<void>? _initializeVideoPlayerFuture;


    bool frontOrBack = false;
    bool isRecording = false;

    void initCamera() {
        _cameraController = CameraController(
        widget.cameras[ frontOrBack ? 0 : 1 ],
        ResolutionPreset.high
        );

        _initalizeControllerFuture = _cameraController.initialize();
    }

    @override
    void initState() {
        super.initState();

        initCamera();
    }

    @override
    void dispose() {
        _videoController?.dispose();
        _cameraController.dispose();

        super.dispose();
    }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
            body: Stack(
                children: [
                    Center(
                        child: FutureBuilder<void>(
                            future: _initalizeControllerFuture,
                            builder: (context, snapshot) {
                                if( snapshot.connectionState == ConnectionState.done ) {
                                    return CameraPreview(_cameraController);
                                } else {
                                    return const Center( child: CircularProgressIndicator.adaptive() );
                                }
                            }
                        ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    try {
                            
                                    } catch (e) {
                                        // HANDLE ERROR
                                    }
                                },
                                child: const Icon( Icons.photo )
                            ),
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    try {
                                        if( isRecording ) {
                                            setState( () => isRecording = false );
                            
                                            final recording = await _cameraController.stopVideoRecording();
                                            _videoController = VideoPlayerController.file( File(recording.path) );
                                            _initializeVideoPlayerFuture = _videoController!.initialize();

                                            await _videoController!.setLooping(true);
                                            await _videoController!.play();
                            
                                            if( !context.mounted ) return;
                            
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) => FutureBuilder(
                                                        future: _initializeVideoPlayerFuture,
                                                        builder: (context, snapshot) {
                                                            if( snapshot.connectionState == ConnectionState.done ) {

                                                                return LiftPreview(
                                                                   videoController: _videoController!,
                                                                   frontOrBack: frontOrBack,
                                                                );

                                                            } else {
                                                                return const Center( child: CircularProgressIndicator.adaptive() );
                                                            }
                                                        }
                                                    )
                                                )
                                            );
                            
                                        } else {
                                            setState( () => isRecording = true );
                            
                                            await _cameraController.prepareForVideoRecording();
                                            _cameraController.startVideoRecording();
                                        }
                                    } catch (e) {
                                        // HANDLE ERROR
                                    }
                                },
                                child: Icon( isRecording ? Icons.check : Icons.videocam )
                            ),
                        ),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FloatingActionButton(
                                onPressed: () async {
                                    if( isRecording ) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                                content: Text( "Flipping locked while recording" ),
                                                behavior: SnackBarBehavior.floating,
                                            )
                                        );
                                        return;
                                    }

                                    try {
                                        await _cameraController.dispose();
                                        setState(() { frontOrBack = !frontOrBack; });
                                        initCamera();
                                    } catch (e) {
                                        // HANDLE ERROR
                                    }
                                },
                                child: Icon( Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android )
                            ),
                        )
                    )
            ] 
            ),
        );
	}
}

class LiftPreview extends StatefulWidget {
    const LiftPreview({
        super.key,
        required this.videoController,
        required this.frontOrBack
    });

    final VideoPlayerController videoController;
    final bool frontOrBack;

    @override
    State<LiftPreview> createState() => _LiftPreviewState();
}

class _LiftPreviewState extends State<LiftPreview> with TickerProviderStateMixin {

    late AnimationController linearProgressController;

    @override
    void initState() {
        super.initState();

        linearProgressController = AnimationController(
            vsync: this,
            duration: widget.videoController.value.duration,
        )..addListener( () {
            setState(() {});
        });
        linearProgressController.repeat();
    }

    @override
    void dispose() {
        linearProgressController.dispose();
        widget.videoController.dispose();

        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: const Text( "Your lift" )
            ),
            body: Stack(
                children: [
                    Align(
                        alignment: Alignment.topCenter,
                        child: LinearProgressIndicator(
                            value: linearProgressController.value,
                            semanticsLabel: "Linear progress inidicator",
                        ),
                    ),
                    Center(
                        child: AspectRatio(
                            aspectRatio: 1 / widget.videoController.value.aspectRatio,
                            child: Transform(
                                alignment: Alignment.center,
                                    transform: Matrix4.identity()..rotateZ( ( widget.frontOrBack ? 90 : -90 ) * pi / 180 ),
                                child: VideoPlayer( widget.videoController )
                            ),
                        ),
                    ),
                ] 
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                    setState(() {
                        if( widget.videoController.value.isPlaying ) {
                            widget.videoController.pause();
                            linearProgressController.stop();
                        } else {
                            widget.videoController.play();
                            linearProgressController
                                ..forward( from: linearProgressController.value )
                                ..repeat();
                        }
                    });
                },
                child: Icon( widget.videoController.value.isPlaying ? Icons.pause : Icons.play_arrow ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: NavigationBar(
                onDestinationSelected: (value) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text( value == 0 ? "Lift saved!" : "Lift discarded" ),
                            behavior: SnackBarBehavior.floating,
                        )
                    );
                },
                destinations: const [
                    NavigationDestination(
                        icon: Icon( Icons.download ),
                        label: "Save lift"
                    ),
                    NavigationDestination(
                        icon: Icon( Icons.delete ),
                        label: "Discard"
                    )
                ],
            ),
        );
    }
}