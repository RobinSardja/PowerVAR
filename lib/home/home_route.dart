import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {

  static const _imageWidth = 250.0;
  static const _minButtonWidth = 200.0;
  static const _minButtonHeight = 25.0;
  static const _buttonStyle = ButtonStyle(
    minimumSize: MaterialStatePropertyAll( Size( _minButtonWidth, _minButtonHeight ) ),
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text( "PowerVAR" ),
          Image.asset(
            "assets/home icon.png",
            width: _imageWidth,
          ),
          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {},
            child: const Text( "New Lift" ),
          ),
          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {},
            child: const Text( "Settings" ),
          ),
          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {},
            child: const Text( "Support" ),
          ),
          ElevatedButton(
            style: _buttonStyle,
            onPressed: () {},
            child: const Text( "Help and About" ),
          ),
        ],
      ),
    );
  } 
}