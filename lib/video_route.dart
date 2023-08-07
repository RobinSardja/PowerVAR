import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoRoute extends StatefulWidget {
  final String filePath;

  const VideoRoute( {Key? key, required this.filePath}) : super(key: key);

  @override
  _VideoRouteState createState() => _VideoRouteState();
}

class _VideoRouteState extends State<VideoRoute> {
  late VideoPlayerController _videoPlayerController;

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future _initVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.file( File(widget.filePath) );
    await _videoPlayerController.initialize();
    await _videoPlayerController.setLooping(true); // TO DO: let user choose to loop video preview
    await _videoPlayerController.play();
  }

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Lift'),
        actions: [
          IconButton(
            icon: const Icon( Icons.check ),
            // TO DO: save video to gallery
            onPressed: () => showAdaptiveDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog.adaptive(
                title: const Text("Saved!"),
                content: const Text("Lift saved to gallery"),
                actions: [
                  TextButton(
                    child: const Text("Ok"),
                    onPressed: () => Navigator.pop( context, "OK" ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: ( context, state ) {
          if( state.connectionState == ConnectionState.done ) {
            return VideoPlayer(_videoPlayerController);
          } else {
            return const Center( child: CircularProgressIndicator.adaptive() );
          }
        }
      ),
    );
  }
}