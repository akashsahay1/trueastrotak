import 'dart:async';
import 'dart:convert';

import 'package:trueastrotalk/controllers/bottomNavigationController.dart';
import 'package:trueastrotalk/controllers/dropDownController.dart';
import 'package:trueastrotalk/model/astrologer_model.dart';
import 'package:trueastrotalk/model/intake_model.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

import '../utils/date_converter.dart';

class IntakeController extends GetxController {
  BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();

  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController birthTimeController = TextEditingController();
  TextEditingController placeController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ocupationController = TextEditingController();
  TextEditingController partnerNameController = TextEditingController();
  TextEditingController partnerPlaceController = TextEditingController();
  TextEditingController partnerDobController = TextEditingController();
  TextEditingController partnerBirthController = TextEditingController();

  TextEditingController verifyPhoneController = TextEditingController();

  double? lat;
  double? long;
  dynamic tzone;

  APIHelper apiHelper = APIHelper();
  var astrologerSorting = <AstrologerModel>[];
  var intakeData = <IntakeModel>[];
  DateTime? selctedPartnerDate;
  DateTime? selctedDate;
  TextEditingController searchReportController = TextEditingController();
  DropDownController dropDownController = Get.find<DropDownController>();
  String errorText = "";
  bool isEnterPartnerDetails = false;
  bool isSelect = false;
  String? sortingFilter = ''.obs();
  FocusNode namefocus = FocusNode();
  FocusNode phonefocus = FocusNode();
  FocusNode partnerNamefocus = FocusNode();
  FocusNode occupationfocus = FocusNode();

  bool isValue = true;

  String gender = 'male';
  String? intakeContact;
  String? countryCode;
  bool isAddNewRequestByFreeuser = false;
  String? freedefaultTime;

  @override
  void onInit() {
    _inIt();
    super.onInit();
  }

  _inIt() async {
    await getFormIntakeData();
  }

  updateGeneder(value) {
    gender = value;
    update();
  }

