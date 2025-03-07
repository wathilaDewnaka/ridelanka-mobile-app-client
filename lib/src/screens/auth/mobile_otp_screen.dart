import 'dart:async';

import 'package:client/global_variable.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/initialize_push.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/screens/rider/rider_navigation_menu.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MobileOTPScreen extends StatefulWidget {
  const MobileOTPScreen({
    super.key,
    required this.verificationId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.isPassenger,
    required this.isRegister,
    required this.forceResendingToken,
  });

  final String verificationId;
  final String fullName;
  final String phoneNumber;
  final String email;
  final int? forceResendingToken;
  final bool isPassenger;
  final bool isRegister;

  @override
  State<MobileOTPScreen> createState() => _MobileOTPScreenState();
}

class _MobileOTPScreenState extends State<MobileOTPScreen> {
  TextEditingController otpController = TextEditingController();
  late StreamController<ErrorAnimationType> errorController;

  String currentText = "";
  String verificationIds = "";
  int? forceResendingToken;
  bool isLoading = false;
  bool isResendLoading = false;
  int countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>();
    verificationIds = widget.verificationId;
    forceResendingToken = widget.forceResendingToken;
    print("verificationIds");
    print(verificationIds);
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
      setState(() {
        isLoading = true;
      });
      final cred = PhoneAuthProvider.credential(
          verificationId: verificationIds, smsCode: otpController.text);

      // Sign in with the credential
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(cred);
      firebaseUser = FirebaseAuth.instance.currentUser;

      DatabaseReference databaseReference = (widget.isPassenger)
          ? FirebaseDatabase.instance
              .ref()
              .child('users/${userCredential.user!.uid}')
          : FirebaseDatabase.instance
              .ref()
              .child('drivers/${userCredential.user!.uid}');

      if (widget.isRegister) {
        Map<String, String> userMap = {
          "fullname": widget.fullName,
          "email": widget.email,
          "phone": widget.phoneNumber,
        };

        databaseReference.set(userMap);
      } else {
        databaseReference.once().then((DatabaseEvent event) {
          final snapshot = event.snapshot;
          if (snapshot.exists) {
            return;
          }
        }).catchError((error) {
          return;
        });
      }

      InitializePush().initialize();
      if (widget.isPassenger) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('isPassenger', "true");
        Navigator.pushNamedAndRemoveUntil(
          context,
          RiderNavigationMenu.id,
          (route) => false, // Removes all previous routes
        );
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('isPassenger', "false");

        isVehicleExist =
            await HelperMethods.checkIsVehicleExist(firebaseUser!.uid);
        driverName =
            await HelperMethods.getDriverName(firebaseUser!.uid) ?? "Mr. N /A";

        final pref = await SharedPreferences.getInstance();
        await pref.setString("driverId", userCredential.user!.uid);

        Navigator.pushNamedAndRemoveUntil(
          context,
          DriverHome.id,
          (route) => false, // Removes all previous routes
        );
      }
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error",
          message: "Invalid OTP Code!",
          type: MessageType.error));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void resendOTP() async {
    try {
      setState(() {
        isResendLoading = true;
      });
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: forceResendingToken, // Ensure token is used
        verificationCompleted: (phoneAuthCredential) async {
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Error",
              message: "Unable to verify the phone number!",
              type: MessageType.error));
        },
        codeSent: (verificationId, newResendToken) {
          setState(() {
            verificationIds = verificationId;
            forceResendingToken = newResendToken; // Update the token
            startCountdown(); // Restart countdown timer
          });
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Success",
              message: "OTP sent to ${widget.phoneNumber} successfully!",
              type: MessageType.success));
        },
        codeAutoRetrievalTimeout: (verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Error",
              message: "Auto retrieval timeout!",
              type: MessageType.error));
        },
      );

      print("verificationIds");
      print(verificationIds);
      await Future.delayed(const Duration(seconds: 8));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error", message: e.toString(), type: MessageType.error));
    } finally {
      setState(() {
        isResendLoading = false;
      });
    }
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
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
              onChanged: (value) {
                setState(() {
                  currentText = value;
                });
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
                    : isResendLoading
                        ? const Text(
                            "Wait...",
                            style: TextStyle(color: Colors.grey),
                          )
                        : GestureDetector(
                            onTap: () {
                              resendOTP();
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
              onPressed: validateOTP,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF0051ED),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                      "Verify",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
