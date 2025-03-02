import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';


class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool saveCard = false;
  bool isProcessing = false;

  void showPaymentResult(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Payment Successful!" : "Payment Failed!"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Card Payment")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Credit Card UI Preview
            CreditCardWidget(
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              showBackView: isCvvFocused, // Flip when CVV is focused
              onCreditCardWidgetChange: (brand) {},
            ),

            // Credit Card Form
            CreditCardForm(
              formKey: formKey, // Required
              cardNumber: cardNumber, // Required
              expiryDate: expiryDate, // Required
              cardHolderName: cardHolderName, // Required
              cvvCode: cvvCode, // Required
              themeColor: Colors.blue, // Required
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                  isCvvFocused = data.isCvvFocused;
                });
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: saveCard,
                  onChanged: (bool? value) {
                    setState(() {
                      saveCard = value!;
                    });
                  },
                ),
                Text("Save card for future payments"),
              ],
            ),
            SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isProcessing = true;
                    });

                    // Simulate payment processing
                    await Future.delayed(Duration(seconds: 2));

                    setState(() {
                      isProcessing = false;
                    });

                    showPaymentResult(true); // or false for failure
                  } else {
                    print("Invalid Card Details");
                  }
                },
                child: isProcessing
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Pay \$97.42",
                        style: TextStyle(
                          color: Colors.blue, // Change this to any color you want
                          fontSize: 18, // Optional: Adjust font size
                          fontWeight: FontWeight.bold, // Optional: Add bold font weight
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
