import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AddVehiclePage1(),
  ));
}

class AddVehiclePage1 extends StatefulWidget {
  @override
  _AddVehiclePage1State createState() => _AddVehiclePage1State();
}

class _AddVehiclePage1State extends State<AddVehiclePage1> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController seatingController = TextEditingController();

  File? _image;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _validateAndProceed() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddVehiclePage2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0051ED),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Image Upload Section
                buildCard('Upload Vehicle Image', [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue[50],
                    ),
                    child: Center(
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo,
                            color: Color(0xFF0051ED), size: 40),
                        onPressed: _pickImage,
                      ),
                    ),
                  ),
                  if (_image != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.file(
                        _image!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                ]),

                // Driver Information
                buildCard('Driver Information', [
                  buildTextField(driverNameController, 'Driver Name'),
                  buildTextField(licenseController, 'License Number'),
                ]),

                // Vehicle Information
                buildCard('Vehicle Information', [
                  buildTextField(vehicleTypeController, 'Vehicle Type'),
                  buildTextField(modelController, 'Vehicle Model and Year'),
                  buildTextField(seatingController, 'Seating Capacity'),
                ]),

                SizedBox(height: 16),

                // Next Button
                ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: elevatedButtonStyle(),
                  child: Text('Next', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddVehiclePage2 extends StatefulWidget {
  @override
  _AddVehiclePage2State createState() => _AddVehiclePage2State();
}

class _AddVehiclePage2State extends State<AddVehiclePage2> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  void _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vehicle Added Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0051ED),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Pricing Details
                buildCard('Pricing', [
                  buildTextField(startLocationController, 'Start Location'),
                  buildTextField(endLocationController, 'End Location'),
                  buildTextField(priceController, 'Price', isNumeric: true),
                  ElevatedButton(
                    onPressed: () {
                      // Predict price functionality
                    },
                    style: elevatedButtonStyle(),
                    child: Text('Predict Price',
                        style: TextStyle(color: Colors.white)),
                  ),
                ]),

                // Add Description Section
                buildCard('Add Description', [
                  buildTextField(
                      descriptionController, 'Write a Description here',
                      maxLines: 4),
                ]),

                SizedBox(height: 16),

                // Submit Button
                ElevatedButton(
                  onPressed: _validateAndSubmit,
                  style: elevatedButtonStyle(),
                  child: Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable Widget for Text Fields with Validation
Widget buildTextField(TextEditingController controller, String label,
    {int maxLines = 1, bool isNumeric = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    ),
  );
}

// Reusable Widget for Cards
Widget buildCard(String title, List<Widget> children) {
  return Card(
    color: Colors.blue[50],
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF0051ED))),
          SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}

// Button Style
ButtonStyle elevatedButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Color(0xFF0051ED),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );
}
