import 'dart:convert';
import 'dart:io';

import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/data_provider/prediction.dart';
import 'package:client/src/methods/helper_methods.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
import 'package:client/src/screens/driver/driver_dashboard.dart';
import 'package:client/src/widgets/message_bar.dart';
import 'package:client/src/widgets/progress_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class VehicleAddScreen extends StatefulWidget {
  VehicleAddScreen({super.key, required this.isAdd});

  final bool isAdd;

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
  String imageUrl = "";

  List<Prediction> _filteredPlaces = [];
  bool _showDropdown = false;
  bool isStart = false;

  final FocusNode _startLocationFocusNode = FocusNode();
  final FocusNode _endLocationFocusNode = FocusNode();

  File? _image;
  final picker = ImagePicker();
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future _uploadImage() async {
    if (_image == null) return;

    try {
      String fileName = _image!.path + DateTime.now().toString();
      Reference ref = storage.ref().child('uploads/$fileName');
      UploadTask uploadTask = ref.putFile(_image!);

      await uploadTask.whenComplete(() => print('File Uploaded'));
      String downloadURL = await ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

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

    if (!widget.isAdd) {
      loadDetailsFromDB();
    }
  }

  @override
  void dispose() {
    _startLocationFocusNode.dispose();
    _endLocationFocusNode.dispose();
    super.dispose();
  }

  void loadDetailsFromDB() async {
    DatabaseReference vehDetails =
        FirebaseDatabase.instance.ref("drivers/${firebaseUser!.uid}");

    try {
      DatabaseEvent event = await vehDetails.once();
      if (event.snapshot.value != null) {
        Map<String, dynamic> details =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        vehicleNoController.text = details["vehicleNo"];
        modelController.text = details['vehicleName'];
        seatingController.text = details['seatCapacity'];
        priceController.text = details['vehiclePrice'];
        descriptionController.text = details['routeDetails'];
        experienceController.text = details['experience'];

        startLocationController.text = details['startPlaceName'];
        endLocationController.text = details['endPlaceName'];

        setState(() {
          vehicleType = details['vehicleType'];
          type = details['type'];
          lanuageType = details['lanuage'];
          imageUrl = details['vehicleImage'];
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
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
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialog(status: "Please wait..."));

    String img = await _uploadImage();
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
      "vehicleImage": img,
      "vehicleType": vehicleType,
      "lanuage": lanuageType,
      "startPlaceName": startLocationController.text,
      "endPlaceName": endLocationController.text,
      "location": {
        "startLat": Provider.of<AppData>(context, listen: false)
            .driverStartAddress
            .latitude,
        "startLng": Provider.of<AppData>(context, listen: false)
            .driverStartAddress
            .longituge,
        "endLat": Provider.of<AppData>(context, listen: false)
            .driverEndAddress
            .latitude,
        "endLng": Provider.of<AppData>(context, listen: false)
            .driverEndAddress
            .longituge
      },
      "ratings": {"average": 5.0, "count": 0}
    };

    try {
      await driverData.update(vehicleData); // Save the vehicle data
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Success",
        message: widget.isAdd
            ? "Vehicle added successfully"
            : "Vehicle edited successfully",
        type: MessageType.success,
      ));

      if (widget.isAdd) {
        isVehicleExist = true;
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DriverHome()),
            (route) => false);
      } else {
        Navigator.pop(context);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Error",
        message:
            widget.isAdd ? "Failed to add vehicle" : "Failed to edit vehicle",
        type: MessageType.error,
      ));
      Navigator.pop(context);
    }
  }

  void getPlacedDetails(String placeId, bool isStartLocation) async {
    setState(() {
      _filteredPlaces.clear();
    });
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

  Future<void> makePostRequest() async {
    final url =
        Uri.parse('https://harmonious-dream-production.up.railway.app/predict');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'start': startLocationController.text,
        'end': endLocationController.text,
        'type': vehicleType,
        'service': type,
        'distance': HelperMethods.haversine(
            LatLng(
                Provider.of<AppData>(context, listen: false)
                    .driverStartAddress
                    .latitude,
                Provider.of<AppData>(context, listen: false)
                    .driverStartAddress
                    .longituge),
            LatLng(
                Provider.of<AppData>(context, listen: false)
                    .driverEndAddress
                    .latitude,
                Provider.of<AppData>(context, listen: false)
                    .driverEndAddress
                    .longituge))
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      priceController.text = responseData['price'];
    } else {
      print("Error: ${response.statusCode}");
    }
  }

  void predictPriceUsingAI() async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(status: 'Please wait...'),
    );

    await makePostRequest();
    ScaffoldMessenger.of(context).showSnackBar(createMessageBar(
        title: "Predicted Price",
        message: "Predicted price updated in input box",
        type: MessageType.info));

    Navigator.pop(context);
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              elevation: 0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 17.0),
              child: Text(
                widget.isAdd ? "Add Vehicle" : "Edit Vehicle",
                style: const TextStyle(
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
                            if (_image == null && imageUrl.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select vehicle image",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (type.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select service type",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (vehicleType.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select vehicle type",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (modelController.text.isEmpty ||
                                modelController.text.length < 5) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message:
                                    "Vehicle name should have at least 5 characters",
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
                            } else if (seatingController.text.isEmpty ||
                                int.tryParse(seatingController.text) == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message:
                                    "Seating capacity should be a valid number",
                                type: MessageType.error,
                              ));
                              return;
                            }
                          } else {
                            if (Provider.of<AppData>(context, listen: false)
                                    .driverStartAddress
                                    .latitude ==
                                0.0) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select start location",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (Provider.of<AppData>(context,
                                        listen: false)
                                    .driverEndAddress
                                    .latitude ==
                                0.0) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select end location",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (Provider.of<AppData>(context,
                                            listen: false)
                                        .driverEndAddress
                                        .latitude ==
                                    Provider.of<AppData>(context, listen: false)
                                        .driverStartAddress
                                        .latitude &&
                                Provider.of<AppData>(context, listen: false)
                                        .driverEndAddress
                                        .longituge ==
                                    Provider.of<AppData>(context, listen: false)
                                        .driverStartAddress
                                        .longituge) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Please select correct locations",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (priceController.text.isEmpty ||
                                double.tryParse(priceController.text) == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Price should be a valid number",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (experienceController.text.isEmpty ||
                                int.tryParse(experienceController.text) ==
                                    null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Experience should be a valid number",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (lanuageType.isEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message: "Lanuage should be selected",
                                type: MessageType.error,
                              ));
                              return;
                            } else if (descriptionController.text.isEmpty ||
                                descriptionController.text.length < 10) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(createMessageBar(
                                title: "Error",
                                message:
                                    "Route details should have at least 10 characters",
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
                          _currentStep < 1
                              ? "Next"
                              : widget.isAdd
                                  ? "Add Vehicle"
                                  : "Edit Vehicle",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentStep == 0) {
                            Navigator.pop(context);
                          } else {
                            details.onStepCancel!();
                          }
                        },
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
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 110,
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
                            child: _image == null && imageUrl.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Upload Image",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 8),
                                        Icon(Icons.add_a_photo)
                                      ],
                                    ),
                                  )
                                : Container(
                                    child: imageUrl.isEmpty
                                        ? Image.file(
                                            _image!,
                                          )
                                        : Image.network(imageUrl),
                                    height: 100,
                                    width: double.infinity,
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
                        value: type.isNotEmpty
                            ? type.substring(0, 1).toUpperCase() +
                                type.substring(1).toLowerCase()
                            : null,
                        decoration: const InputDecoration(
                          labelText: 'Service Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        items: ['Van', 'Bus']
                            .map((value) => DropdownMenuItem(
                                value: value, child: Text(value)))
                            .toList(),
                        value: vehicleType.isNotEmpty ? vehicleType : null,
                        onChanged: (value) {
                          setState(() {
                            vehicleType = value!;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: modelController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Model and Year',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: vehicleNoController,
                        decoration: const InputDecoration(
                          labelText: 'Vehicle Number',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: seatingController,
                        decoration: const InputDecoration(
                          labelText: 'Seating Capacity',
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
                            decoration: const InputDecoration(
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
                                    labelText: 'Price (Rs)',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: ElevatedButton(
                                  onPressed: () {
                                    predictPriceUsingAI();
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
                            value: lanuageType.isNotEmpty ? lanuageType : null,
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
