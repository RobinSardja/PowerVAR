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

// class RouteTemplate extends StatefulWidget {
//   const RouteTemplate({
//     super.key,
//     required this.appBarTitle,
//     });

//   final Text appBarTitle;

//   @override
//   State<RouteTemplate> createState() => RouteTemplateState();
// }

// class RouteTemplateState extends State<RouteTemplate> {

//   // handles nav bar changing routes
//   int _selectedIndex = 0;
//   void _changeIndex(int index) {
//     if( index == _selectedIndex ) return;
//     setState( () {_selectedIndex = index;} );
//     switch( index ) {
//       case 0:
//         Navigator.pushReplacementNamed( context, "Home" );
//         break;
//       case 1:
//         Navigator.pushReplacementNamed( context, "Camera" );
//         break;
//       case 2:
//         Navigator.pushReplacementNamed( context, "Settings" );
//         break;
//     }
//   }

//   late BottomNavigationBar bottomNavigationBar = BottomNavigationBar(
//     items: const <BottomNavigationBarItem>[
//       BottomNavigationBarItem(
//         icon: Icon(Icons.home),
//         label: 'Home',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.photo_camera),
//         label: 'Camera',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.settings),
//         label: 'Settings',
//       )
//     ],
//     selectedFontSize: 0, // hide icon label
//     iconSize: 32, // enlargen icon size
//     currentIndex: _selectedIndex,
//     onTap: (index) => _changeIndex(index),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: GestureDetector(
//         onHorizontalDragUpdate: (details) {
//           const sensitivity = 10;
//           if( _selectedIndex > 0 && details.delta.dx > sensitivity ) { // swipe right
//             _changeIndex( _selectedIndex - 1);
//           }
//           if( _selectedIndex < 2 && details.delta.dx < -sensitivity ) { // swipe left
//           _changeIndex( _selectedIndex + 1);
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: widget.appBarTitle,
//             automaticallyImplyLeading: false,
//           ),
//           bottomNavigationBar: bottomNavigationBar,
//         ),
//       ),
//     );
//   } 
// }