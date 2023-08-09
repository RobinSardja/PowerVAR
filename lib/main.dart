import 'package:flutter/material.dart';

import 'camera/camera_route.dart';

// asynchronous main function to compensate for camera feed delays
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // initialize navigation bar for use
  BottomNavigationBar navBar = BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.photo_camera),
        label: 'Camera',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        label: 'Settings',
      )
    ],
    selectedFontSize: 0, // hide icon label
    iconSize: 32, // enlargen icon size
    currentIndex: 1, // TO DO: update navbar selection
  );

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // disable debug banner
      theme: ThemeData.dark(),
      home: CameraRoute(
        navBar: navBar,
      ),
    )
  );
}