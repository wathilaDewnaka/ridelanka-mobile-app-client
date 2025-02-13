import 'package:flutter/material.dart';

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
      appBar: AppBar(title: Text('Add Vehicle')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCard('Add Images', [
                ElevatedButton(onPressed: () {}, child: Icon(Icons.add_a_photo))
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
                onPressed: () {},
                child: Text('Next'),
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
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
}
