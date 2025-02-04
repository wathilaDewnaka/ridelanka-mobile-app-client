import 'package:client/src/widgets/brand_divier.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var pickupController = TextEditingController();
  var destinationController = TextEditingController();

  var focusDestination = FocusNode();

  bool focused = false;
  void setFocus() {
    if (!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    setFocus();

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: 220,
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7, 0.7))
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 5,
                  ),
                  Stack(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back)),
                      const Center(
                        child: Text(
                          'Set Destination',
                          style:
                              TextStyle(fontSize: 20, fontFamily: 'Brand-Bold'),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        'images/pickicon.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFe2e2e2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              controller: pickupController,
                              decoration: const InputDecoration(
                                  hintText: 'Pickup location',
                                  fillColor: Color(0xFFe2e2e2),
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: <Widget>[
                      Image.asset(
                        'images/desticon.png',
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(
                        width: 18,
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFe2e2e2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: TextField(
                              onChanged: (value) {
                                print("this is destination");
                              },
                              focusNode: focusDestination,
                              controller: destinationController,
                              decoration: const InputDecoration(
                                  hintText: 'Where to?',
                                  fillColor: Color(0xFFe2e2e2),
                                  filled: true,
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 10, top: 8, bottom: 8)),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
