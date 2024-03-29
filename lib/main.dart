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
      debugShowCheckedModeBanner: false, // disables debug banner
      theme: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark().copyWith( background: Colors.black, ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        snackBarTheme: const SnackBarThemeData(
          actionTextColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.red,
          showSelectedLabels: false,
          unselectedItemColor: Colors.white,
          showUnselectedLabels: false,
        ),
      ),
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

  // handles nav bar changing routes
  int _selectedIndex = 1;
  static const List<Widget> _routes = <Widget>[
    HomeRoute(),
    CameraRoute(),
    SettingsRoute(),
  ];
  static const List<Text> _appBarTitles = <Text>[
    Text( "PowerVAR" ),
    Text( "New Lift" ),
    Text( "Settings" ),
  ];
  void _changeIndex(int index) {
    if( index == _selectedIndex ) return;
    setState( () {_selectedIndex = index;} );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    return Scaffold(
      appBar: ( _selectedIndex == 0 ) ? null : AppBar(
        title: _appBarTitles[ _selectedIndex ],
        automaticallyImplyLeading: false, // removes back button
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
        currentIndex: _selectedIndex,
        onTap: (index) => _changeIndex(index),
      ),
    );
  } 
}