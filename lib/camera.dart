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

    @override
    void initState() {
        super.initState();

         _controller = CameraController(
            widget.cameras[1],
            ResolutionPreset.max
        );

        _initalizeControllerFuture = _controller.initialize();
    }

    @override
    void dispose() {
        _controller.dispose();

        super.dispose();
    }

	@override
	Widget build(BuildContext context) {
		return Scaffold(
            body: FutureBuilder<void>(
                future: _initalizeControllerFuture,
                builder: (context, snapshot) {
                    if( snapshot.connectionState == ConnectionState.done ) {
                        return CameraPreview(_controller);
                    } else {
                        return const Center( child: CircularProgressIndicator() );
                    }
                }
            ),
            floatingActionButton: FloatingActionButton(
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
                        print(e);
                    }
                },
                child: const Icon( Icons.camera_alt )
            ),
        );
	}
}