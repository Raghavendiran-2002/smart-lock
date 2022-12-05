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
  var IP = "http://13.235.244.236:3000";
  // var IP = "http://192.168.1.4:3000";d
  Map<String, bool> deviceInfo = {};

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

  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/lock/updateLockStatus',
        data: {"deviceID": deviceID, "deviceState": status});
  }

  void getLockStatus() async {
    var response = await Dio().get('${IP}/lock/getAllNodeID');
    nodeID = response.data;
    for (Map map in nodeID) {
      deviceInfo[map['deviceID']] = map['deviceState'];
    }
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
                        builder: (context) => SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            height: 210,
                            decoration: BoxDecoration(
                              color: Color(0xFFC3B3F0),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            filled: true,
                                            hintStyle: TextStyle(
                                                color: Colors.grey[800]),
                                            hintText: "Enter Unique CODE",
                                            fillColor: Colors.white70),
                                      ),
                                    ),
                                    ElevatedButton(
                                        // Color(0xFF6171DC)
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.white,
                                        ),
                                        onPressed: () {},
                                        child: Text(
                                          "Connect",
                                          style: TextStyle(
                                              color: Color(0xFF6171DC)),
                                        ))
                                  ],
                                )),
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
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  itemCount: nodeID.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 100,
                    crossAxisSpacing: 15.0,
                    mainAxisSpacing: 15.0,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        bool val = !deviceInfo[nodeID[index]['deviceID']]!;
                        deviceInfo[nodeID[index]['deviceID']] =
                            !nodeID[index]['deviceState'];
                        print(deviceInfo[nodeID[index]['deviceID']]);
                        print(nodeID[index]['deviceState']);
                        sendResponse(val, nodeID[index]['deviceID']);
                        setState(() {
                          deviceInfo[nodeID[index]['deviceID']] = val;
                        });
                      },
                      child: deviceInfo[nodeID[index]['deviceID']]!
                          ? CustomDeviceWidget(
                              nodeID,
                              deviceInfo[nodeID[index]['deviceID']]!,
                              Color(0xFF6171DC), //0xFFDBDBFC
                              Colors.white,
                              nodeID[index]['deviceType']!,
                              index)
                          : CustomDeviceWidget(
                              nodeID,
                              deviceInfo[nodeID[index]['deviceID']]!,
                              Color(0xFFDBDBFC),
                              Color(0xFF6171DC),
                              nodeID[index]['deviceType']!,
                              index),
                    );
                  },
                ),
              ),
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
  final bool deviceStatus;
  final Color widgetColors;
  final Color textColors;
  final String icon;
  final int index;
  CustomDeviceWidget(this.nodeID, this.deviceStatus, this.widgetColors,
      this.textColors, this.icon, this.index);

  @override
  State<CustomDeviceWidget> createState() => _CustomDeviceWidgetState();
}

class _CustomDeviceWidgetState extends State<CustomDeviceWidget> {
  var dio = Dio();
  var IP = "http://13.235.244.236:3000";
  // var IP = "http://192.168.1.4:3000";
  void sendResponse(status, deviceID) async {
    await dio.post('${IP}/lock/updateLockStatus',
        data: {"deviceID": deviceID, "deviceState": status});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
      decoration: BoxDecoration(
        color: widget.widgetColors,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              deviceIconWidget(widget.nodeID[widget.index]['deviceType']!,
                  widget.deviceStatus),
              Transform.scale(
                scale: 0.7,
                child: CupertinoSwitch(
                  activeColor: Colors.white54,
                  value: widget.deviceStatus,
                  onChanged: (val) {
                    // sendResponse(val, widget.nodeID[widget.index]['deviceID']);
                    // setState(() {
                    //   widget.nodeStatus[widget.index] = val;
                    // });
                  },
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                widget.nodeID[widget.index]['deviceType'],
                style: TextStyle(
                  color: widget.textColors,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              widget.deviceStatus
                  ? Text(
                      "ON",
                      style: TextStyle(
                        color: widget.textColors,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      "OFF",
                      style: TextStyle(
                        color: widget.textColors,
                        fontSize: 12,
                      ),
                    ),
            ],
          ),
        ],
      ), //BoxDecoration
    );
  }
}

class deviceIconWidget extends StatelessWidget {
  late String icon;
  late bool deviceState;
  deviceIconWidget(this.icon, this.deviceState);

  @override
  Widget build(BuildContext context) {
    Map<bool, Color> iconColoring = {
      true: Colors.white,
      false: Color(0xFF6171DC),
    };
    Map<String, IconData> iconMapping = {
      'lock': CupertinoIcons.lock,
      'lamp': CupertinoIcons.lightbulb,
      'fan': CupertinoIcons.dial_fill,
      'tv': CupertinoIcons.tv,
    };
    return Icon(iconMapping[icon], color: iconColoring[deviceState], size: 50);
  }
}
