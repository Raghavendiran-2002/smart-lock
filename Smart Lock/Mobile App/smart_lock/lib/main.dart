import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_lock/workflow/bluetooth-flow/screens/homeScreenble.dart';
import 'package:smart_lock/workflow/home-flow/screens/homeScreen.dart';
import 'package:smart_lock/workflow/home-flow/screens/homeScreenDynamic.dart';
import 'package:smart_lock/workflow/login-flow/otp_screen.dart';
import 'package:smart_lock/workflow/login-flow/screens/LoginScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  String? _userUID;
  String? _phoneNumber;
  String getInitRoute() {
    if (FirebaseAuth.instance.currentUser == null) {
      return "/";
    } else {
      User user = FirebaseAuth.instance.currentUser!;
      _userUID = user.uid;
      _phoneNumber = user.phoneNumber;
      return "home";
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Foodly',
      initialRoute: "homeble",
      // initialRoute: "adddevice",
      routes: {
        "/": (context) => LoginScreen(),
        "home": (context) => HomeScreen(),
        "homedy": (context) => HomeDynamic(),
        "homeble": (context) => HomeScreenBluetooth(),
        // "adddevice": (context) => AddNewDevice(
        //       deviceID: "0x00",
        //     ),
        // "bluetooth": (context) => Bluetooth(),
        "login": (context) =>
            OTPScreen(verificationID: _userUID!, phoneNumber: _phoneNumber!),
      },
    );
  }
}
