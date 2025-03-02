import 'package:firebase_database/firebase_database.dart';

class Driver {
  String? fullName;
  String? email;
  String? phone;
  String? id;
  String? vehicalType;
  String? vehicalNo;
  String? vehicalName;

  Driver({
    this.fullName,
    this.email,
    this.phone,
    this.id,
    this.vehicalType,
    this.vehicalNo,
    this.vehicalName,
  });



  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;

    var data = snapshot.value as Map<dynamic, dynamic>?;  
    if (data != null) {
      phone = data['phone'] as String?;
      email = data['email'] as String?;
      fullName = data['fullname'] as String?;
      vehicalName = data['vehicleName'] as String?;
      vehicalNo = data['vehicleNo'] as String?;
      vehicalType = data['vehicleType'] as String?;
      
    }
  }

  @override
  String toString() {
    return 'Driver(id: $id, fullName: $fullName, email: $email, phone: $phone, '
           'vehicleType: $vehicalType, vehicleNo: $vehicalNo, vehicleName: $vehicalName)';
  }
}
