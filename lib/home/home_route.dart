import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text( "PowerVAR" ),
          Image.asset( "assets/home icon.png" ),
          ElevatedButton(
            onPressed: () {},
            child: const Text( "New Lift" ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text( "Settings" ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text( "Support" ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text( "Help and About" ),
          ),
        ],
      ),
    );
  } 
}