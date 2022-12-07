import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:smart_lock/workflow/home-flow/screens/homeScreenDynamic.dart';

import '../services/bluetoothImplementation.dart';

class AddNewDevice extends StatefulWidget {
  final deviceID;
  AddNewDevice({required this.deviceID});

  @override
  State<AddNewDevice> createState() => _AddNewDeviceState();
}

class _AddNewDeviceState extends State<AddNewDevice> {
  var dio = Dio();
  late var deviceName;
  late var wifi;
  late var passwd;
  late var deviceType;
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();

  void CreateNewDevice(deviceName, deviceType, wifi, passwd,
      RoundedLoadingButtonController controller) async {
    final json =
        '{"deviceID": "${widget.deviceID}","deviceState": false,"deviceName": "${deviceName}","deviceType": "${deviceType}"}';
    var k = jsonDecode(json);
    print(k['deviceID']);
    Response response = await dio
        .post('http://13.235.244.236:3000/lock/createLockStatus', data: k);
    print(response.statusCode);
    CustomBluetoothImplementation.instance.writeWiFiCreds(wifi, passwd);
    setState(() {
      controller.success();
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext context) => HomeDynamic()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 30, right: 30, top: 150),
        child: Container(
          height: 600,
          width: 350,
          decoration: BoxDecoration(
            color: Color(0xFFDBDBFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: TextField(
                    onChanged: (text) {
                      deviceName = text;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Device Name",
                        fillColor: Colors.white70),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: TextField(
                    onChanged: (text) {
                      deviceType = text;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Device Type",
                        fillColor: Colors.white70),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: TextField(
                    onChanged: (text) {
                      wifi = text;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Device Name",
                        fillColor: Colors.white70),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: TextField(
                    onChanged: (text) {
                      passwd = text;
                    },
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[800]),
                        hintText: "Device Name",
                        fillColor: Colors.white70),
                  ),
                ),
                RoundedLoadingButton(
                  // animateOnTap: false,
                  color: Color(0xFF6171DC),
                  successColor: Color(0xFFC3B3F0),
                  controller: _btnController,
                  duration: Duration(seconds: 2),
                  onPressed: () {
                    CreateNewDevice(
                        deviceName, deviceType, wifi, passwd, _btnController);
                  },
                  valueColor: Colors.black,
                  borderRadius: 10,
                  child: Text("Create New Device",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
