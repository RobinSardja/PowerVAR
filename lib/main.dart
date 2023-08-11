import 'package:flutter/material.dart';


import 'package:powervar/camera/camera_route.dart';
import 'package:powervar/home/home_route.dart';
import 'package:powervar/settings/settings_route.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false, // disable debug banner
      theme: ThemeData.dark(),
      initialRoute: "Camera",
      routes: {
        "Camera": (context) => const CameraRoute(),
        "Home": (context) => const HomeRoute(),
        "Settings": (context) => const SettingsRoute(),
      }
    )
  );
}