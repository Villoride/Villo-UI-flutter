// TODO Implement this library.


import 'package:flutter/material.dart';

class RideDetailsPage extends StatelessWidget {
  const RideDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking  Details"),
      ),
      body: Center(
        child: Text(
          "Your Booking has started! 🚴‍♀️",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
