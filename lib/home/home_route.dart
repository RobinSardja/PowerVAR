import 'package:flutter/material.dart';

class HomeRoute extends StatefulWidget {
  const HomeRoute({super.key});

  @override
  State<HomeRoute> createState() => _HomeRouteState();
}

class _HomeRouteState extends State<HomeRoute> {

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center( child: Text( "Home" ), ),
    );
  } 
}