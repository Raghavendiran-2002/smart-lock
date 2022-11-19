import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({Key? key}) : super(key: key);

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  bool toggleStatus = false;
  var dio = Dio();

  void getHttp() async {
    try {
      var response = await Dio().get('http://192.168.128.235:3000/api');
      print(response.data["status"]); // access the json data
      print(response.data.toString()); // Prints the Data
      if (response.data["status"] == true) {
        // status = true;
      } else {
        setState(() {
          // status = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void sendResponse(status, deviceID) async {
    Response response = await dio.post('http://13.127.183.39:3000/test',
        data: {"deviceID": deviceID, "status": status});
    print(response.data['status']);
  }

  @override
  void initState() {
    // TODO: implement initState
    // getHttp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FlutterSwitch Demo"),
      ),
      body: Center(
        child: Container(
          child: FlutterSwitch(
            width: 125.0,
            height: 55.0,
            valueFontSize: 25.0,
            toggleSize: 45.0,
            value: toggleStatus,
            borderRadius: 30.0,
            padding: 8.0,
            showOnOff: true,
            onToggle: (val) {
              setState(() {
                sendResponse(val, "01");
                toggleStatus = val;
              });
            },
          ),
        ),
      ),
    );
  }
}
