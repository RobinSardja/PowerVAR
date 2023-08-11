import 'package:flutter/material.dart';

class SettingsRoute extends StatefulWidget {
  const SettingsRoute({super.key});

  @override
  State<SettingsRoute> createState() => _SettingsRouteState();
}

class _SettingsRouteState extends State<SettingsRoute> {

  // handles nav bar changing routes
  int _selectedIndex = 2;
  void _changeIndex(int index) {
    if( index == _selectedIndex ) return;
    setState( () {_selectedIndex = index;} );
    switch( index ) {
      case 0:
        Navigator.pushNamed( context, "Home" );
        break;
      case 1:
        Navigator.pushNamed( context, "Camera" );
        break;
      case 2:
        Navigator.pushNamed( context, "Settings" );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onPanUpdate: (details) {
          if( details.delta.dx > 0 ) { // swipe right
            _changeIndex( _selectedIndex - 1);
          }
          if( details.delta.dx < 0 ) { // swipe left
          _changeIndex( _selectedIndex + 1);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text( "Settings" ),
            automaticallyImplyLeading: false,
          ),
          bottomNavigationBar: BottomNavigationBar(
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
            currentIndex: _selectedIndex,
            onTap: (index) => _changeIndex(index),
          ),
      ),
      ),
    );
  }
}