import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:trueastrotalk/controllers/homeController.dart';
import 'package:trueastrotalk/model/login_model.dart';
import 'package:trueastrotalk/model/device_info_login_model.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:trueastrotalk/views/bottomNavigationBarScreen.dart';
import 'package:trueastrotalk/views/verifyPhoneScreen.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

class SignupController extends GetxController {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  
  SplashController splashController = Get.find<SplashController>();
  APIHelper apiHelper = APIHelper();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';
  String selectedCountryCode = "+91";
  
  bool isPasswordVisible = false;
  bool acceptTerms = false;
  bool countryvalidator = false;

  @override
  void onInit() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  void toggleAcceptTerms() {
    acceptTerms = !acceptTerms;
    update();
  }

  void updateCountryCode(String? value) {
    selectedCountryCode = value.toString();
    print('countryCode -> $selectedCountryCode');
    update();
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool validateForm() {
    if (firstNameController.text.trim().isEmpty) {
      global.showToast(
        message: "Please enter your first name",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      global.showToast(
        message: "Please enter your last name",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      global.showToast(
        message: "Please enter your email address",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (!isValidEmail(emailController.text.trim())) {
      global.showToast(
        message: "Please enter a valid email address",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (passwordController.text.trim().isEmpty) {
      global.showToast(
        message: "Please enter a password",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (passwordController.text.trim().length < 6) {
      global.showToast(
        message: "Password must be at least 6 characters",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      global.showToast(
        message: "Please enter your phone number",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (!countryvalidator) {
      global.showToast(
        message: "Please enter a valid phone number",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    if (!acceptTerms) {
      global.showToast(
        message: "Please accept the Terms & Conditions",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
      return false;
    }

    return true;
  }

  Future<void> signUp() async {
    if (!validateForm()) return;

    try {
      global.showOnlyLoaderDialog(Get.context);

      // Create Firebase account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(
          '${firstNameController.text.trim()} ${lastNameController.text.trim()}'
        );

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Send phone OTP for verification
        await sendPhoneOTP();
      }
    } on FirebaseAuthException catch (e) {
      global.hideLoader();
      String message = "Signup failed";

      switch (e.code) {
        case 'weak-password':
          message = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          message = "An account already exists for this email.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'operation-not-allowed':
          message = "Email/password accounts are not enabled.";
          break;
      }

      global.showToast(
        message: message,
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    } catch (e) {
      global.hideLoader();
      print("Signup error: $e");
      global.showToast(
        message: "Signup failed. Please try again.",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  Future<void> sendPhoneOTP() async {
    try {
      String phoneNumber = selectedCountryCode + phoneController.text.trim();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _auth.currentUser?.linkWithCredential(credential);
          global.hideLoader();
          await createUserAccount();
        },
        verificationFailed: (FirebaseAuthException e) {
          global.hideLoader();
          print("Phone verification failed: ${e.message}");
          global.showToast(
            message: "Phone verification failed: ${e.message}",
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          global.hideLoader();
          Get.to(() => VerifyPhoneScreen(
            phoneNumber: phoneController.text.trim(),
            isFromSignup: true,
            signupController: this,
          ));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      global.hideLoader();
      print("Error sending OTP: $e");
      global.showToast(
        message: "Error sending OTP. Please try again.",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  Future<void> verifyPhoneOTP(String otp) async {
    try {
      global.showOnlyLoaderDialog(Get.context);
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      // Link phone credential to existing email account
      await _auth.currentUser?.linkWithCredential(credential);
      
      global.hideLoader();
      await createUserAccount();
    } catch (e) {
      global.hideLoader();
      print("OTP verification error: $e");
      global.showToast(
        message: "Invalid OTP. Please try again.",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }

  Future<void> createUserAccount() async {
    try {
      global.showOnlyLoaderDialog(Get.context);
      
      await global.getDeviceData();
      
      // Create user data for API
      LoginModel loginModel = LoginModel();
      loginModel.email = emailController.text.trim();
      loginModel.contactNo = phoneController.text.trim();
      loginModel.countryCode = selectedCountryCode;
      loginModel.firstName = firstNameController.text.trim();
      loginModel.lastName = lastNameController.text.trim();
      loginModel.password = passwordController.text.trim(); // Add password to model
      
      loginModel.deviceInfo = DeviceInfoLoginModel();
      loginModel.deviceInfo?.appId = global.appId;
      loginModel.deviceInfo?.appVersion = global.appVersion;
      loginModel.deviceInfo?.deviceId = global.deviceId;
      loginModel.deviceInfo?.deviceLocation = global.deviceLocation ?? "";
      loginModel.deviceInfo?.deviceManufacturer = global.deviceManufacturer;
      loginModel.deviceInfo?.deviceModel = global.deviceManufacturer;
      loginModel.deviceInfo?.fcmToken = global.fcmToken;

      await apiHelper.signupUser(loginModel).then((result) async {
        if (result.status == "200") {
          var recordId = result.recordList["recordList"];
          var token = result.recordList["token"];
          var tokenType = result.recordList["token_type"];
          
          await global.saveCurrentUser(int.parse(recordId["id"]), token, tokenType);
          await splashController.getCurrentUserData();
          await global.getCurrentUser();
          
          final homeController = Get.find<HomeController>();
          homeController.myOrders.clear();
          
          global.hideLoader();
          
          global.showToast(
            message: "Account created successfully!",
            textColor: Colors.white,
            bgColor: Colors.green,
          );
          
          Get.offAll(() => BottomNavigationBarScreen(index: 0));
        } else {
          global.hideLoader();
          global.showToast(
            message: result.recordList["msg"] ?? "Signup failed",
            textColor: global.textColor,
            bgColor: global.toastBackGoundColor,
          );
        }
      });
    } catch (e) {
      global.hideLoader();
      print("Error creating user account: $e");
      global.showToast(
        message: "Failed to create account. Please try again.",
        textColor: global.textColor,
        bgColor: global.toastBackGoundColor,
      );
    }
  }
}