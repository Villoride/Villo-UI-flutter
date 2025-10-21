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
