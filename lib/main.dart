import 'package:flutter/material.dart';
import 'package:my_villo_project/pages/login_page.dart';
import 'package:my_villo_project/pages/ride_booking_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(VilloApp(isLoggedIn: isLoggedIn));
}

class VilloApp extends StatelessWidget {
  final bool isLoggedIn;
  const VilloApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Villo Ride',
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const RideBookingPage() : const LoginPage(),
    );
  }
}
