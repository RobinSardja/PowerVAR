import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {

  // home route styling variables2
  static const _titleFontSize = 48.0;
  static const _buttonFontSize = 24.0;
  static const _imageWidth = 300.0;
  static const _padding = EdgeInsets.all(8.0);
  static const _minButtonWidth = 200.0;
  static const _minButtonHeight = 50.0;
  static const _homeBackground = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromARGB(255, 255, 0, 0),
        Color.fromARGB(255, 64, 0, 0),
      ],
    ),
  );
  final _buttonStyle = ButtonStyle(
    minimumSize: const MaterialStatePropertyAll( Size( _minButtonWidth, _minButtonHeight ) ),
    shape: MaterialStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      )
    ),
    backgroundColor: const MaterialStatePropertyAll( Colors.white ),
  );
  static const _textStyle = TextStyle(
    color: Colors.black,
    fontSize: _buttonFontSize,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _homeBackground,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: _padding,
              child: Text(
                "PowerVAR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
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
      ),
    );
  } 
}