import "package:flutter/material.dart";

import "package:camera/camera.dart";

class SettingsPage extends StatefulWidget {
	const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

    bool enableTracking = true;
    ResolutionPreset resolutionPreset = ResolutionPreset.high;

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
                    ),
                    ListTile(
                        title: const Text( "Camera Quality" ),
                        trailing: DropdownMenu(
                            initialSelection: resolutionPreset,
                            onSelected: (value) {
                                setState( () => resolutionPreset = value! );
                            },
                            dropdownMenuEntries: const [
                                DropdownMenuEntry(
                                    value: ResolutionPreset.low,
                                    label: "Low",
                                ),
                                DropdownMenuEntry(
                                    value: ResolutionPreset.medium,
                                    label: "Medium",
                                ),
                                DropdownMenuEntry(
                                    value: ResolutionPreset.high,
                                    label: "High",
                                ),
                                DropdownMenuEntry(
                                    value: ResolutionPreset.veryHigh,
                                    label: "Very high",
                                ),
                                DropdownMenuEntry(
                                    value: ResolutionPreset.ultraHigh,
                                    label: "Ultra high",
                                ),
                                DropdownMenuEntry(
                                    value: ResolutionPreset.max,
                                    label: "Max",
                                )
                            ],
                      ),
                    )
                ]
            ),
        );
	}
}