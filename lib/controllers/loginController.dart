import 'dart:async';
import 'package:trueastrotalk/controllers/homeController.dart';
import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:trueastrotalk/main.dart';
import 'package:trueastrotalk/model/login_model.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:trueastrotalk/views/loginScreen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../model/device_info_login_model.dart';
import '../utils/global.dart';
import '../views/bottomNavigationBarScreen.dart';
import '../views/verifyPhoneScreen.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

class LoginController extends GetxController {
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _verificationId = '';
  var loaderVisibility = true;

  // Email/Password authentication properties
  bool isPasswordVisible = false;
  bool isSignInMode = false; // false = sign up, true = sign in

  @override
  void onInit() {
    phoneController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.onInit();
  }

  void verifyOTP(String otp) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: otp);

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        await loginAndSignupUser(int.parse(phoneController.text), "", oauthType: "phone");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP");
      hideLoader();
      print("OTP verification error: $e");
    }
  }

  Future<void> sendPhoneOTP({bool resendOtp = false}) async {
    try {
      String phoneNumber = selectedCountryCode + phoneController.text;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          UserCredential userCredential = await _auth.signInWithCredential(credential);
          if (userCredential.user != null) {
            hideLoader();
            await loginAndSignupUser(int.parse(phoneController.text), "", oauthType: "phone");
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          hideLoader();
          print("Phone verification failed: ${e.message}");
          Fluttertoast.showToast(msg: "Phone verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          hideLoader();
          if (!resendOtp) {
            timer();
            Get.to(() => VerifyPhoneScreen(phoneNumber: phoneController.text));
          } else {
            Fluttertoast.showToast(msg: "OTP resent to: ${phoneController.text}");
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          print("Auto retrieval timeout");
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      hideLoader();
      print("Error sending OTP: $e");
      Fluttertoast.showToast(msg: "Error sending OTP");
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        hideLoader();
        return; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        String email = userCredential.user!.email ?? "";
        await loginAndSignupUser(null, email, oauthType: "google");
      }
    } catch (e) {
      hideLoader();
      print("Google sign-in error: $e");
      Fluttertoast.showToast(msg: "Google sign-in failed");
    }
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

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    update();
  }

  // Toggle between sign in and sign up mode
  void toggleSignInMode() {
    isSignInMode = !isSignInMode;
    update();
  }

  // Validate email format
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if user exists before sending OTP for login
  Future<void> checkUserExistsAndSendOTP() async {
    if (!validedPhone()) {
      global.showToast(message: "Invalid Number", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    try {
      global.showOnlyLoaderDialog(Get.context);

      // Check if user exists
      final response = await apiHelper.checkContact(phoneController.text);
      if (response.statusCode == 200) {
        // User exists, send OTP
        await sendPhoneOTP();
      } else {
        global.hideLoader();
        global.showToast(message: "User not found. Please sign up first.", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      }
    } catch (e) {
      global.hideLoader();
      print("Error checking user: $e");
      global.showToast(message: "Error checking user. Please try again.", textColor: global.textColor, bgColor: global.toastBackGoundColor);
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail() async {
    if (emailController.text.trim().isEmpty) {
      global.showToast(message: "Please enter email address", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      global.showToast(message: "Please enter a valid email address", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      global.showToast(message: "Please enter password", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    try {
      global.showOnlyLoaderDialog(Get.context);

      // Sign in with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());

      if (userCredential.user != null) {
        await loginAndSignupUser(null, emailController.text.trim(), password: passwordController.text.trim(), oauthType: "email");
      }
    } on FirebaseAuthException catch (e) {
      global.hideLoader();
      String message = "Authentication failed";

      switch (e.code) {
        case 'user-not-found':
          message = "No user found for this email. Please sign up first.";
          break;
        case 'wrong-password':
          message = "Wrong password provided.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
        case 'user-disabled':
          message = "This user account has been disabled.";
          break;
      }

      global.showToast(message: message, textColor: global.textColor, bgColor: global.toastBackGoundColor);
    } catch (e) {
      global.hideLoader();
      print("Email sign-in error: $e");
      global.showToast(message: "Sign-in failed. Please try again.", textColor: global.textColor, bgColor: global.toastBackGoundColor);
    }
  }

  // Sign up with email and password (kept for compatibility)
  Future<void> signUpWithEmail() async {
    if (emailController.text.trim().isEmpty) {
      global.showToast(message: "Please enter email address", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    if (!isValidEmail(emailController.text.trim())) {
      global.showToast(message: "Please enter a valid email address", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      global.showToast(message: "Please enter password", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    if (passwordController.text.trim().length < 6) {
      global.showToast(message: "Password must be at least 6 characters", textColor: global.textColor, bgColor: global.toastBackGoundColor);
      return;
    }

    try {
      global.showOnlyLoaderDialog(Get.context);

      if (isSignInMode) {
        // Sign in with existing account
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());

        if (userCredential.user != null) {
          await loginAndSignupUser(null, emailController.text.trim(), password: passwordController.text.trim(), oauthType: "email");
        }
      } else {
        // Create new account
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: emailController.text.trim(), password: passwordController.text.trim());

        if (userCredential.user != null) {
          // Send email verification
          await userCredential.user!.sendEmailVerification();

          global.showToast(message: "Verification email sent. Please check your inbox.", textColor: Colors.white, bgColor: Colors.green);

          await loginAndSignupUser(null, emailController.text.trim(), password: passwordController.text.trim(), oauthType: "email");
        }
      }
    } on FirebaseAuthException catch (e) {
      global.hideLoader();
      String message = "Authentication failed";

      switch (e.code) {
        case 'weak-password':
          message = "The password provided is too weak.";
          break;
        case 'email-already-in-use':
          message = "An account already exists for this email.";
          break;
        case 'user-not-found':
          message = "No user found for this email.";
          break;
        case 'wrong-password':
          message = "Wrong password provided.";
          break;
        case 'invalid-email':
          message = "The email address is not valid.";
          break;
      }

      global.showToast(message: message, textColor: global.textColor, bgColor: global.toastBackGoundColor);
    } catch (e) {
      global.hideLoader();
      print("Email authentication error: $e");
      global.showToast(message: "Authentication failed. Please try again.", textColor: global.textColor, bgColor: global.toastBackGoundColor);
    }
  }

  loginAndSignupUser(int? phoneNumber, String email, {String? password, String? oauthType}) async {
    try {
      print("Trying login Akash with gmail");
      await global.getDeviceData();
      LoginModel loginModel = LoginModel();
      email.toString() != "" ? loginModel.contactNo = null : loginModel.contactNo = phoneNumber.toString();
      email.toString() == "" ? null : loginModel.email = email.toString();
      loginModel.countryCode = selectedCountryCode.toString();

      // Set password and oauthType based on the provided parameters
      loginModel.password = password;
      loginModel.oauthType = oauthType;
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
        print(result.status.runtimeType);
        if (result.status == "200") {
          print("Login successful with gmail");
          var recordId = result.recordList["recordList"];
          var token = result.recordList["token"];
          var tokenType = result.recordList["token_type"];
          await global.saveCurrentUser(int.parse(recordId["id"].toString()), token, tokenType);
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
      debugPrint("Exception in loginAndSignupUser():-" + e.toString());
    }
  }
}
