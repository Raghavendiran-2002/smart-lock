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
  late var node1;
  // List nodeID = [];
  List docs = [];
  late final AnimationController _controller;
  final Uri _url = Uri.parse('http://proxy60.rt3.io:37278/');
  late bool toggleStatus;
  late var nodeStatus;
  late var nodeID;
  var dio = Dio();
  final firestoreInstance = FirebaseFirestore.instance;

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  void getLockStatus() async {
    try {
      var response =
          await Dio().get('http://13.235.99.169:3000/lock/getByNode/0x01');
      // k = response.data['values'][0]['nodeId'];
      // print(response.data['values'][0]['nodeId']); // access the json data
      node1 = response.data['values'][0]['nodeId'];
      // print(response.data.toString()); // Prints the Data
      // print(k);
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          if (response.data['values'][0]['status'] == "true") {
            toggleStatus = true;
          } else {
            toggleStatus = false;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  // void initLockStatus() async {
  //   try {
  //     var response =
  //         await Dio().get('http://13.235.99.169:3000/lock/getAllNodeID');
  //     s = response.data;
  //     // k = response.data['values'][0]['nodeId'];
  //     // print(response.data['values'][0]['nodeId']); // access the json data
  //     // node1 = response.data['values'][0]['nodeId'];
  //     // print(response.data.toString()); // Prints the Data
  //     print('list : $s');
  //     var no = s.length;
  //     print('list : $no');
  //     // print(k);
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         if (response.data['values'][0]['status'] == "true") {
  //           toggleStatus = true;
  //         } else {
  //           toggleStatus = false;
  //         }
  //         isLoading = true;
  //       });
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void sendResponse(status, deviceID) async {
    Response response = await dio.post(
        'http://13.235.99.169:3000/lock/updateLockStatus',
        data: {"nodeId": deviceID, "status": status});
    print(status);
    // print(response.data['quality']['status']);
    print(response.data);
  }

  void _lockRealTimeChanges() {
    firestoreInstance.collection("lockRealTime").snapshots().listen((result) {
      result.docChanges.forEach((res) {
        if (res.type == DocumentChangeType.modified) {
          // print(res.doc.data());
          // print(res.doc['isChanged']);
          setState(() {
            // node1 = res.doc['nodeID'];
            toggleStatus = res.doc['isChanged'];
          });
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // initLockStatus();
    getLockStatus();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1));
    _lockRealTimeChanges();
    setState(() {
      // isLoading = false;
    });
    // toggleStatus = fa;
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
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // isLoading
                //     ? Column(
                //         children: listvieww(s),
                //       )
                //     : CircularProgressIndicator(),
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
                    child: Lottie.network(
                      "https://assets10.lottiefiles.com/packages/lf20_rf7upa0j.json",
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
                // Row(
                //   children: [
                //     isLoading
                //         ? Container(
                //             width: 170,
                //             height: 300,
                //             //BoxDecoration Widget
                //             decoration: BoxDecoration(
                //               //DecorationImage
                //               border: Border.all(
                //                 color: Color(0xFF666CDB),
                //                 width: 2,
                //               ),
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 toggleStatus
                //                     ? Image.asset('assets/images/lock.png',
                //                         width: 150,
                //                         height: 120,
                //                         fit: BoxFit.fill)
                //                     : Image.asset('assets/images/unlock.png',
                //                         width: 150,
                //                         height: 120,
                //                         fit: BoxFit.fill),
                //                 isLoading
                //                     ? Text(node1)
                //                     : CircularProgressIndicator(),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 FlutterSwitch(
                //                     value: toggleStatus,
                //                     onToggle: (val) {
                //                       sendResponse(val, "0x01");
                //                       setState(() {
                //                         toggleStatus = val;
                //                       });
                //                     }),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 Text("Smart Lock 1"),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //               ],
                //             ) //BoxDecoration
                //             )
                //         : Center(child: CircularProgressIndicator()),
                //     SizedBox(
                //       width: 5,
                //     ),
                //     isLoading
                //         ? Container(
                //             width: 170,
                //             height: 300,
                //             //BoxDecoration Widget
                //             decoration: BoxDecoration(
                //               //DecorationImage
                //               border: Border.all(
                //                 color: Color(0xFF666CDB),
                //                 width: 2,
                //               ),
                //               color: Colors.white,
                //               borderRadius: BorderRadius.circular(20),
                //             ),
                //             child: Column(
                //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //               children: [
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 toggleStatus
                //                     ? Image.asset('assets/images/lock.png',
                //                         width: 150,
                //                         height: 120,
                //                         fit: BoxFit.fill)
                //                     : Image.asset('assets/images/unlock.png',
                //                         width: 150,
                //                         height: 120,
                //                         fit: BoxFit.fill),
                //                 isLoading
                //                     ? Text(node1)
                //                     : CircularProgressIndicator(),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 FlutterSwitch(
                //                     value: toggleStatus,
                //                     onToggle: (val) {
                //                       sendResponse(val, "0x01");
                //                       setState(() {
                //                         toggleStatus = val;
                //                       });
                //                     }),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //                 Text("Smart Lock 1"),
                //                 SizedBox(
                //                   height: 10,
                //                 ),
                //               ],
                //             ) //BoxDecoration
                //             )
                //         : Center(child: CircularProgressIndicator()),
                //   ],
                // ),
                SizedBox(
                  height: 20,
                ),
                isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(
                        width: 170,
                        height: 300,
                        //BoxDecoration Widget
                        decoration: BoxDecoration(
                          //DecorationImage
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
                            toggleStatus
                                ? Image.asset('assets/images/lock.png',
                                    width: 150, height: 120, fit: BoxFit.fill)
                                : Image.asset('assets/images/unlock.png',
                                    width: 150, height: 120, fit: BoxFit.fill),
                            isLoading
                                ? Text(node1)
                                : CircularProgressIndicator(),
                            SizedBox(
                              height: 10,
                            ),
                            FlutterSwitch(
                                value: toggleStatus,
                                onToggle: (val) {
                                  sendResponse(val, "0x01");
                                  setState(() {
                                    toggleStatus = val;
                                  });
                                }),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Smart Lock 1"),
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

// wigetSome(s) {
//   return List.generate(s.length, (index) => Text(s[index]['nodeId']));
// }
//
// listvieww(s) {
//   return GridView.builder(
//     itemCount: s.length,
//     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 4.0),
//     itemBuilder: (BuildContext context, int index) {
//       return Text(s[index]['nodeId']);
//     },
//   );
// }
