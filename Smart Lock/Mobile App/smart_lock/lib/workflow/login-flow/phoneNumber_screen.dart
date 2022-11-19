import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'otp_screen.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  String phoneNumber = "0000000000";
  bool phoneFieldInit = false;

  late Timer timer;

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

  void phoneFieldController(String pressedKey) {
    switch (pressedKey) {
      case "-1":
        if (!phoneFieldInit || phoneNumber.isEmpty) return;
        setState(() {
          //removing last digit
          phoneNumber =
              phoneNumber.replaceRange(phoneNumber.length - 1, null, "");
          if (phoneNumber.isEmpty) {
            setState(() {
              phoneFieldInit = false;
              phoneNumber = "0000000000";
            });
          }
        });
        break;
      case "10":
        break;
      default:
        if (!phoneFieldInit) {
          phoneNumber = "";
          setState(() {
            phoneNumber += pressedKey;
            phoneFieldInit = true;
          });
        } else {
          if (phoneNumber.length == 10) return;
          setState(() {
            phoneNumber += pressedKey;
          });
        }
        break;
    }
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Continue with Phone",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(40),
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Image.asset(
                  "assets/images/blue2.jpg",
                  height: 225,
                ),
                Text(
                  "You'll receive a 6 digit code\nto verify next.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        offset: Offset(0, 0),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                    borderRadius: BorderRadius.all(
                      Radius.circular(15),
                    ),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter your phone",
                            style: TextStyle(),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "+91 ",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                () {
                                  if (phoneNumber.length <= 5)
                                    return phoneNumber;
                                  return phoneNumber.substring(0, 5) +
                                      " " +
                                      phoneNumber.substring(5);
                                }(),
                                style: TextStyle(
                                  fontSize: 20,
                                  color: phoneFieldInit
                                      ? Colors.black
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 65,
                        width: 145,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (phoneNumber.length != 10) {
                                    displaySnackBar(
                                        "A Phone number without 10 digits?  🤔");
                                  } else if (!phoneFieldInit) {
                                    displaySnackBar("Don't have a Phone?   😂");
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await FirebaseAuth.instance
                                        .verifyPhoneNumber(
                                      phoneNumber: "+91" + phoneNumber,
                                      verificationCompleted:
                                          (PhoneAuthCredential credential) {
                                        displaySnackBar("Auto Verified!",
                                            color: Colors.green);
                                        print("auto verification completed");
                                        //popping everything and pushing on homeScreen
                                        // Navigator.of(context).pushAndRemoveUntil(
                                        //     MaterialPageRoute(
                                        //       builder: (context) => HomeScreen(),
                                        //     ),
                                        //     (Route<dynamic> route) => false);
                                      },
                                      verificationFailed:
                                          (FirebaseAuthException e) {
                                        displaySnackBar(
                                            "Verification failed! Try again later 😓");

                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      codeSent: (String verificationID,
                                          int? resendToken) async {
                                        //todo: use a timer or something to figure out if recently otp sent to same number

                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => OTPScreen(
                                                verificationID: verificationID,
                                                phoneNumber:
                                                    "+91" + phoneNumber),
                                          ),
                                        );
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      codeAutoRetrievalTimeout:
                                          (String verificationId) {},
                                    );
                                    if (Platform.isAndroid) {
                                      Future.delayed(Duration(seconds: 10))
                                          .then((value) {
                                        if (!isLoading) return;
                                        displaySnackBar(
                                            "Timed out! Try again later 😓");
                                        setState(() {
                                          isLoading = false;
                                        });
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFDC3D),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: isLoading
                              ? SpinKitWave(
                                  color: Colors.white,
                                  size: 25.0,
                                )
                              : Text(
                                  "Continue",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: Container(
          //     padding: EdgeInsets.symmetric(vertical: 20, horizontal: 22),
          //     color: Color(0xFFF6F5FA),
          //     child: GridView.count(
          //       physics: NeverScrollableScrollPhysics(),
          //       crossAxisCount: 3,
          //       childAspectRatio: 1.8,
          //       mainAxisSpacing: 15,
          //       crossAxisSpacing: 20,
          //       children: getKeypadChildren(),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
