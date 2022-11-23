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
  bool quickViewItems = true;
  bool isLoading = true;
  List<Stream<QuerySnapshot>> streams = [];
  List docs = [];
  // late final AnimationController _controller;
  final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  bool toggleStatus = false;
  bool internetConnectivity = false;
  late var nodeStatus;
  late var nodeID;
  var dio = Dio();
  final db = FirebaseFirestore.instance;

  void getDevices() async {
    var temp = await FirebaseFirestore.instance.collection("lock").get();
    docs = temp.docs;
    for (var doc in docs) {
      streams.add(
        FirebaseFirestore.instance
            .collection('lock')
            .where(FieldPath.documentId, isEqualTo: doc.id)
            .snapshots(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  void getHttp() async {
    try {
      var response =
          await Dio().get('http://13.235.99.169:8000/lock/getByNode/ragsdgsdf');
      print(response.data['values'][0]['nodeId']); // access the json data
      print(response.data.toString()); // Prints the Data
      if (response.statusCode == 200) {}
    } catch (e) {
      print(e);
    }
  }

  void sendResponse(status, deviceID) async {
    Response response = await dio.post(
        'http://13.235.99.169:8000/lock/postLockStatus',
        data: {"nodeId": "poiopu", "status": "pdsgd", "motion": "gfdg"});
    print(response.data['status']);
  }

  @override
  void initState() {
    getDevices();

    super.initState();
    // sendResponse(":hg", "jhg");
    // _controller = AnimationController(vsync: this);
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              isLoading
                  ? CircularProgressIndicator()
                  : GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: streams.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                docs[index]["id"],
                              ),
                              StreamBuilder(
                                stream: streams[index],
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "!!!",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    );
                                  }

                                  if (snapshot.data!.docs.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "no source",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    );
                                  }

                                  return Switch(
                                    value: snapshot.data!.docs[0]['status'],
                                    onChanged: snapshot.data!.docs[0]['motion']
                                        ? null
                                        : (bool value) {
                                            FirebaseFirestore.instance
                                                .collection("lock")
                                                .doc(snapshot.data!.docs[0].id)
                                                .set(
                                              //setting target state to !actualState
                                              {
                                                "targetState": !snapshot
                                                    .data!.docs[0]['state'],
                                                "isTransient": true,
                                              },
                                              SetOptions(
                                                merge: true,
                                              ),
                                            );
                                          },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10),
                    ),

              // Container(
              //   height: 150,
              //   width: 150,
              //   child: InkWell(
              //     onTap: () {
              //       switch (_controller.status) {
              //         case AnimationStatus.completed:
              //           _controller.reverse();
              //           break;
              //         case AnimationStatus.dismissed:
              //           _controller.forward();
              //           break;
              //         default:
              //       }
              //     },
              //     child: Lottie.asset(
              //       'assets/images/passwordlock.json',
              //       controller: _controller,
              //       onLoaded: (composition) {
              //         // Configure the AnimationController with the duration of the
              //         // Lottie file and start the animation.
              //         _controller
              //           ..duration = composition.duration
              //           ..forward();
              //       },
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 10,
              ),
              Container(
                  width: 150,
                  height: 150,
                  //BoxDecoration Widget
                  decoration: BoxDecoration(
                    //DecorationImage
                    border: Border.all(
                      color: Color(0xFF666CDB),
                      width: 1,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FlutterSwitch(
                          value: toggleStatus,
                          onToggle: (val) {
                            setState(() {
                              toggleStatus = val;
                            });
                          }),
                      Text("On"),
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
    );
  }
}
