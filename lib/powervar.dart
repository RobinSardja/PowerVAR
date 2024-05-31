import "package:flutter/material.dart";

import "camera.dart";
import "home.dart";
import "settings.dart";

class PowerVAR extends StatefulWidget {
	const PowerVAR({super.key});

	@override
	State<PowerVAR> createState() => _PowerVARState();
}

class _PowerVARState extends State<PowerVAR> {

	// selected index for navigation bar
	int selectedIndex = 1;

	@override
	Widget build(BuildContext context) {

		// page controller for page view
		final pageController = PageController(
			initialPage: selectedIndex,
		);

		return Scaffold(
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
		);
	}
}