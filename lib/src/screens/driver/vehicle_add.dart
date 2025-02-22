import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: VehicleAddScreen(),
  ));
}

class VehicleAddScreen extends StatelessWidget {
  final TextEditingController driverNameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController licenseController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final TextEditingController modelController = TextEditingController();
  final TextEditingController seatingController = TextEditingController();

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
                      onPressed: () {
                        // Image Picker functionality
                      },
                    ),
                  ),
                ),
              ]),

              // Driver Information
              buildCard('Driver Information', [
                buildTextField(driverNameController, 'Driver Name'),
                buildTextField(contactController, 'Contact Number'),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleAddScreen2()),
                  );
                },
                style: elevatedButtonStyle(),
                child: Text('Next', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleAddScreen2 extends StatelessWidget {
  final TextEditingController startLocationController = TextEditingController();
  final TextEditingController endLocationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController countController = TextEditingController();
  final TextEditingController languagesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Add Vehicle - Page 2', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF0051ED),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Pricing Details
              buildCard('Pricing', [
                buildTextField(startLocationController, 'Start Location'),
                buildTextField(endLocationController, 'End Location'),
                buildTextField(priceController, 'Price'),
                ElevatedButton(
                  onPressed: () {
                    // Predict price functionality
                  },
                  style: elevatedButtonStyle(),
                  child: Text('Predict Price',
                      style: TextStyle(color: Colors.white)),
                ),
              ]),

              // Work Experience & Details
              buildCard('Driver Background Details', [
                buildTextField(experienceController, 'Work Experience'),
                buildTextField(countController, 'Current Count in Vehicle'),
                buildTextField(languagesController, 'Languages'),
              ]),

              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Vehicle Added Successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: elevatedButtonStyle(),
                child: Text('Submit', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Widget for Text Fields
Widget buildTextField(TextEditingController controller, String label,
    {int maxLines = 1}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
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
