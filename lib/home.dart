import "package:flutter/material.dart";

class HomePage extends StatelessWidget {
	const HomePage({super.key});

    simpleNavPush( BuildContext context, Widget widget ) {
        Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => widget
            )
        );
    }

	@override
	Widget build(BuildContext context) {
		return Center(
            child: ListView(
                shrinkWrap: true,
                children: [
                    ListTile(
                        title: TextButton(
                            onPressed: () => simpleNavPush( context, const TutorialPage() ),
                            child: const Text( "Tutorial" )
                        ),
                    ),
                    ListTile(
                        title: TextButton(
                            onPressed: () => simpleNavPush( context, const AboutPage() ),
                            child: const Text( "About" )
                        ),
                    ),
                    ListTile(
                        title: TextButton(
                            onPressed: () => simpleNavPush( context, const SupportPage() ),
                            child: const Text( "Support" )
                        ),
                    )
                ],
            )
        );
	}
}

class TutorialPage extends StatelessWidget {
    const TutorialPage({super.key});

    @override
    Widget build(BuildContext context) {
        return const Scaffold(
            body: Center(
                child: Text( "Tutorial" )
            )
        );
    }
}

class AboutPage extends StatelessWidget {
    const AboutPage({super.key});

    @override
    Widget build(BuildContext context) {
        return const Scaffold(
            body: Center(
                child: Text( "About" )
            )
        );
    }
}

class SupportPage extends StatelessWidget {
    const SupportPage({super.key});

    @override
    Widget build(BuildContext context) {
        return const Scaffold(
            body: Center(
                child: Text( "Support" )
            )
        );
    }
}