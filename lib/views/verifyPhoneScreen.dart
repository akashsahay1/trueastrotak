// ignore_for_file: deprecated_member_use, must_be_immutable

import 'dart:io';
import 'package:trueastrotalk/controllers/loginController.dart';
import 'package:trueastrotalk/controllers/signupController.dart';
import 'package:trueastrotalk/views/loginScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class VerifyPhoneScreen extends StatelessWidget {
  final String phoneNumber;
  final bool isFromSignup;
  final SignupController? signupController;
  
  VerifyPhoneScreen({
    Key? key, 
    required this.phoneNumber,
    this.isFromSignup = false,
    this.signupController,
  }) : super(key: key);
  
  final pinEditingControllerlogin = TextEditingController(text: '');
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!isFromSignup) {
          final loginController = Get.find<LoginController>();
          loginController.maxSecond = 61;
          loginController.time!.cancel();
          loginController.update();
        }
        Get.offAll(() => LoginScreen());
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Color.fromARGB(255, 245, 235, 235),
          title: Text('Verify Phone', style: Get.textTheme.titleMedium).tr(),
          leading: IconButton(
            onPressed: () {
              if (!isFromSignup) {
                Get.delete<LoginController>(force: true);
              }
              Get.off(() => LoginScreen());
            },
            icon: Icon(
              kIsWeb
                  ? Icons.arrow_back
                  : Platform.isIOS
                  ? Icons.arrow_back_ios
                  : Icons.arrow_back,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Color.fromARGB(255, 245, 235, 235),
        body: Center(
          child: SizedBox(
            width: Get.width - Get.width * 0.1,
            child: Column(
              children: [
                SizedBox(height: 5.h),
                Text('OTP Send to ${isFromSignup ? signupController?.selectedCountryCode : Get.find<LoginController>().selectedCountryCode}-$phoneNumber', style: TextStyle(color: Colors.green)).tr(),
                SizedBox(height: 30),
                PinInputTextField(
                  pinLength: 6,
                  decoration: BoxLooseDecoration(strokeColorBuilder: PinListenColorBuilder(Colors.grey.shade400, Colors.grey.shade400)),
                  controller: pinEditingControllerlogin,
                  textInputAction: TextInputAction.done,
                  enabled: true,
                  keyboardType: TextInputType.number,
                  onSubmit: (pin) {
                    if (isFromSignup && signupController != null) {
                      // For signup flow, we don't need to update smsCode in loginController
                    } else {
                      final controller = Get.find<LoginController>();
                      controller.smsCode = pin;
                      controller.update();
                    }
                  },
                  onChanged: (pin) {
                    if (isFromSignup && signupController != null) {
                      // For signup flow, we don't need to update smsCode in loginController
                    } else {
                      final controller = Get.find<LoginController>();
                      controller.smsCode = pin;
                      controller.update();
                    }
                  },
                  enableInteractiveSelection: false,
                ),
                SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: isFromSignup && signupController != null
                      ? ElevatedButton(
                        onPressed: () async {
                          if (pinEditingControllerlogin.text.length != 6) {
                            global.showToast(message: "All field required", textColor: Colors.white, bgColor: Colors.red);
                            return;
                          }

                          final controller = isFromSignup ? null : Get.find<LoginController>();
                          if (!isFromSignup && controller!.maxSecond <= 0) {
                            global.showToast(message: "OTP expired. Please resend OTP.", textColor: Colors.white, bgColor: Colors.red);
                            return;
                          }
                          
                          try {
                            if (pinEditingControllerlogin.text.isEmpty) {
                              global.showToast(message: 'Enter Otp First', textColor: Colors.white, bgColor: Colors.black);
                            } else {
                              global.showOnlyLoaderDialog(context);
                              
                              if (isFromSignup && signupController != null) {
                                // Signup flow
                                await signupController!.verifyPhoneOTP(pinEditingControllerlogin.text);
                              } else {
                                // Login flow
                                final loginController = Get.find<LoginController>();
                                loginController.smsCode = pinEditingControllerlogin.text;
                                loginController.verifyOTP(loginController.smsCode);
                              }
                            }
                          } catch (e) {
                            global.hideLoader();
                            global.showToast(message: "OTP INVALID", textColor: Colors.white, bgColor: Colors.red);
                            print("Exception " + e.toString());
                          }
                        },
                        child: Text('SUBMIT', style: TextStyle(color: Colors.white)).tr(),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                          padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                          backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
                          textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                      )
                      : GetBuilder<LoginController>(
                          builder: (loginController) {
                            return ElevatedButton(
                              onPressed: () async {
                                if (pinEditingControllerlogin.text.length != 6) {
                                  global.showToast(message: "All field required", textColor: Colors.white, bgColor: Colors.red);
                                  return;
                                }

                                final controller = Get.find<LoginController>();
                                if (controller.maxSecond <= 0) {
                                  global.showToast(message: "OTP expired. Please resend OTP.", textColor: Colors.white, bgColor: Colors.red);
                                  return;
                                }
                                
                                try {
                                  if (pinEditingControllerlogin.text.isEmpty) {
                                    global.showToast(message: 'Enter Otp First', textColor: Colors.white, bgColor: Colors.black);
                                  } else {
                                    global.showOnlyLoaderDialog(context);
                                    
                                    // Login flow
                                    final loginController = Get.find<LoginController>();
                                    loginController.smsCode = pinEditingControllerlogin.text;
                                    loginController.verifyOTP(loginController.smsCode);
                                  }
                                } catch (e) {
                                  global.hideLoader();
                                  global.showToast(message: "OTP INVALID", textColor: Colors.white, bgColor: Colors.red);
                                  print("Exception " + e.toString());
                                }
                              },
                              child: Text('SUBMIT', style: TextStyle(color: Colors.white)).tr(),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                padding: MaterialStateProperty.all(EdgeInsets.all(12)),
                                backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
                                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 18, color: Colors.black)),
                              ),
                            );
                          },
                        ),
                ),
                SizedBox(height: 15),
                if (!isFromSignup)
                  GetBuilder<LoginController>(
                    builder: (c) {
                      return SizedBox(
                        child:
                            c.maxSecond != 0
                                ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: kIsWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
                                  children: [SizedBox(width: 15), Text('Resend OTP Available in ${c.maxSecond} s', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)).tr()],
                                )
                                : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: kIsWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                                  children: [
                                    Text('Resend OTP Available', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)).tr(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            c.maxSecond = 60;
                                            pinEditingControllerlogin.text = '';
                                            c.update();
                                            c.timer();
                                            c.phoneController.text = phoneNumber;
                                            global.showOnlyLoaderDialog(context);
                                            c.sendPhoneOTP(resendOtp: true);
                                          },
                                          child: Text('Resend OTP on SMS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)).tr(),
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                            padding: MaterialStateProperty.all(EdgeInsets.only(left: 25, right: 25)),
                                            backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
                                            textStyle: MaterialStateProperty.all(TextStyle(fontSize: 12, color: Colors.black)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                      );
                    },
                  ),
                if (isFromSignup)
                  SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: kIsWeb ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                      children: [
                        Text('Resend OTP Available', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500)).tr(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                pinEditingControllerlogin.text = '';
                                global.showOnlyLoaderDialog(context);
                                signupController?.sendPhoneOTP();
                              },
                              child: Text('Resend OTP on SMS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)).tr(),
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                padding: MaterialStateProperty.all(EdgeInsets.only(left: 25, right: 25)),
                                backgroundColor: MaterialStateProperty.all(Get.theme.primaryColor),
                                textStyle: MaterialStateProperty.all(TextStyle(fontSize: 12, color: Colors.black)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
