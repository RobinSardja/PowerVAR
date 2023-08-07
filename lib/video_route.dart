import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:gallery_saver/gallery_saver.dart';

class VideoRoute extends StatefulWidget {
  const VideoRoute({
    super.key,
    required this.filePath,
  });

  final String filePath;
  final String albumName = "PowerVAR";

  @override
  State<VideoRoute> createState() => _VideoRouteState();
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

  // save video to gallery
  _saveToGallery() async {
    await GallerySaver.saveVideo(
      widget.filePath,
      albumName: widget.albumName,
      );
    File(widget.filePath).deleteSync();
    if( context.mounted ) {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text("Saved!"),
          content: const Text("Lift saved to gallery!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "Ok"),
              child: const Text("Ok"),
            )
          ]
        )
      );
    }
  }

  @override
  Widget build( BuildContext context ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Lift'),
        actions: [
          IconButton(
            icon: const Icon( Icons.check ),
            onPressed: () => _saveToGallery(),
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