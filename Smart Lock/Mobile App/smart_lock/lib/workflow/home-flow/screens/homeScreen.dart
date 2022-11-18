import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  final String userUID;
  final String phoneNumber;
  HomeScreen({required this.phoneNumber, required this.userUID});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
    );
  }
}