  getGeoCodingLatLong({double? latitude, double? longitude}) async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.geoCoding(lat: latitude, long: longitude).then((result) {
            if (result.status == "true") {
              tzone = double.parse(result.recordList['timezone'].toString());

              print("timezone");
              print("$tzone");
              update();
            } else {
              global.showToast(message: 'NOt Avalilable', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getGeoCodingLatLong():' + e.toString());
    }
  }

  partnerDetails(bool value) {
    isEnterPartnerDetails = value;
    if (isEnterPartnerDetails == false) {
      selctedPartnerDate = null;
      partnerDobController.clear();
      partnerPlaceController.clear();
      partnerBirthController.clear();
      partnerNameController.clear();
    }
    update();
  }

  bool isVarified = true;

  checkContact(String number) {
    if (number.length == 10) {
      intakeContact = number;
    }
    if (intakeContact != "${global.user.contactNo}") {
      isVarified = false;
      update();
    } else {
      isVarified = true;
      update();
    }
    update();
  }

  updateCountryCode(value) {
    countryCode = value.toString();
    update();
  }

  bool isValidData() {
    if (nameController.text == "") {
      errorText = "Please Enter Name";
      return false;
    } else if (phoneController.text == "") {
      errorText = "Please Enter Phone Number";
      return false;
    } else if (dobController.text == "") {
      errorText = "Please Enter Date of Birth";
      return false;
    } else if (birthTimeController.text == " " || birthTimeController.text.isEmpty) {
      errorText = "Please Enter time of Birth";
      return false;
    } else if (placeController.text == " " || placeController.text.isEmpty) {
      errorText = "Please Enter Place of Birth";
      return false;
    } else {
      if (isEnterPartnerDetails) {
        if (partnerNameController.text == "") {
          errorText = "Please Enter partner name";
          return false;
        } else if (partnerDobController.text == "") {
          errorText = "Please Enter partner DOB";
          return false;
        } else if (partnerPlaceController.text == "") {
          errorText = "Please Enter partner birth place";
          return false;
        }
      }
      return true;
    }
  }

  addCallIntakeFormData() async {
    IntakeModel intakeModel =
        isEnterPartnerDetails == true
            ? IntakeModel(
              name: nameController.text,
              birthDate: selctedDate == null ? DateTime(1994) : DateTime.parse(selctedDate.toString()),
              birthPlace: placeController.text,
              birthTime: birthTimeController.text,
              countryCode: countryCode ?? "+91",
              gender: gender,
              maritalStatus: dropDownController.maritalStatus ?? "Single",
              occupation: ocupationController.text == "" ? "" : ocupationController.text,
              partnerBirthDate:
                  isEnterPartnerDetails == true
                      ? selctedPartnerDate == null
                          ? DateTime(1994)
                          : DateTime.parse(selctedPartnerDate.toString())
                      : null,
              partnerBirthPlace: partnerPlaceController.text == "" ? null : partnerPlaceController.text,
              partnerBirthTime: partnerBirthController.text == "" ? null : partnerBirthController.text,
              partnerName: partnerNameController.text == "" ? null : partnerNameController.text,
              phoneNumber: phoneController.text,
              topicOfConcern: dropDownController.topic ?? 'Study',
              latitude: lat,
              longitude: long,
              timezone: tzone,
            )
            : IntakeModel(
              name: nameController.text,
              birthDate: selctedDate == null ? DateTime(1994) : DateTime.parse(selctedDate.toString()),
              birthPlace: placeController.text,
              birthTime: birthTimeController.text,
              countryCode: countryCode ?? "+91",
              gender: gender,
              maritalStatus: dropDownController.maritalStatus ?? "Single",
              occupation: ocupationController.text == "" ? null : ocupationController.text,
              phoneNumber: phoneController.text,
              topicOfConcern: dropDownController.topic ?? 'StuGLOdy',
              latitude: lat,
              longitude: long,
              timezone: tzone,
            );
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.addIntakeDetail(intakeModel).then((result) async {
            if (result.status == "200") {
              await getFormIntakeData();
            } else {
              global.showToast(message: 'Failed to add form data!', textColor: global.textColor, bgColor: global.toastBackGoundColor);
            }
          });
        }
      });
    } catch (e) {
      print("Exception in addCallIntakeFormData:-" + e.toString());
    }
  }

  getFormIntakeData() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.getIntakedata().then((result) {
            if (jsonDecode(result)['status'].toString() == "200") {
              freedefaultTime = jsonDecode(result)['default_time'];
              // intakeData = IntakeModel.fromJson(jsonDecode(result['recordList']));
              intakeData = List<IntakeModel>.from(jsonDecode(result)['recordList'].map((x) => IntakeModel.fromJson(x)));
              if (intakeData.isNotEmpty) {
                nameController.text = intakeData[0].name ?? "";
                phoneController.text = intakeData[0].phoneNumber ?? "";
                gender = intakeData[0].gender ?? "male";
                dobController.text = DateConverter.isoStringToLocalDateOnly(intakeData[0].birthDate!.toIso8601String());
                birthTimeController.text = intakeData[0].birthTime ?? "";
                placeController.text = intakeData[0].birthPlace ?? "";
                intakeData[0].latitude == null || intakeData[0].latitude == "null" ? null : lat = intakeData[0].latitude;
                intakeData[0].longitude == null || intakeData[0].longitude == "null" ? null : long = intakeData[0].longitude;
                intakeData[0].timezone == null || intakeData[0].timezone == "null" ? null : tzone = intakeData[0].timezone;

                print("latitute and long");
                print("${lat}");
                print("${long}");
                print("${tzone}");
                countryCode = intakeData[0].countryCode ?? "+91";

                ocupationController.text = intakeData[0].occupation ?? "";
                partnerNameController.text = intakeData[0].partnerName ?? "";
                partnerBirthController.text = intakeData[0].partnerBirthTime ?? "";
                partnerDobController.text = intakeData[0].partnerBirthDate == null ? "" : DateConverter.isoStringToLocalDateOnly(intakeData[0].partnerBirthDate!.toIso8601String());
                partnerPlaceController.text = intakeData[0].partnerBirthPlace ?? "";
              }
              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(message: 'Fail to get get Intake data', textColor: global.textColor, bgColor: global.toastBackGoundColor);
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in getKundliList():' + e.toString());
    }
  }

  // verifyOTP() async {
  //
  //   await FirebaseAuth.instance.verifyPhoneNumber(
  //     phoneNumber: '${'+91' + phoneController.text}',
  //     verificationCompleted: (PhoneAuthCredential credential) {},
  //     verificationFailed: (FirebaseAuthException e) {
  //       global.hideLoader();
  //       print('verification failed intakeController verifyOTP ${e.toString()}');
  //     },
  //     codeSent: (String verificationId, int? resendToken) {
  //       global.hideLoader();
  //
  //       timer();
  //       Get.to(() => IntakeVerifyOTPScreen(
  //             phoneNumber: phoneController.text,
  //             verificationId: verificationId,
  //           ));
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //   );
  // }

  var maxSecond;
  Timer? time;
  Timer? time2;
  double second = 0;
  timer() {
    maxSecond = 60;
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time!.cancel();
      }
    });
    time2 = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (second < 0.9) {
        second = second + 0.02;
        update();
      } else {
        //second = 1.0;
        time2!.cancel();
        update();
      }
    });
  }

  checkFreeSessionAvailable() async {
    try {
      await global.checkBody().then((result) async {
        if (result) {
          await apiHelper.checkFreeSession().then((result) {
            if (result.status == "200") {
              isAddNewRequestByFreeuser = result.recordList ?? false;
              update();
            } else {
              if (global.currentUserId != null) {
                global.showToast(message: 'Free session not granted!', textColor: global.textColor, bgColor: global.toastBackGoundColor);
              }
            }
          });
        }
      });
    } catch (e) {
      print('Exception in checkFreeSessionAvailable():' + e.toString());
    }
  }
}
