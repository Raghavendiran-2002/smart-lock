import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Uri _url = Uri.parse('http://192.168.29.99:5012/video_feed');
  bool toggleStatus = false;
  bool internetConnectivity = false;
  var dio = Dio();

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  void getHttp() async {
    try {
      var response = await Dio().get('http://192.168.128.235:3000/api');
      print(response.data["status"]); // access the json data
      print(response.data.toString()); // Prints the Data
      if (response.data["status"] == true) {
        // status = true;
      } else {}
    } catch (e) {
      print(e);
      setState(() {
        internetConnectivity = true;
        // status = false;
      });
    }
  }

  void sendResponse(status, deviceID) async {
    Response response = await dio.post('http://13.127.183.39:3000/test',
        data: {"deviceID": deviceID, "status": status});
    print(response.data['status']);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF666CDB),
        centerTitle: true,
        title: Text(
          "TORQ - RiG'22",
          style: TextStyle(
            fontFamily: "Poppins",
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.refresh,
            ),
          ),
        ],
        leading: IconButton(
          onPressed: () async {
            FirebaseAuth.instance.signOut();
            GoogleSignIn().signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, "/", (Route<dynamic> route) => false);
          },
          icon: Icon(
            Icons.logout,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                "assets/images/Door.png",
              ),
              SizedBox(
                height: 10,
              ),
              BlurryContainer(
                child: Column(
                  children: [
                    Text("h"),
                    SizedBox(
                      height: 40,
                    ),
                    FlutterSwitch(
                      width: 130.0,
                      height: 50.0,
                      valueFontSize: 25.0,
                      toggleSize: 45.0,
                      value: toggleStatus,
                      borderRadius: 40.0,
                      padding: 8.0,
                      activeText: "unlock",
                      inactiveText: "lock  ",
                      inactiveIcon: Icon(Icons.lock_outline),
                      activeIcon: Icon(Icons.lock_open),
                      showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          sendResponse(val, "01");
                          toggleStatus = val;
                        });
                      },
                    ),
                  ],
                ),
                blur: 5,
                width: 350,
                height: 200,
                elevation: 0,
                color: Color(0xFF666CDB),
                padding: const EdgeInsets.all(8),
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 70,
                width: 350,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                    gradient: const LinearGradient(
                        colors: [Colors.black, Colors.greenAccent]),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.grey,
                          blurRadius: 2.0,
                          offset: Offset(2.0, 2.0))
                    ]),
                child: ElevatedButton.icon(
                  label: Text('View Camera'),
                  icon: Icon(Icons.video_camera_back),
                  onPressed: _launchUrl,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
