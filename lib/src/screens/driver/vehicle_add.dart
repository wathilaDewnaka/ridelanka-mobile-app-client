import 'package:flutter/material.dart';

class VehicleAddScreen extends StatefulWidget {
  @override
  _VehicleAddScreenState createState() =>
      _VehicleAddScreenState();
}

class _VehicleAddScreenState extends State<VehicleAddScreen> {
  int _currentStep = 0;

  final TextEditingController licenseController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController seatingController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();
  final TextEditingController refereeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Vehicle')),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 1) {
            setState(() => _currentStep += 1);
          } else {
            // Submit data
            print("Submit all data");
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          // Step 1: Vehicle Information
          Step(
            title: Text(_currentStep == 0 ? 'Step 1: Vehicle Info' : ""),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            content: Column(
              children: [
                DropdownButtonFormField(
                  items: ['School', 'Staff']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: 'Service Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField(
                  items: ['Van', 'Bus']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {},
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
                  controller: licenseController,
                  decoration: InputDecoration(
                    labelText: 'Driving License Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField(
                  items: ['Yes', 'No']
                      .map((value) =>
                          DropdownMenuItem(value: value, child: Text(value)))
                      .toList(),
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: 'Air Conditioning Availability',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Step 2: Pricing and Background
          Step(
            title:
                Text(_currentStep == 1 ? 'Step 2: Pricing & Background' : ''),
            isActive: _currentStep >= 1,
            state: _currentStep == 1 ? StepState.indexed : StepState.complete,
            content: Column(
              children: [
                TextField(
                  controller: startLocationController,
                  decoration: InputDecoration(
                    labelText: 'Start Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: endLocationController,
                  decoration: InputDecoration(
                    labelText: 'End Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Predict price logic
                  },
                  child: Text('Predict Price'),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: experienceController,
                  decoration: InputDecoration(
                    labelText: 'Work Experience',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: languagesController,
                  decoration: InputDecoration(
                    labelText: 'Languages',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Route details of the vehicle',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
