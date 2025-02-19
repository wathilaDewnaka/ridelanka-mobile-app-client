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
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCard('Add Images', [
                ElevatedButton(
                  onPressed: () {},
                  style: elevatedButtonStyle(),
                  child: Icon(Icons.add_a_photo, color: Colors.white),
                )
              ]),
              buildCard('Driver Information', [
                buildTextField(driverNameController, 'Driver Name'),
                buildTextField(contactController, 'Contact Number'),
                buildTextField(licenseController, 'License Number'),
              ]),
              buildCard('Vehicle Information', [
                buildTextField(vehicleTypeController, 'Vehicle Type'),
                buildTextField(modelController, 'Vehicle Model and Year'),
                buildTextField(seatingController, 'Seating Capacity'),
                buildDropdown(['Yes', 'No'], 'Air Conditioning Availability'),
              ]),
              buildCard('Add Description', [
                buildTextField(
                    descriptionController, 'Write a description here',
                    maxLines: 3),
              ]),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehicleAddScreen()),
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
  final TextEditingController refereeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Vehicle', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCard('Pricing', [
                buildTextField(startLocationController, 'Start Location'),
                buildTextField(endLocationController, 'End Location'),
                buildTextField(priceController, 'Price'),
                ElevatedButton(
                  onPressed: () {},
                  style: elevatedButtonStyle(),
                  child: Text('Predict Price',
                      style: TextStyle(color: Colors.white)),
                ),
              ]),
              buildCard('Background Details', [
                buildTextField(experienceController, 'Work Experience'),
                buildTextField(countController, 'Current Count in Vehicle'),
                buildTextField(languagesController, 'Languages'),
                buildDropdown(
                    ['Cash', 'Card', 'Online Payment'], 'Payment Method'),
              ]),
              buildCard('Referee Details', [
                buildTextField(refereeController, 'Write a description here',
                    maxLines: 3),
              ]),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
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

Widget buildDropdown(List<String> items, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: DropdownButtonFormField(
      items: items.map((String value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    ),
  );
}

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
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
          SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}

ButtonStyle elevatedButtonStyle() {
  return ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
  );
}
