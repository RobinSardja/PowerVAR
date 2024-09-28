import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "package:camera/camera.dart";
import "package:permission_handler/permission_handler.dart";
import "package:shared_preferences/shared_preferences.dart";

import "powervar.dart";

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    final cameras = await availableCameras();
    final settings = await SharedPreferences.getInstance();
    final perms = await [
        Permission.camera,
        Permission.microphone,
        Permission.mediaLibrary
    ].request();

	runApp(
        MaterialApp(
            title: "Pose detection for weightlifting.",
			debugShowCheckedModeBanner: false,
			theme: ThemeData.light().copyWith(
				appBarTheme: const AppBarTheme(
					centerTitle: true,
					backgroundColor: Colors.red,
					foregroundColor: Colors.white
				),
				scaffoldBackgroundColor: Colors.white,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white
                ),
                textButtonTheme: const TextButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.red ),
                        foregroundColor: WidgetStatePropertyAll( Colors.white )
                    )
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.red
                ),
                switchTheme: SwitchThemeData(
                    thumbColor: WidgetStateProperty.resolveWith( (state) => state.contains( WidgetState.selected ) ? Colors.white : Colors.black ),
                    trackColor: WidgetStateProperty.resolveWith( (state) => state.contains( WidgetState.selected ) ? Colors.red : Colors.white ),
                    trackOutlineColor: WidgetStateProperty.resolveWith( (state) => state.contains( WidgetState.selected ) ? Colors.red : Colors.black )
                ),
                snackBarTheme: const SnackBarThemeData(
                    backgroundColor: Colors.white,
                    actionTextColor: Colors.black,
                    closeIconColor: Colors.red,
                    contentTextStyle: TextStyle(
                        color: Colors.black
                    ),
                    showCloseIcon: true
                ),
                dropdownMenuTheme: const DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.white )
                    )
                ),
                bottomAppBarTheme: const BottomAppBarTheme(
                    color: Colors.red
                ),
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.red,
					indicatorColor: Colors.white,
					iconTheme: WidgetStateProperty.resolveWith( (state) => IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						)
					),
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
					foregroundColor: Colors.white
				),
				scaffoldBackgroundColor: Colors.black,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black
                ),
                textButtonTheme: const TextButtonThemeData(
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.white ),
                        foregroundColor: WidgetStatePropertyAll( Colors.black )
                    )
                ),
                progressIndicatorTheme: const ProgressIndicatorThemeData(
                    color: Colors.white
                ),
                switchTheme: SwitchThemeData(
                    thumbColor: WidgetStateProperty.resolveWith( (state) => state.contains( WidgetState.selected ) ? Colors.black : Colors.white ),
                    trackColor: WidgetStateProperty.resolveWith(( state) => state.contains( WidgetState.selected ) ? Colors.white : Colors.black ),
                    trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.white,
                    )
                ),
                snackBarTheme: const SnackBarThemeData(
                    backgroundColor: Colors.white,
                    actionTextColor: Colors.black,
                    closeIconColor: Colors.black,
                    contentTextStyle: TextStyle(
                        color: Colors.black
                    ),
                    showCloseIcon: true
                ),
                dropdownMenuTheme: const DropdownMenuThemeData(
                    menuStyle: MenuStyle(
                        backgroundColor: WidgetStatePropertyAll( Colors.black )
                    )
                ),
                bottomAppBarTheme: const BottomAppBarTheme(
                    color: Colors.black
                ),
				navigationBarTheme: NavigationBarThemeData(
					backgroundColor: Colors.black,
					indicatorColor: Colors.white,
					iconTheme: WidgetStateProperty.resolveWith( (state) => IconThemeData(
							color: state.contains( WidgetState.selected ) ? Colors.black : Colors.white
						)
                    ),
					labelTextStyle: const WidgetStatePropertyAll(
						TextStyle(
							color: Colors.white
						)
					)
				)
			),
            home: PowerVAR( cameras: cameras, perms: perms, settings: settings )
        )
    );
}