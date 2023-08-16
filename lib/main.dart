import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:powervar/camera/camera_route.dart';
import 'package:powervar/home/home_route.dart';
import 'package:powervar/settings/settings_route.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();

  runApp( const PowerVAR() );

}

class PowerVAR extends StatelessWidget {
  const PowerVAR({super.key});

  @override
  Widget build( context ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // disable debug banner
      theme: ThemeData.dark(),
      home: const MainRoute(),
    );
  }
}

class MainRoute extends StatefulWidget {
  const MainRoute({ super.key });

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {

  Text appBarTitle = const Text( "PowerVAR" );

  // handles nav bar changing routes
  int _selectedIndex = 1;
  static const List<Widget> _routes = <Widget>[
    HomeRoute(),
    CameraRoute(),
    SettingsRoute(),
  ];
  void _changeIndex(int index) {
    setState( () {_selectedIndex = index;} );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return SizedBox.expand(
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          const sensitivity = 10;
          if( _selectedIndex > 0 && details.delta.dx > sensitivity ) { // swipe right
            _changeIndex( _selectedIndex - 1 );
          }
          if( _selectedIndex < 2 && details.delta.dx < -sensitivity ) { // swipe left
          _changeIndex( _selectedIndex + 1 );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: appBarTitle,
            automaticallyImplyLeading: false,
          ),
          body: _routes[ _selectedIndex ],
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