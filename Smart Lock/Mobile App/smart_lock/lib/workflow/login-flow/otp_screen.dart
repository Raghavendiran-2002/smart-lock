import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:smart_lock/workflow/login-flow/services/phoneNumber_Helper.dart';

import '../home-flow/screens/homeScreen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationID;
  final String phoneNumber;
  OTPScreen({required this.verificationID, required this.phoneNumber});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late String code;
  bool validated = false;
  bool isLoading = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 120,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Enter your\nverification code",
                      style: TextStyle(
                        fontSize: 25,
                        color: Color(0xFF151D56),
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "We sent a verification code\nto ${() {
                        return PhoneNumberHelper()
                            .formatPhoneNumberWithCountryCode(
                                widget.phoneNumber, 2);
                      }()}",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    // Image.asset(
                    //   'assets/images/green1.jpg',
                    //   height: 200,
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 300, //larger width doesn't overflow,
                      //widget renders to screen width on smaller phones

                      child: Pinput(
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: 100,
                          height: 65,
                          textStyle: TextStyle(
                            fontSize: 25,
                            color: Color(0xFF151D56),
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (String? pin) {
                          RegExp regex = RegExp(r'^[0-9]*$');

                          if (!regex.hasMatch(pin!)) {
                            return "Only numbers, please!";
                          }
                          if (pin.length != 6) {
                            return (6 - pin.length).toString() +
                                " more digit${() {
                                  if (pin.length == 5) return "";
                                  return "s";
                                }()}, you can do it!";
                          }
                          validated = true;
                          code = pin;
                          return null;
                        },
                        onChanged: (String pin) => validated = false,
                        showCursor: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    SizedBox(
                      height: 50,
                      width: 170,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF151D56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (validated) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  PhoneAuthCredential credential =
                                      PhoneAuthProvider.credential(
                                          verificationId: widget.verificationID,
                                          smsCode: code);
                                  try {
                                    await auth.signInWithCredential(credential);
                                    displaySnackBar("Login Successful!  👍",
                                        color: Colors.green);
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => HomeScreen(
                                            // phoneNumber: widget.phoneNumber,
                                            // userUID: auth.currentUser!.uid,
                                            ),
                                      ),
                                    );
                                  } catch (e) {
                                    displaySnackBar("Invalid Code!  😓");
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                        child: Text(
                          "Verify",
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "Change phone number",
                        style: TextStyle(
                          color: Color(0xFF34D0E9),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
