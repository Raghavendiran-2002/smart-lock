import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class HomeScreen extends StatefulWidget {
  final String userUID;
  final String phoneNumber;
  HomeScreen({required this.phoneNumber, required this.userUID});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FlutterSwitch(
          width: 125.0,
          height: 55.0,
          valueFontSize: 25.0,
          toggleSize: 45.0,
          value: status,
          borderRadius: 30.0,
          padding: 8.0,
          showOnOff: true,
          onToggle: (val) {
            setState(() {
              status = val;
            });
          },
        ),
      ),
    );
  }
}
