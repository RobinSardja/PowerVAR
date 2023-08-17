import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  _saveToGallery(int selected) async {
    switch( selected ) {
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text( 'Lift deleted' ),
            action: SnackBarAction(
              label: "OK",
              onPressed: () {},
            ),
          ),
        );
        Navigator.pop(context);
        break;
      case 0:
        await GallerySaver.saveVideo(
          widget.filePath,
          albumName: widget.albumName,
          );
        File(widget.filePath).deleteSync();
        if( context.mounted ) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text( 'Saved to gallery!' ),
              action: SnackBarAction(
                label: "OK",
                onPressed: () {},
              ),
            ),
          );
        }
        if(context.mounted) Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build( BuildContext context ) {
    // enforce portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lift Preview'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder(
        future: _initVideoPlayer(),
        builder: ( context, state ) {
          if( state.connectionState == ConnectionState.done ) {
            return VideoPlayer(_videoPlayerController);
          } else {
            return const Center( child: Text( "Loading Lift" ), );
          }
        }
      ),
      extendBody: false,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon( Icons.save_alt_outlined ),
            label: "Save"
          ),
          BottomNavigationBarItem(
            icon: Icon( Icons.delete_outlined ),
            label: "Delete",
          )
        ],
        selectedFontSize: 0,
        iconSize: 32,
        currentIndex: 0,
        onTap: (value) => _saveToGallery(value),
      ),
    );
  }
}