import 'package:flutter/material.dart';
import 'package:my_villo_project/pages/registration_page.dart';
import 'package:my_villo_project/pages/login_page.dart';

class VilloRidePage extends StatefulWidget {
  const VilloRidePage({super.key});

  @override
  State<VilloRidePage> createState() => _VilloRidePageState();
}

class _VilloRidePageState extends State<VilloRidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;

  @override
  void initState() {
    super.initState();

    // Car "riding effect" animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _positionAnimation =
        Tween<double>(begin: -30, end: 30).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInOut,
        ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🌍 Villo Ride"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🚖 Animated Car inside a Card
            AnimatedBuilder(
              animation: _positionAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_positionAnimation.value, 0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 10,
                    shadowColor: Colors.blueAccent,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Icon(
                        Icons.directions_car, // 🚗 Car logo
                        size: 120,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // Welcome text
            Text(
              "Welcome globle to Villo Ride",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              "Book your ride with ease and enjoy smooth journeys 🚖",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Register button
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegistrationPage(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add),
              label: const Text("Register"),
            ),

            const SizedBox(height: 16),

            // Login button
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
