import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  List nodeID = [];
  var IP = "http://13.235.244.236:3000";
  List<bool> nodeStatus = [false, false, false, false];
  // final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  final Uri _url = Uri.parse('http://172.20.10.4:5001/video_feed');
  var dio = Dio();
  final firestoreInstance = FirebaseFirestore.instance;
  var orientation, size, height, width;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  void getLockStatus() async {
    var response = await Dio().get('${IP}/lock/getAllNodeID');
    nodeID = response.data;
    for (Map map in nodeID) {
      if (map['nodeId'] == '0x01') {
        nodeStatus[0] = map['status'] == 'true' ? true : false;
      } else if (map['nodeId'] == '0x02') {
        nodeStatus[1] = map['status'] == 'true' ? true : false;
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/lock/updateLockStatus',
        data: {"nodeId": deviceID, "status": status});
  }

  void _lockRealTimeChanges() {
    firestoreInstance.collection("lockRealTime").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified) {
          setState(() {
            getLockStatus();
          });
        }
      });
    });
  }

  void _wrongIDNotify() {
    firestoreInstance.collection("wrongID").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified) {
          displaySnackBar("Invalid ID!  😓");
        }
      });
    });
  }

  void displaySnackBar(String message, {Color color = Colors.red}) {
    SnackBar snackBar = SnackBar(
      content: Text(
        message,
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: Duration(seconds: 4),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Color color = Colors.red;
  bool press = false;

  @override
  void initState() {
    super.initState();
    getLockStatus();
    _lockRealTimeChanges();
    _wrongIDNotify();
  }

  @override
  Widget build(BuildContext context) {
    orientation = MediaQuery.of(context).orientation;
    size = MediaQuery.of(context).size;
    height = size.height;
    width = size.width;
    return SafeArea(
      child: Scaffold(
        // backgroundColor: Color(0xFFD5E1F4),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Home",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFF7D3B68),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "   Logout",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
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
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: height / 20,
              ),
              Text(
                "Good Day, Raghav!😃",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: height / 200,
              ),
              Text(
                "Manage your Locks",
                style: TextStyle(
                  color: Colors.black,
                  // fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: height / 50,
              ),
              if (isLoading)
                Center(child: CircularProgressIndicator())
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: nodeID.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisExtent: height / 7,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.6,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      return nodeStatus[index]
                          ? InkWell(
                              onTap: () {
                                bool val = !nodeStatus[index];
                                sendResponse(val, nodeID[index]['nodeId']);
                                setState(() {
                                  nodeStatus[index] = val;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFFFC3B0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        nodeStatus[index]
                                            ? Image.asset(
                                                'assets/images/unlock.png',
                                                width: width / 10,
                                                height: height / 20,
                                                fit: BoxFit.fill)
                                            : Image.asset(
                                                'assets/images/lock.png',
                                                width: width / 10,
                                                height: height / 20,
                                                fit: BoxFit.fill),
                                        FlutterSwitch(
                                            height: 30,
                                            width: 60,
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white,
                                            activeToggleColor:
                                                Color(0xFFFD492C),
                                            inactiveToggleColor:
                                                Color(0xFF47CC6B),
                                            // toggleColor: Color(0xFF47CC6B),
                                            value: nodeStatus[index],
                                            onToggle: (val) {
                                              sendResponse(
                                                  val, nodeID[index]['nodeId']);
                                              setState(() {
                                                nodeStatus[index] = val;
                                              });
                                            }),
                                      ],
                                    ),
                                    Text(
                                      nodeID[index]['nodeId'],
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ), //BoxDecoration
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                bool val = !nodeStatus[index];
                                sendResponse(val, nodeID[index]['nodeId']);
                                setState(() {
                                  nodeStatus[index] = val;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFFC3B3F0),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        nodeStatus[index]
                                            ? Image.asset(
                                                'assets/images/unlock.png',
                                                width: width / 10,
                                                height: height / 20,
                                                fit: BoxFit.fill)
                                            : Image.asset(
                                                'assets/images/lock.png',
                                                width: width / 10,
                                                height: height / 20,
                                                fit: BoxFit.fill),
                                        FlutterSwitch(
                                            height: 30,
                                            width: 60,
                                            activeColor: Colors.white,
                                            inactiveColor: Colors.white,
                                            activeToggleColor:
                                                Color(0xFFFD492C),
                                            inactiveToggleColor:
                                                Color(0xFF47CC6B),
                                            // toggleColor: Color(0xFF47CC6B),
                                            value: nodeStatus[index],
                                            onToggle: (val) {
                                              sendResponse(
                                                  val, nodeID[index]['nodeId']);
                                              setState(() {
                                                nodeStatus[index] = val;
                                              });
                                            }),
                                      ],
                                    ),
                                    Text(
                                      nodeID[index]['nodeId'],
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ), //BoxDecoration
                              ),
                            );
                    },
                  ),
                ),

              // AnimatedContainer(
              //   curve: Curves.linear,
              //   duration: Duration(
              //     seconds: 5,
              //   ),
              //   child: Container(
              //     decoration: BoxDecoration(),
              //     height: 100,
              //     width: 100,
              //     // color: press ? Colors.blue : Colors.red,
              //     child: InkWell(
              //         onTap: () {
              //           setState(() {
              //             press = !press;
              //           });
              //         },
              //         child: Text("Hi")),
              //   ),
              // ),
              Center(
                child: Container(
                  height: height / 12,
                  width: width / 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: IconButton(
                      onPressed: () {
                        _launchUrl();
                      },
                      icon: Icon(
                        Icons.video_camera_back_rounded,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
