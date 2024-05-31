import "package:flutter/material.dart";

class SettingsPage extends StatefulWidget {
	const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

    bool enableTracking = false;

	@override
	Widget build(BuildContext context) {

		return Center(
            child: ListView(
                shrinkWrap: true,
                children: [
                    ListTile(
                        title: const Text( "Enable tracking" ),
                        trailing: Switch(
                            value: enableTracking,
                            onChanged: (value) {
                                setState( () => enableTracking = value );
                            },
                        )
                    )
                ]
            ),
        );
	}
}