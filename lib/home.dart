import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
	const HomePage({super.key});

    @override
    State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
	@override
	Widget build(BuildContext context) {
		return Center(
            child: ListView(
                shrinkWrap: true,
                children: [
                    ListTile(
                        title: TextButton(
                            onPressed: () {},
                            child: const Text( "Tutorial" )
                        ),
                    ),
                    ListTile(
                        title: TextButton(
                            onPressed: () {},
                            child: const Text( "About" )
                        ),
                    ),
                    ListTile(
                        title: TextButton(
                            onPressed: () {},
                            child: const Text( "Support" )
                        ),
                    )
                ],
            )
        );
	}
}