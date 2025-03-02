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
          ],
        ),
      ),
    );
  }
}
