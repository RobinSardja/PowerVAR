import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {

  static const _fontSize = 24.0;
  static const _imageWidth = 300.0;
  static const _padding = EdgeInsets.all(8.0);
  static const _minButtonWidth = 200.0;
  static const _minButtonHeight = 50.0;
  static const _buttonStyle = ButtonStyle(
    minimumSize: MaterialStatePropertyAll( Size( _minButtonWidth, _minButtonHeight ) ),
  );
  static const _textStyle = TextStyle(
    fontSize: _fontSize,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: _padding,
            child: Text(
              "PowerVAR",
              style: _textStyle,
            ),
          ),
          Padding(
            padding: _padding,
            child: Image.asset(
              "assets/home icon.png",
              width: _imageWidth,
            ),
          ),
          Padding(
            padding: _padding,
            child: ElevatedButton(
              style: _buttonStyle,
              onPressed: () {},
              child: const Text(
                "New Lift",
                style: _textStyle,
              ),
            ),
          ),
          Padding(
            padding: _padding,
            child: ElevatedButton(
              style: _buttonStyle,
              onPressed: () {},
              child: const Text(
                "Settings",
                style: _textStyle,
              ),
            ),
          ),
          Padding(
            padding: _padding,
            child: ElevatedButton(
              style: _buttonStyle,
              onPressed: () {},
              child: const Text(
                "Support",
                style: _textStyle,
              ),
            ),
          ),
          Padding(
            padding: _padding,
            child: ElevatedButton(
              style: _buttonStyle,
              onPressed: () {},
              child: const Text(
                "Help and About",
                style: _textStyle,
              ),
            ),
          ),
        ],
      ),
    );
  } 
}