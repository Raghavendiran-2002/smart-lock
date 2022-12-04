import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeDynamic extends StatefulWidget {
  const HomeDynamic({Key? key}) : super(key: key);

  @override
  State<HomeDynamic> createState() => _HomeDynamicState();
}

class _HomeDynamicState extends State<HomeDynamic> {
  var userState = ["I'm Home", "I'm Leaving"];
  bool isLoading = true;
  List nodeID = [];
  // var IP = "http://13.235.244.236:3000";
  var IP = "http://192.168.1.4:3000";
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
    print(nodeID);
    for (Map map in nodeID) {
      if (map['deviceID'] == '1') {
        nodeStatus[0] = map['state'];
        print(nodeStatus[0]);
      } else if (map['deviceID'] == '2') {
        nodeStatus[1] = map['state'];
        print(nodeStatus[1]);
      } else if (map['deviceID'] == '3') {
        nodeStatus[2] = map['state'];
        print(nodeStatus[2]);
      }
    }
    print(nodeStatus);
    setState(() {
      isLoading = false;
    });
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
    return Scaffold(
      // backgroundColor: Color(0xFFD5E1F4),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 15),
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
                    fontSize: 35,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFDBDBFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      GoogleSignIn().signOut();
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/", (Route<dynamic> route) => false);
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFF6171DC),
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height / 40,
            ),
            Text(
              "Good Day, Raghav!😃",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            SizedBox(
              height: height / 200,
            ),
            Text(
              "Manage your Home",
              style: TextStyle(
                color: Colors.black,
                // fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            SizedBox(
              height: height / 30,
            ),
            // Flexible(
            //   child: GridView.builder(
            //     itemCount: 2,
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       mainAxisSpacing: 15.0,
            //       crossAxisSpacing: 15.0,
            //       childAspectRatio: 2,
            //       crossAxisCount: 2,
            //     ),
            //     itemBuilder: (BuildContext context, int index) {
            //       // return CustomLockSwitch(nodeData[index], context, index);
            //       return Container(
            //         decoration: BoxDecoration(
            //           color: Color(0xFFDBDBFC),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: Padding(
            //           padding:
            //               EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //           child: Text(
            //             userState[index],
            //             style: TextStyle(
            //               color: Colors.white,
            //               fontWeight: FontWeight.bold,
            //               fontSize: 20,
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${nodeID.length} Devices",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Container(
                  height: height / 20,
                  width: width / 10,
                  decoration: BoxDecoration(
                    color: Color(0xFFDBDBFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      showMaterialModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        builder: (context) => Container(
                          height: 210,
                          decoration: BoxDecoration(
                            color: Color(0xFFC3B3F0),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Text("Device Name : "),
                              Expanded(
                                child: TextField(
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Password',
                                  ),
                                ),
                              )
                              // TextField(),
                            ],
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.add,
                      color: Color(0xFF6171DC),
                      // color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: height / 50,
            ),
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              CustomDeviceWidget(nodeID, nodeStatus, Color(0xFF6171DC)),
            SizedBox(
              height: height / 35,
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFDBDBFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: () async {
                    _launchUrl();
                  },
                  icon: Icon(
                    CupertinoIcons.video_camera,
                    color: Color(0xFF6171DC),
                    // color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDeviceWidget extends StatefulWidget {
  final List nodeID;
  List<bool> nodeStatus = [false, false, false, false];
  final Color WidgetColors;
  CustomDeviceWidget(this.nodeID, this.nodeStatus, this.WidgetColors);

  @override
  State<CustomDeviceWidget> createState() => _CustomDeviceWidgetState();
}

class _CustomDeviceWidgetState extends State<CustomDeviceWidget> {
  var dio = Dio();
  // var IP = "http://13.235.244.236:3000";
  var IP = "http://192.168.1.4:3000";
  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/lock/updateLockStatus',
        data: {"deviceID": deviceID, "state": status});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 10),
        itemCount: widget.nodeID.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 100,
          crossAxisSpacing: 15.0,
          mainAxisSpacing: 15.0,
          childAspectRatio: 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          // return CustomLockSwitch(nodeData[index], context, index);
          return GestureDetector(
            onTap: () {
              bool val = !widget.nodeStatus[index];
              sendResponse(val, widget.nodeID[index]['deviceID']);
              setState(() {
                widget.nodeStatus[index] = val;
              });
              // showMaterialModalBottomSheet(
              //   backgroundColor: Colors.transparent,
              //   context: context,
              //   builder: (context) => Container(
              //     height: 210,
              //     decoration: BoxDecoration(
              //       color: Color(0xFFC3B3F0),
              //       borderRadius: BorderRadius.circular(15),
              //     ),
              //   ),
              // );
            },
            child: widget.nodeStatus[index]
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFF6171DC),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            deviceIconWidget(Colors.white,
                                widget.nodeID[index]['deviceType']!),
                            Transform.scale(
                              scale: 0.7,
                              child: CupertinoSwitch(
                                activeColor: Colors.white54,
                                value: widget.nodeStatus[index],
                                onChanged: (val) {
                                  sendResponse(
                                      val, widget.nodeID[index]['deviceID']);
                                  setState(() {
                                    widget.nodeStatus[index] = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.nodeID[index]['deviceType'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            widget.nodeStatus[index]
                                ? Text(
                                    "ON",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    "OFF",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ), //BoxDecoration
                  )
                : Container(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Color(0xFFDBDBFC),
                      // color: Color(0xFF6171DC),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // deviceIcon(1),
                        // iconMapping["lamp"]!,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            deviceIconWidget(Color(0xFF6171DC),
                                widget.nodeID[index]['deviceType']!),
                            Transform.scale(
                              scale: 0.7,
                              child: CupertinoSwitch(
                                activeColor: Colors.white54,
                                value: widget.nodeStatus[index],
                                onChanged: (val) {
                                  sendResponse(
                                      val, widget.nodeID[index]['deviceID']);
                                  setState(() {
                                    widget.nodeStatus[index] = val;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                              widget.nodeID[index]['deviceType'],
                              style: TextStyle(
                                  color: Color(0xFF6171DC),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            widget.nodeStatus[index]
                                ? Text(
                                    "ON",
                                    style: TextStyle(
                                      color: Color(0xFF6171DC),
                                      fontSize: 12,
                                    ),
                                  )
                                : Text(
                                    "OFF",
                                    style: TextStyle(
                                      color: Color(0xFF6171DC),
                                      fontSize: 12,
                                    ),
                                  ),
                          ],
                        ),
                      ],
                    ), //BoxDecoration
                  ),
          );
        },
      ),
    );
  }
}

class deviceIconWidget extends StatelessWidget {
  late Color color;
  late String icon;
  deviceIconWidget(this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    Map<String, Icon> iconWhiteMapping = {
      'lock': Icon(
        CupertinoIcons.lock,
        size: 50,
        color: Colors.white,
      ),
      'lamp': Icon(
        CupertinoIcons.lightbulb,
        size: 50,
        color: Colors.white,
      ),
      'fan': Icon(
        CupertinoIcons.dial_fill,
        size: 50,
        color: Colors.white,
      ),
      'tv': Icon(
        CupertinoIcons.tv,
        size: 50,
        color: Colors.white,
      ),
    };
    Map<String, Icon> iconBlueMapping = {
      'lock': Icon(
        CupertinoIcons.lock,
        size: 50,
        color: Color(0xFF6171DC),
      ),
      'lamp': Icon(
        CupertinoIcons.lightbulb,
        size: 50,
        color: Color(0xFF6171DC),
      ),
      'fan': Icon(
        CupertinoIcons.dial_fill,
        size: 50,
        color: Color(0xFF6171DC),
      ),
      'tv': Icon(
        CupertinoIcons.tv,
        size: 50,
        color: Color(0xFF6171DC),
      ),
    };
    return color == Colors.white
        ? iconWhiteMapping[icon]!
        : iconBlueMapping[icon]!;
  }
}
