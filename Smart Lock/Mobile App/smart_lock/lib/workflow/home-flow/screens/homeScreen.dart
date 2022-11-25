import 'package:cloud_firestore/cloud_firestore.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  late final AnimationController _controller;
  List nodeID = [];
  var IP = "http://13.235.99.169:3000";
  List<bool> nodeStatus = [false, false, false, false];
  // final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  final Uri _url = Uri.parse('http://192.168.1.8:8000/index.html');
  var dio = Dio();
  final firestoreInstance = FirebaseFirestore.instance;

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

  @override
  void initState() {
    super.initState();
    getLockStatus();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    _lockRealTimeChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF666CDB),
        centerTitle: true,
        title: Text(
          "Smart Lock",
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
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceAround,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 20,
            ),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: GridView.builder(
                      itemCount: nodeID.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color(0xFF666CDB),
                                width: 2,
                              ),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                nodeStatus[index]
                                    ? Image.asset('assets/images/lock.png',
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.fill)
                                    : Image.asset('assets/images/unlock.png',
                                        width: 150,
                                        height: 120,
                                        fit: BoxFit.fill),
                                Text(nodeID[index]['nodeId']),
                                SizedBox(
                                  height: 10,
                                ),
                                FlutterSwitch(
                                    value: nodeStatus[index],
                                    onToggle: (val) {
                                      sendResponse(
                                          val, nodeID[index]['nodeId']);
                                      setState(() {
                                        nodeStatus[index] = val;
                                      });
                                    }),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ) //BoxDecoration
                            );
                      },
                    ),
                  ),
            FloatingActionButton(
              onPressed: () {
                _launchUrl();
              },
              child: Icon(Icons.video_camera_back_rounded),
              // child: Lottie.network(
              //   "https://assets8.lottiefiles.com/packages/lf20_cemuvgf7.json",
              //   controller: _controller,
              //   onLoaded: (composition) {
              //     _controller
              //       ..duration = composition.duration
              //       ..forward();
              //   },
            ),
          ],
        ),
      ),
    );
  }
}
