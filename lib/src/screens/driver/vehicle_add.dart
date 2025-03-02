import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/data_provider/prediction.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VehicleAddScreen extends StatefulWidget {
  @override
  _VehicleAddScreenState createState() => _VehicleAddScreenState();
}

class _VehicleAddScreenState extends State<VehicleAddScreen> {
  int _currentStep = 0;

  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController seatingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  String lanuageType = "";

  String type = "";
  String vehicleType = "";
  String airCondition = "";

  List<Prediction> _filteredPlaces = [];
  bool _showDropdown = false;
  bool isStart = false;

  // Create FocusNodes for both location fields
  final FocusNode _startLocationFocusNode = FocusNode();
  final FocusNode _endLocationFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listeners for both FocusNodes
    _startLocationFocusNode.addListener(() {
      if (!_startLocationFocusNode.hasFocus) {
        setState(() {
          _showDropdown = false;
        });
      }
    });

    _endLocationFocusNode.addListener(() {
      if (!_endLocationFocusNode.hasFocus) {
        setState(() {
          _showDropdown = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _startLocationFocusNode.dispose();
    _endLocationFocusNode.dispose();
    super.dispose();
  }

  void searchPlace(String placeName, {required bool isStartLocation}) async {
    if (placeName.isEmpty) {
      setState(() {
        _filteredPlaces.clear();
      });
      return;
    }

    setState(() {
      _showDropdown = true;
      isStart = isStartLocation;
    });

    String countryCode = 'LK';
    String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&types=geocode&components=country:$countryCode&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      var predictionJson = response['predictions'];

      var thisList =
          (predictionJson as List).map((e) => Prediction.fromJson(e)).toList();

      setState(() {
        _filteredPlaces = thisList;
      });
    }
  }

  void addVehicle() async {
    if (modelController.text.isEmpty || modelController.text.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Vehicle name should have at least 5 characters",
        type: MessageType.error,
      ));
      return;
    } else if (seatingController.text.isEmpty ||
        int.tryParse(seatingController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Seating capacity should be a valid number",
        type: MessageType.error,
      ));
      return;
    } else if (priceController.text.isEmpty ||
        double.tryParse(priceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Price should be a valid number",
        type: MessageType.error,
      ));
      return;
    } else if (descriptionController.text.isEmpty ||
        descriptionController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Route details should have at least 10 characters",
        type: MessageType.error,
      ));
      return;
    } else if (experienceController.text.isEmpty ||
        int.tryParse(experienceController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Experience should be a valid number",
        type: MessageType.error,
      ));
      return;
    }

    DatabaseReference driverData =
        FirebaseDatabase.instance.ref().child("drivers/${firebaseUser!.uid}");

    Map<String, dynamic> vehicleData = {
      "vehicleName": modelController.text,
      "vehicleNo": vehicleNoController.text,
      "vehiclePrice": priceController.text,
      "seatCapacity": seatingController.text,
      "experience": experienceController.text,
      "routeDetails": descriptionController.text,
      "type": type,
      "vehicleType": vehicleType,
      "location": {
        "startLat": Provider.of<AppData>(context).driverStartAddress.latitude,
        "startLng": Provider.of<AppData>(context).driverStartAddress.longituge,
        "endLat": Provider.of<AppData>(context).driverEndAddress.latitude,
        "endLng": Provider.of<AppData>(context).driverEndAddress.longituge
      }
    };

    try {
      await driverData.set(vehicleData); // Save the vehicle data
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: "Vehicle added successfully",
        type: MessageType.success,
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message: "Failed to add vehicle: $error",
        type: MessageType.error,
      ));
    }
  }

  void getPlacedDetails(String placeId, bool isStartLocation) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Please wait..."));

    String url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address(
          placeId: placeId,
          latitude: response['result']['geometry']['location']['lat'],
          longituge: response['result']['geometry']['location']['lng'],
          placeName: response['result']['name'],
          placeFormattedAddress: '');

      if (isStartLocation) {
        Provider.of<AppData>(context, listen: false)
            .updateStartAddress(thisPlace);
      } else {
        Provider.of<AppData>(context, listen: false)
            .updateEndAddress(thisPlace);
      }
      setState(() {
        _showDropdown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0051ED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppBar(
              backgroundColor: const Color(0xFF0051ED),
              leading: IconButton(
                icon:
                    const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                onPressed: () {},
              ),
              elevation: 0,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                "Add Vehicle",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Theme(
            data: ThemeData(
              colorScheme: const ColorScheme.light(
                  primary: Color(0xFF0051ED),
                  surface: Colors.white,
                  shadow: Colors.transparent,
                  secondary: Colors.black87),
            ),
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 1) {
                  setState(() => _currentStep += 1);
                } else {
                  addVehicle();
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep -= 1);
                }
              },
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStep == 0) {
                            if (type.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select service type",
                                type: MessageType.error,
                              ));
                              return;
                            }
                          } else if (vehicleType.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(createMessageBar(
                              title: "Error",
                              message: "Please select vehicle type",
                              type: MessageType.error,
                            ));
                            return;
                          } else if (vehicleNoController.text.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(createMessageBar(
                              title: "Error",
                              message: "Vehicle number cannot be empty",
                              type: MessageType.error,
                            ));
                            return;
                          } else if (airCondition.isEmpty) {
                            if (vehicleNoController.text.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select air conditioned or not",
                                type: MessageType.error,
                              ));
                              return;
                            }
                          }

                          if (details.onStepContinue != null) {
                            details.onStepContinue!();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF0051ED),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: Text(
                          _currentStep < 1 ? "Next" : "Add Vehicle",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: const Color(0xFF0051ED),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: Text(
                    _currentStep == 0 ? 'Step 1: Vehicle Info' : "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  isActive: _currentStep >= 0,
                  state:
                      _currentStep > 0 ? StepState.complete : StepState.indexed,
                  content: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Card(
                          elevation: 3,
                          color: Colors.grey[50],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0)),
                          child: Padding(
                            padding: EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Upload Image",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 8),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Icon(Icons.add_a_photo))
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        items: ['School', 'Staff']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            type = value!.toLowerCase();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Service Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        items: ['Van', 'Bus']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            vehicleType = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: modelController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Model and Year',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: vehicleNoController,
                        decoration: InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField(
                        items: ['Yes', 'No']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            airCondition = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Air Conditioning Availability',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                Step(
                  title: Text(
                    _currentStep == 1 ? 'Step 2: Pricing Info' : '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep == 1
                      ? StepState.indexed
                      : StepState.complete,
                  content: Stack(
                    clipBehavior: Clip.none, // Allow widgets to overflow
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Start Location TextField
                          TextField(
                            controller: startLocationController,
                            decoration: InputDecoration(
                              labelText: 'Start Location',
                              border: OutlineInputBorder(),
                            ),
                            focusNode: _startLocationFocusNode,
                            onChanged: (value) {
                              searchPlace(value, isStartLocation: true);
                            },
                          ),
                          const SizedBox(height: 16),

                          // End Location TextField
                          TextField(
                            controller: endLocationController,
                            decoration: const InputDecoration(
                              labelText: 'End Location',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              searchPlace(value, isStartLocation: false);
                            },
                          ),
                          const SizedBox(height: 16),

                          // Price and Predict Button Row
                          Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: TextField(
                                  controller: priceController,
                                  decoration: const InputDecoration(
                                    labelText: 'Price',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Predict action
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 55),
                                    backgroundColor: const Color(0xFF0051ED),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0)),
                                    ),
                                  ),
                                  child: const Text(
                                    "Predict",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Work Experience TextField
                          TextField(
                            controller: experienceController,
                            decoration: const InputDecoration(
                              labelText: 'Work Experience',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Preferred Language Dropdown
                          DropdownButtonFormField(
                            items: ['English', 'Sinhala', 'Tamil']
                                .map((value) => DropdownMenuItem(
                                    value: value, child: Text(value)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                lanuageType = value!;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Preferred Language',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Route Details TextField
                          TextField(
                            controller: descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Route details of the vehicle',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      if (_showDropdown)
                        Positioned(
                          top:
                              isStart ? 55 : 126, // Adjust position dynamically
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _filteredPlaces.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    _filteredPlaces[index].mainText +
                                        " " +
                                        _filteredPlaces[index].secondaryText,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      if (isStart) {
                                        startLocationController.text =
                                            _filteredPlaces[index].mainText;
                                        getPlacedDetails(
                                            _filteredPlaces[index].placeId,
                                            true);
                                      } else {
                                        endLocationController.text =
                                            _filteredPlaces[index].mainText;
                                        getPlacedDetails(
                                            _filteredPlaces[index].placeId,
                                            false);
                                      }
                                      _showDropdown = false;
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
