import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:my_villo_project/pages/login_page.dart';
import 'package:my_villo_project/pages/registration_page.dart';

class VilloRidePage extends StatefulWidget {
  const VilloRidePage({super.key});

  @override
  State<VilloRidePage> createState() => _VilloRidePageState();
}

class _VilloRidePageState extends State<VilloRidePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _wiggle;
  int _selectedIndex = 0;

  final List<String> vehicleAssets = [
    'assets/images/car.png',
    'assets/images/auto.png',
    'assets/images/bike.png',
  ];

  final List<String> vehicleNames = [
    'Car',
    'Auto',
    'Bike',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _wiggle = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onVehicleChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A3B8A),
      body: Stack(
        children: [
          /// ✅ New Premium Gradient Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1), // Top dark blue
                    Color(0xFF1976D2), // Mid blue
                    Color(0xFF42A5F5), // Sky blue bottom
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  Image.asset(
                    'assets/images/villo_app_icon.png',
                    height: 80,
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    "Welcome to Villo",
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "Choose your ride & start moving!",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                  const SizedBox(height: 18),

                  /// ✅ Frosted Glass Vehicle Preview with Animation
                  AnimatedBuilder(
                    animation: _wiggle,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(_wiggle.value, 0),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          width: double.infinity,
                          height: size.height * 0.30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                bottom: 34,
                                child: Container(
                                  width: 180,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.yellow.withOpacity(0.8),
                                        Colors.orange.withOpacity(0.3),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                              ),
                              Image.asset(
                                vehicleAssets[_selectedIndex],
                                height: size.height * 0.18,
                                fit: BoxFit.contain,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ✅ Compact Vehicle Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(vehicleAssets.length, (i) {
                      final selected = i == _selectedIndex;
                      return GestureDetector(
                        onTap: () => _onVehicleChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: selected
                                ? [
                              const BoxShadow(
                                color: Colors.black38,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              )
                            ]
                                : [],
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                vehicleAssets[i],
                                height: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                vehicleNames[i],
                                style: TextStyle(
                                  color: selected
                                      ? const Color(0xFF0A3B8A)
                                      : Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0A3B8A),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                        elevation: 8,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegistrationPage(),
                          ),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
