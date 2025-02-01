import 'package:client/src/screens/auth/mobile_register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  static const String id = "signin";

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  bool isPassenger = true;
  bool agreeToTerms = false;

  final emailController = TextEditingController();
  String phoneNumber = "";

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
              "Sign in",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
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
                          isPassenger ? Colors.grey[100] : Colors.white,
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
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF0051ED),
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(10)), // Removes rounding
                ),
              ),
              child: const Text(
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
                const Text("Don’t have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MobileRegisterScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Sign up",
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
