import 'package:flutter/material.dart';
import 'pages/WelcomePage.dart';

void main() {
  runApp(const VilloApp());
}

class VilloApp extends StatelessWidget {
  const VilloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Villo Ride',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const VilloRidePage(), // first screen
    );
  }
}
