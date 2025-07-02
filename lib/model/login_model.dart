import 'device_info_login_model.dart';

class LoginModel {
  LoginModel({
    this.contactNo, 
    this.deviceInfo, 
    this.countryCode,
    this.email,
    this.firstName,
    this.lastName,
    this.password,
    this.oauthType,
  });

  String? contactNo;
  String? email;
  String? countryCode;
  String? firstName;
  String? lastName;
  String? password;
  String? oauthType; // phone, email, google, apple, facebook
  DeviceInfoLoginModel? deviceInfo = DeviceInfoLoginModel();

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
        contactNo: json["contactNo"],
        countryCode: json["countryCode"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        password: json["password"],
        oauthType: json["oauthType"],
      );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    
    // Only include non-null values
    if (contactNo != null) json["contactNo"] = contactNo;
    if (deviceInfo != null) json["userDeviceDetails"] = deviceInfo;
    if (countryCode != null) json["countryCode"] = countryCode;
    if (email != null) json["email"] = email;
    if (firstName != null) json["firstName"] = firstName;
    if (lastName != null) json["lastName"] = lastName;
    if (oauthType != null) json["oauthType"] = oauthType;
    
    // Only include password if it's not null (for email/password login)
    if (password != null && password!.isNotEmpty) {
      json["password"] = password;
    }
    
    return json;
  }
}
