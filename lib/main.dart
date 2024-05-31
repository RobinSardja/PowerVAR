import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:camera/camera.dart";

import "powervar.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

    final cameras = await availableCameras();

	SystemChrome.setPreferredOrientations([
		DeviceOrientation.portraitUp,
		DeviceOrientation.portraitDown
	]);

	runApp(
        MaterialApp(
			debugShowCheckedModeBanner: false,
			theme: ThemeData.light().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.red,
					foregroundColor: Colors.white,
				),
				scaffoldBackgroundColor: Colors.white,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.red,
                ),
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
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.white
                ),
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.black,
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
            home: PowerVAR( cameras: cameras ),
        )
    );
}