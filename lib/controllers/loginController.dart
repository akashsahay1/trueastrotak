import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:trueastrotalk/controllers/homeController.dart';
import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:trueastrotalk/main.dart';
import 'package:trueastrotalk/model/login_model.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:trueastrotalk/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:otpless_headless_flutter/otpless_flutter.dart';
import '../model/device_info_login_model.dart';
import '../utils/global.dart';
import '../views/bottomNavigationBarScreen.dart';
import '../views/verifyPhoneScreen.dart';
import 'package:trueastrotalk/utils/global.dart' as global;
import 'package:http/http.dart' as http;

class LoginController extends GetxController {
  late TextEditingController phoneController;
  SplashController splashController = Get.find<SplashController>();
  String validationId = "";
  double second = 0;
  var maxSecond;
  // String countryCode = "+91";
  Timer? time;
  Timer? time2;
  String smsCode = "";
  //String verificationId = "";
  String? errorText;
  APIHelper apiHelper = APIHelper();
  String selectedCountryCode = "+91";
  var flag = '🇮🇳';

  final otplessFlutterPlugin = Otpless();
  var loaderVisibility = true;
  final TextEditingController urlTextContoller = TextEditingController();
  Map dataResponse = {};
  String phoneOrEmail = '';
  String otp = '';
  bool isInitIos = false;
  static const String appId = "V2IXF52ONF0OEP8EY64M";

  @override
  void onInit() {
    phoneController = TextEditingController();
    super.onInit();
  }

  void onHeadlessResultVerify(dynamic result) async {
    dataResponse = result;
    log("all response:-  ${dataResponse}");
    if (dataResponse['statusCode'].toString() == "200") {
      // print("phone no ${int.parse(phoneController.text)}");//errrorrrrr
      await loginAndSignupUser(
        int.parse(phoneController.text),
        // int.parse(data['authentication_details']['phone']['phone_number']
        //     .toString()),
        "",
      );
    } else {
      Fluttertoast.showToast(msg: "Invalid Otp");
      hideLoader();
    }
  }

  Future<void> startHeadlessWithWhatsapp(String type, {bool? resendOtp = false}) async {
    if (Platform.isAndroid) {
      otplessFlutterPlugin.initialize(appId, timeout: 23);
      otplessFlutterPlugin.setResponseCallback(onHeadlessResult);
      debugPrint("init headless sdk is called for android");
    }
    if (Platform.isIOS && !isInitIos) {
      otplessFlutterPlugin.initialize(appId, timeout: 23);
      otplessFlutterPlugin.setResponseCallback(onHeadlessResult);
      isInitIos = true;
      debugPrint("init headless sdk is called for ios");
    }
    Map<String, dynamic> arg = type == "phone" ? {'phone': '${phoneController.text}', 'countryCode': selectedCountryCode} : {'channelType': "$type"};

    print(arg);
    print("resend otp:- ${resendOtp}");
    type == "phone" ? otplessFlutterPlugin.start(resendOtp == true ? onResendotp : onHeadlessResultPhone, arg) : otplessFlutterPlugin.start(onHeadlessResult, arg);
  }

