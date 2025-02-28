import 'package:client/global_variable.dart';
import 'package:client/src/data_provider/app_data.dart';
import 'package:client/src/data_provider/prediction.dart';
import 'package:client/src/methods/request_helper.dart';
import 'package:client/src/models/address.dart';
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

  String languageType = "";
  String type = "";
  String vehicleType = "";
  String airCondition = "";
  List<Prediction> _filteredPlaces = [];
  bool _showDropdown = false;
  bool isStart = false;
  FocusNode _startLocationFocusNode = FocusNode();

  void addVehicle() async {
    DatabaseReference driverData = FirebaseDatabase.instance.ref().child("drivers/1234");
    Map<String, String> vehicleData = {
      "vehicleName": modelController.text,
      "vehicleNo": vehicleNoController.text,
      "vehiclePrice": priceController.text,
      "seatCapacity": seatingController.text,
      "experience": experienceController.text,
      "routeDetails": descriptionController.text
    };
    await driverData.set(vehicleData);
  }

  void getPlaceDetails(String placeId, bool isStartLocation) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: "Please wait..."));

    String url = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if (response == 'failed') {
      return;
    }

    if (response['status'] == 'OK') {
      Address thisPlace = Address(
          placeId: placeId,
          latitude: response['result']['geometry']['location']['lat'],
          longitude: response['result']['geometry']['location']['lng'],
          placeName: response['result']['name'],
          placeFormattedAddress: '');

      if (isStartLocation) {
        Provider.of<AppData>(context, listen: false).updateStartAddress(thisPlace);
      } else {
        Provider.of<AppData>(context, listen: false).updateEndAddress(thisPlace);
      }
      setState(() {
        _showDropdown = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0051ED),
        title: const Text("Add Vehicle", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stepper(
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
        steps: [
          Step(
            title: const Text('Vehicle Info'),
            content: Column(
              children: [
                TextField(controller: modelController, decoration: InputDecoration(labelText: 'Vehicle Model and Year')),
                TextField(controller: vehicleNoController, decoration: InputDecoration(labelText: 'Vehicle Number')),
              ],
            ),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Pricing Info'),
            content: Column(
              children: [
                TextField(controller: startLocationController, decoration: InputDecoration(labelText: 'Start Location')),
                TextField(controller: endLocationController, decoration: InputDecoration(labelText: 'End Location')),
              ],
            ),
            isActive: _currentStep >= 1,
          ),
        ],
      ),
    );
  }
}