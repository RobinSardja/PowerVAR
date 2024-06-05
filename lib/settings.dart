import "package:flutter/material.dart";

import "package:camera/camera.dart";

class SettingsPage extends StatefulWidget {
	const SettingsPage({
        super.key,
        required this.settings
    });

    final Map<String, dynamic> settings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

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
                            value: widget.settings["enableTracking"],
                            onChanged: (value) {
                                setState( () => widget.settings["enableTracking"] = value );
                            },
                        )
                    ),
                    ListTile(
                        title: const Text( "Camera quality" ),
                        trailing: DropdownMenu(
                            initialSelection: widget.settings["resolutionPreset"],
                            onSelected: (value) {
                                setState( () => widget.settings["resolutionPreset"] = value! );
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