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

  bool _liftSaved = false;

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
  _saveToGallery(int item) async {
    if( item == 1 && _liftSaved == false ) {
      showAdaptiveDialog(
        context: context,
        builder: (context) => AlertDialog.adaptive(
          title: const Text("Ready to Delete"),
          content: const Text("You can still save this lift before you start another! Exiting the lift preview automatically deletes lifts."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, "Ok"),
              child: const Text("Ok"),
            )
          ]
        )
      );
    } else if( _liftSaved == false ) {
      await GallerySaver.saveVideo(
        widget.filePath,
        albumName: widget.albumName,
        );
      File(widget.filePath).deleteSync();
      if( context.mounted ) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text( 'Saved to Gallery!' ),
            action: SnackBarAction(
              label: "OK",
              onPressed: () {},
            ),
          ),
        );
      }
      _liftSaved = true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text( 'Lift already saved!' ),
          action: SnackBarAction(
              label: "OK",
              onPressed: () {},
          ),
        ),
      );
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