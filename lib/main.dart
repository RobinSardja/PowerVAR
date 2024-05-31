import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "powervar.dart";

void main() {
	WidgetsFlutterBinding.ensureInitialized();

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
            home: const PowerVAR(),
        )
    );
}