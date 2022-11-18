import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_lock/workflow/home-flow/screens/homeScreen.dart';
import 'package:smart_lock/workflow/lock-flow/screens/lockScreen.dart';
import 'package:smart_lock/workflow/login-flow/login-screen.dart';

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
      title: 'Foodly',
      initialRoute: "lock",
      routes: {
        "/": (context) => LoginScreen(),
        "home": (context) => HomeScreen(
              userUID: _userUID!,
              phoneNumber: _phoneNumber!,
            ),
        "lock": (context) => LockScreen(),
      },
    );
  }
}
