import "dart:async";
import "dart:io";

import "package:flutter/material.dart";

import "package:camera/camera.dart";

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
    late CameraController _controller;
    late Future<void> _initalizeControllerFuture;

    bool frontOrBack = false;

    void initCamera() {
        _controller = CameraController(
        widget.cameras[ frontOrBack ? 0 : 1 ],
        ResolutionPreset.max
        );

        _initalizeControllerFuture = _controller.initialize();
    }

    @override
    void initState() {
        super.initState();

        initCamera();
    }

    @override
    Future<void> dispose() async {
        await _controller.dispose();

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
                                    return CameraPreview(_controller);
                                } else {
                                    return const Center( child: CircularProgressIndicator() );
                                }
                            }
                        ),
                    ),
                    Align(
                        alignment: Alignment.bottomLeft,
                        child: FloatingActionButton(
                            onPressed: () async {
                                try {

                                } catch (e) {
                                    // HANDLE ERROR
                                }
                            },
                            child: const Icon( Icons.photo )
                        )
                    ),
                    Align(
                        alignment: Alignment.bottomCenter,
                        child: FloatingActionButton(
                            onPressed: () async {
                                try {
                                    await _initalizeControllerFuture;
                        
                                    final image = await _controller.takePicture();
                        
                                    if( !context.mounted ) return;
                        
                                    await Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) => Image.file( File(image.path) )
                                        )
                                    );
                                } catch (e) {
                                    // HANDLE ERROR
                                }
                            },
                            child: const Icon( Icons.camera )
                        ),
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                            onPressed: () async {
                                try {
                                    setState(() { frontOrBack = !frontOrBack; });
                                    initCamera();
                                } catch (e) {
                                    // HANDLE ERROR
                                }
                            },
                            child: Icon( Platform.isIOS ? Icons.flip_camera_ios : Icons.flip_camera_android )
                        )
                    )
            ] 
            ),
        );
	}
}