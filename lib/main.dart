import "package:flutter/material.dart";
import 'package:flutter/services.dart';

import "camera.dart";
import "home.dart";
import "settings.dart";

void main() {
	WidgetsFlutterBinding.ensureInitialized();

	SystemChrome.setPreferredOrientations([
		DeviceOrientation.portraitUp,
		DeviceOrientation.portraitDown
	]);

	runApp(const MainApp());
}

class MainApp extends StatefulWidget {
	const MainApp({super.key});

	@override
	State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

	// selected index for navigation bar
	int selectedIndex = 1;

	@override
	Widget build(BuildContext context) {

		// page controller for page view
		final pageController = PageController(
			initialPage: selectedIndex,
		);

		return MaterialApp(
			debugShowCheckedModeBanner: false,
			theme: ThemeData.light().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.red,
					foregroundColor: Colors.white,
				),
				scaffoldBackgroundColor: Colors.white,
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.red,
					indicatorColor: Colors.white,
					iconTheme: WidgetStateProperty.resolveWith((state) {
						return IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						);
					}),
					labelTextStyle: const WidgetStatePropertyAll(
						TextStyle(
							color: Colors.white
						)
					)
				)
			),
			darkTheme: ThemeData.dark().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.black,
					foregroundColor: Colors.white,
				),
				scaffoldBackgroundColor: Colors.black,
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.black,
					indicatorColor: Colors.red,
					iconTheme: WidgetStateProperty.resolveWith((state) {
						return IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						);
					}),
					labelTextStyle: const WidgetStatePropertyAll(
						TextStyle(
							color: Colors.white
						)
					)
				)
			),
			home: Scaffold(
				appBar: AppBar(
					title: const Text( "PowerVAR" ),
				),
				body: PageView(
					controller: pageController,
					onPageChanged: (selectedPage) {
						setState(() {selectedIndex = selectedPage;});
					},
					children: const [
						HomePage(),
						CameraPage(),
						SettingsPage()
					]
				),
				bottomNavigationBar: NavigationBar(
					onDestinationSelected: ( selectedDestination ) {
						setState(() {
							selectedIndex = selectedDestination;
							pageController.jumpToPage(selectedDestination);
						});
					},
					selectedIndex: selectedIndex,
					destinations: const [
						NavigationDestination(
							icon: Icon( Icons.home ),
							label: "Home",
						),
						NavigationDestination(
							icon: Icon( Icons.camera ),
							label: "Camera",
						),
						NavigationDestination(
							icon: Icon( Icons.settings ),
							label: "Settings",
						),
					],
				),
			),
		);
	}
}