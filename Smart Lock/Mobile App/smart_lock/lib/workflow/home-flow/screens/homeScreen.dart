import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool quickViewItems = true;
  bool isLoading = true;
  List<Stream<QuerySnapshot>> streams = [];
  var node1 = '0x01';
  List docs = [];
  late final AnimationController _controller;
  final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  late bool toggleStatus;
  bool internetConnectivity = false;
  late var nodeStatus;
  late var nodeID;
  late var k;
  var dio = Dio();
  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  void getHttp() async {
    try {
      var response =
          await Dio().get('http://172.20.10.6:3000/lock/getByNode/0x01');
      // k = response.data['values'][0]['nodeId'];
      // print(response.data['values'][0]['nodeId']); // access the json data
      // print(response.data.toString()); // Prints the Data
      // print(k);

      if (response.statusCode == 200) {
        setState(() {
          if (response.data['values'][0]['status'] == "true") {
            toggleStatus = true;
          } else {
            toggleStatus = false;
          }
          isLoading = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void sendResponse(status, deviceID) async {
    Response response = await dio.post(
        'http://172.20.10.6:3000/lock/updateLockStatus',
        data: {"nodeId": deviceID, "status": status});
    print(response.data['status']);
  }

  void _onPressed() {
    firestoreInstance.collection("lockRealTime").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified) {
          print("modified");
          // print(res.doc.data());
          // print(res.doc['isChanged']);
          setState(() {
            node1 = res.doc['isChanged'];
            toggleStatus = res.doc['isChanged'];
          });
          // getHttp();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _onPressed();
    // getHttp();
    setState(() {
      isLoading = false;
    });
    toggleStatus = true;
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
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: 150,
                  child: InkWell(
                    onTap: () {
                      switch (_controller.status) {
                        case AnimationStatus.completed:
                          _controller.reverse();
                          break;
                        case AnimationStatus.dismissed:
                          _controller.forward();
                          break;
                        default:
                      }
                    },
                    child: Lottie.asset(
                      'assets/images/passwordlock.json',
                      controller: _controller,
                      onLoaded: (composition) {
                        // Configure the AnimationController with the duration of the
                        // Lottie file and start the animation.
                        _controller
                          ..duration = composition.duration
                          ..forward();
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                    width: 330,
                    height: 170,
                    //BoxDecoration Widget
                    decoration: BoxDecoration(
                      //DecorationImage
                      border: Border.all(
                        color: Color(0xFF666CDB),
                        width: 2,
                      ),
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text("Smart Lock 1"),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              FlutterSwitch(
                                  value: toggleStatus,
                                  onToggle: (val) {
                                    sendResponse(val, node1);
                                    setState(() {
                                      toggleStatus = val;
                                    });
                                  }),
                              toggleStatus
                                  ? Image(
                                      image:
                                          AssetImage('assets/images/lock.png'))
                                  : Image(
                                      image: AssetImage(
                                          'assets/images/unlock.png')),
                            ],
                          ),
                        ),
                        isLoading ? Text("dfg") : CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ) //BoxDecoration
                    ),
                //Container
                SizedBox(
                  height: 20,
                ),
                // InkWell(
                //   onTap: () {
                //     switch (_controller.status) {
                //       case AnimationStatus.completed:
                //         _controller.reverse();
                //         break;
                //       case AnimationStatus.dismissed:
                //         _controller.forward();
                //         break;
                //       default:
                //     }
                //   },
                //   child: Container(
                //     height: 150,
                //     width: 150,
                //     child: InkWell(
                //       onTap: () {
                //         _launchUrl();
                //       },
                //       child: Lottie.asset(
                //         'assets/images/securitycamera.json',
                //         controller: _controller,
                //         onLoaded: (composition) {
                //           // Configure the AnimationController with the duration of the
                //           // Lottie file and start the animation.
                //           _controller
                //             ..duration = composition.duration
                //             ..forward();
                //         },
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
