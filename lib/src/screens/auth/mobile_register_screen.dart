import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/screens/auth/mobile_login_screen.dart';
import 'package:client/src/screens/auth/mobile_otp_screen.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileRegisterScreen extends StatefulWidget {
  const MobileRegisterScreen({super.key});

  static const String id = "signup";

  @override
  State<MobileRegisterScreen> createState() => _MobileRegisterScreenState();
}

class _MobileRegisterScreenState extends State<MobileRegisterScreen> {
  bool isPassenger = true;
  bool isLoading = false;
  bool agreeToTerms = false;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String phoneNumber = "";
  String? title = "Mr.";

  void registerUser() async {
    try {
      // Validate email
      setState(() {
        isLoading = true;
      });
      String email = emailController.text.trim();
      String name = nameController.text.trim();

      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "Invalid email address!",
            type: MessageType.error));
        return;
      }

      // Check if phone number exists
      bool phoneNum =
          await HelperMethods.checkPhoneNumberExists(phoneNumber, isPassenger);
      String fullName = "$title $name";

      if (phoneNum) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "Phone number already exists!",
            type: MessageType.error));
        return;
      } else if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "Name cannot be empty!",
            type: MessageType.error));
        return;
      } else if (!agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "You must agree to the terms and conditions!",
            type: MessageType.error));
        return;
      } else if (name.length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "Please enter a valid name!",
            type: MessageType.error));
        return;
      } else if (name.split(" ").length != 2) {
        ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
            title: "Error",
            message: "Please enter a valid name!",
            type: MessageType.error));
        return;
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (phoneAuthCredential) async {
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Error",
              message: "Unable to verify the phone number !",
              type: MessageType.error));
        },
        codeSent: (verificationId, forceResendingToken) {
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Success",
              message: "OTP Sent to $phoneNumber successfully !",
              type: MessageType.success));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MobileOTPScreen(
                  verificationId: verificationId,
                  fullName: fullName,
                  phoneNumber: phoneNumber,
                  email: email,
                  isPassenger: isPassenger,
                  isRegister: true,
                  forceResendingToken: forceResendingToken),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
              title: "Error",
              message: "Auto retrievel time out !",
              type: MessageType.error));
        },
      );

      await Future.delayed(const Duration(seconds: 8));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
          title: "Error", message: e.toString(), type: MessageType.error));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text(
              "Sign up",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                      border: Border.all(color: Colors.grey), // Border for
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: DropdownButton<String>(
                      value: title,
                      items: ["Mr.", "Mrs.", "Miss", "Dr.", "Prof."]
                          .map((String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                      underline: const SizedBox(), // Remove default underline
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Full Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            IntlPhoneField(
              decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  counterText: ''),
              initialCountryCode: 'LK', // Default country
              onChanged: (phone) {
                setState(() {
                  phoneNumber = phone.completeNumber;
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter
                    .digitsOnly, // Ensures only digits are entered
              ],
              showDropdownIcon: false,
              showCountryFlag: false,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Passenger Button
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => isPassenger = true),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)), // Removes rounding
                      ),
                      backgroundColor:
                          isPassenger ? Colors.grey[200] : Colors.white,
                    ),
                    child: const Text(
                      'Passenger',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                // Driver Button
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => isPassenger = false),
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      backgroundColor:
                          !isPassenger ? Colors.grey[200] : Colors.white,
                    ),
                    child: const Text(
                      'Driver',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                registerUser();
              },
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
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: const Color(0xFF0051ED),
                  value: agreeToTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      agreeToTerms = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "By proceeding, you are agreeing to our Terms and Conditions",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Row(
              children: [
                Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("or"),
                ),
                Expanded(
                  child: Divider(
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MobileLoginScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: Color(0xFF0051ED),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