  void onHeadlessResult(dynamic result) async {
    print("email data");
    dataResponse = result;
    print("${dataResponse}");
    final responseType = result['responseType'];
    print("${responseType}");
    otplessFlutterPlugin.commitResponse(result);

    final responseTyp = result['responseType'];

    switch (responseTyp) {
      case "SDK_READY":
        debugPrint("SDK is ready");

        break;

      case "FAILED":
        debugPrint("SDK initialization failed");
        // Handle SDK initialization failure
        break;

      case "INITIATE":
        if (result["statusCode"] == 200) {
          debugPrint("Headless authentication initiated");
          final authType = result["response"]["authType"];
          if (authType == "OTP") {
            // Take user to OTP verification screen
          } else if (authType == "SILENT_AUTH") {
            // Handle Silent Authentication initiation by showing
            // loading status for SNA flow.
          }
        } else {
          debugPrint("Failed to initiate authentication: ${result["statusCode"]}");
          // Handle failure to initiate authentication
          if (result["statusCode"] == 9106) {
            // Silent Authentication failed and all fallback methods have been exhausted.
            // Handle the scenario to gracefully exit the authentication flow
          } else {
            // Handle other error codes
          }
        }
        break;

      case "OTP_AUTO_READ":
        // OTP_AUTO_READ is triggered only in ANDROID devices for WhatsApp and SMS.
        final otp = result["response"]["otp"];
        debugPrint("OTP Received: $otp");
        break;

      case "VERIFY":
        final authType = result["response"]["authType"];
        if (authType == "SILENT_AUTH") {
          if (result["statusCode"] == 9106) {
            // Silent Authentication and all fallback authentication methods in SmartAuth have failed.
            //  The transaction cannot proceed further.
            // Handle the scenario to gracefully exit the authentication flow
          } else {
            // Silent Authentication failed.
            // If SmartAuth is enabled, the INITIATE response
            // will include the next available authentication method configured in the dashboard.
          }
        } else {
          // This is the response for OTP or Magic Link verification.
          // The response will contain the authentication details.
          // You can use this to log in or sign up the user.
          debugPrint("Verification successful: ${result["response"]}");
        }
        break;

      case "DELIVERY_STATUS":
        break;

      case "ONETAP":
        final token = result["response"]["token"];
        if (token != null) {
          debugPrint("OneTap Data: $token");
          // Process token and proceed
        }
        break;

      case "FALLBACK_TRIGGERED":
        // A fallback occurs when an OTP delivery attempt on one channel fails,
        // and the system automatically retries via the subsequent channel selected on Otpless Dashboard.
        // For example, if a merchant opts for SmartAuth with primary channal as WhatsApp and secondary channel as SMS,
        // in that case, if OTP delivery on WhatsApp fails, the system will automatically retry via SMS.
        // The response will contain the deliveryChannel to which the OTP has been sent.
        final newDeliveryChannel = result["response"]["deliveryChannel"];
        if (newDeliveryChannel != null) {
          // This is the deliveryChannel to which the OTP has been sent
        }
        break;

      default:
        debugPrint("Unknown response type: $responseType");
        break;
    }

    if (dataResponse['response']['status'].toString() == "SUCCESS") {
      if (dataResponse['response']['identities'][0]['identityType'].toString() == "EMAIL") {
        await loginAndSignupUser(null, dataResponse['response']['identities'][0]['identityValue'].toString());
      } else {
        final response = await http.post(Uri.parse('$baseUrl/getOtlResponse'), body: json.encode({"token": dataResponse['response']['token']}), headers: await global.getApiHeaders(false));
        print("Response from getOtlResponse: ${response.body}");
        Map data = json.decode(response.body);
        if (response.statusCode == 200) {
          await loginAndSignupUser(int.parse(data['authentication_details']['phone']['phone_number'].toString()), "");
        }
      }
    } else {
      //hideLoader();
    }
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  void onResendotp(dynamic result) {
    log(" result is1 ${dataResponse}");
    dataResponse = result;
    log(" result is ${dataResponse}");
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  void onHeadlessResultPhone(dynamic result) {
    log(" result is1 ${dataResponse}");
    dataResponse = result;
    log(" result is ${dataResponse}");
    hideLoader();
    if (dataResponse['statusCode'] == 200) {
      timer();
      Get.to(() => VerifyPhoneScreen(phoneNumber: phoneController.text));
    }
    // whatsapplogindetailsModelFromJson(dataResponse);
  }

  timer() {
    maxSecond = 60;
    update();
    print("maxSecond:- ${maxSecond}");
    time = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (maxSecond > 0) {
        maxSecond--;
        update();
      } else {
        time!.cancel();
      }
    });
  }

  updateCountryCode(value) {
    selectedCountryCode = value.toString();
    print('countryCode -> $selectedCountryCode');
    update();
  }

  bool countryvalidator = false;

  bool validedPhone() {
    return countryvalidator;
  }

  loginAndSignupUser(int? phoneNumber, String email) async {
    try {
      print("Trying login Akash with gmail");
      await global.getDeviceData();
      LoginModel loginModel = LoginModel();
      email.toString() != "" ? loginModel.contactNo = null : loginModel.contactNo = phoneNumber.toString();
      email.toString() == "" ? null : loginModel.email = email.toString();
      loginModel.countryCode = selectedCountryCode.toString();
      loginModel.deviceInfo = DeviceInfoLoginModel();
      loginModel.deviceInfo?.appId = global.appId;
      loginModel.deviceInfo?.appVersion = global.appVersion;
      loginModel.deviceInfo?.deviceId = global.deviceId;
      loginModel.deviceInfo?.deviceLocation = global.deviceLocation ?? "";
      loginModel.deviceInfo?.deviceManufacturer = global.deviceManufacturer;
      loginModel.deviceInfo?.deviceModel = global.deviceManufacturer;
      loginModel.deviceInfo?.fcmToken = global.fcmToken;
      loginModel.deviceInfo?.appVersion = global.appVersion;

      await apiHelper.loginSignUp(loginModel).then((result) async {
        print("Checkin results of login Akash with gmail");
        print(result.status);
        if (result.status == "200") {
          var recordId = result.recordList["recordList"];
          var token = result.recordList["token"];
          var tokenType = result.recordList["token_type"];
          await global.saveCurrentUser(recordId["id"], token, tokenType);
          await splashController.getCurrentUserData();
          await global.getCurrentUser();
          // global.hideLoader();
          final homeController = Get.find<HomeController>();
          homeController.myOrders.clear();
          time?.cancel();
          update();

          bottomController.setIndex(0, 0);
          Get.off(() => BottomNavigationBarScreen(index: 0));
        } else {
          global.hideLoader();
          Get.off(() => LoginScreen());
        }
      });
    } catch (e) {
      global.hideLoader();
      print("Exception in loginAndSignupUser():-" + e.toString());
    }
  }
}
