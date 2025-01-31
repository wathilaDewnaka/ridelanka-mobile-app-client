import 'dart:async';
import 'dart:developer';

import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class MobileOTPScreen extends StatefulWidget {
  const MobileOTPScreen(
      {super.key,
      required this.verificationId,
      required this.fullName,
      required this.phoneNumber,
      required this.email,
      required this.isPassenger,
      required this.isRegister});
  final String verificationId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final bool isPassenger;
  final bool isRegister;

  @override
  State<MobileOTPScreen> createState() => _MobileOTPScreenState();
}

class _MobileOTPScreenState extends State<MobileOTPScreen> {
  TextEditingController otpController = TextEditingController();

  late StreamController<ErrorAnimationType> errorController;

  String currentText = "";
  int countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    startCountdown();
  }

  @override
  void dispose() {
    errorController.close();
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    setState(() {
      countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown == 0) {
        timer.cancel();
      } else {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void validateOTP() async {
    try {
      final cred = PhoneAuthProvider.credential(
          verificationId: widget.verificationId, smsCode: otpController.text);

      // Sign in with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);

      DatabaseReference databaseReference = (widget.isPassenger)
          ? FirebaseDatabase.instance
              .ref()
              .child('drivers/${userCredential.user!.uid}')
          : FirebaseDatabase.instance
              .ref()
              .child('users/${userCredential.user!.uid}');

      if (widget.isRegister) {
        Map<String, String> userMap = {
          "fullname": widget.fullName,
          "email": widget.email,
          "phone": widget.phoneNumber,
        };

        databaseReference.set(userMap);
        log("Completed !");
        return;
      }

      databaseReference.once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        if (snapshot.exists) {
          return;
        } else {
          return;
        }
      }).catchError((error) {
        return;
      });
    } catch (e) {
      
    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Invalid OTP Code !",
        type: MessageType.error));
  }
  
  }

  void resendOTP() async {
    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "OTP sent again to ${widget.phoneNumber} successfully !",
        type: MessageType.success));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text(
              "Phone Verification",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Enter the 6-digit OTP sent to your phone",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            PinCodeTextField(
              appContext: context,
              length: 6,
              obscureText: false,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(13),
                fieldHeight: 65,
                fieldWidth: 50,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade100,
                inactiveFillColor: Colors.grey.shade50,
                activeColor: const Color.fromARGB(255, 175, 200, 247),
                selectedColor: const Color.fromARGB(255, 175, 200, 247),
                inactiveColor: const Color.fromARGB(255, 233, 233, 233),
                borderWidth: 0.4,
              ),
              animationDuration: const Duration(milliseconds: 300),
              enableActiveFill: true,
              errorAnimationController: errorController,
              controller: otpController,
              onCompleted: (v) {
                print("Completed: $v");
              },
              onChanged: (value) {
                print(value);
                setState(() {
                  currentText = value;
                });
              },
              beforeTextPaste: (text) {
                print("Allowing to paste $text");
                return true;
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Didn't receive the OTP code? "),
                countdown > 0
                    ? Text(
                        "Resend in $countdown s",
                        style: const TextStyle(color: Colors.grey),
                      )
                    : GestureDetector(
                        onTap: () {
                          resendOTP();
                          startCountdown();
                        },
                        child: const Text(
                          "Resend",
                          style: TextStyle(color: Color(0xFF0051ED)),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                validateOTP();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF0051ED),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: const Text(
                "Verify",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
