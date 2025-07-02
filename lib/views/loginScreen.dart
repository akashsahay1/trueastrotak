import 'dart:developer';

import 'package:trueastrotalk/controllers/homeController.dart';
import 'package:trueastrotalk/controllers/loginController.dart';
import 'package:trueastrotalk/utils/images.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'signupScreen.dart';

String privacyUrl = "https://www.trueastrotalk.com/privacy-and-policy";
String termsconditionUrl = "https://www.trueastrotalk.com/terms-and-condition";
String refundpolicy = 'https://www.trueastrotalk.com/refundPolicy';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final homeController = Get.find<HomeController>();
  final _initialPhone = PhoneNumber(isoCode: "IN");
  late TabController _tabController;

  late String? codeVerifier;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Background decorations
              Positioned(top: -50, right: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(75)))),
              Positioned(bottom: -50, left: -50, child: Container(width: 150, height: 150, decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(75)))),
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),

                      // Back button
                      Align(alignment: Alignment.topLeft, child: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_ios, color: Colors.black87), padding: EdgeInsets.zero)),

                      SizedBox(height: 2.h),

                      // Logo (120px)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(60), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: ClipRRect(borderRadius: BorderRadius.circular(60), child: Image.asset("assets/images/splash.png", fit: BoxFit.cover)),
                      ),
                      SizedBox(height: 4.h),

                      // Welcome text (single line)
                      FittedBox(fit: BoxFit.scaleDown, child: Text('Welcome Back!', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 1)),
                      SizedBox(height: 2.h),
                      Text('Sign in to your account', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
                      SizedBox(height: 4.h),

                      // Tab bar (icons only)
                      Container(
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.grey[600],
                          dividerColor: Colors.transparent,
                          tabs: [Tab(icon: Icon(Icons.phone, size: 24)), Tab(icon: Icon(Icons.mail_outline, size: 24))],
                        ),
                      ),
                      SizedBox(height: 3.h),

                      // Tab content
                      SizedBox(height: 40.h, child: TabBarView(controller: _tabController, children: [_buildPhoneTab(theme, colorScheme), _buildEmailTab(theme, colorScheme)])),

                      // Terms and Privacy
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text('By signing in, you agree to our ', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])).tr(),
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(termsconditionUrl));
                            },
                            child: Text('Terms of use', style: theme.textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline, color: colorScheme.primary)).tr(),
                          ),
                          Text(' and ', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])).tr(),
                          InkWell(
                            onTap: () {
                              launchUrl(Uri.parse(privacyUrl));
                            },
                            child: Text('Privacy Policy', style: theme.textTheme.bodySmall?.copyWith(decoration: TextDecoration.underline, color: colorScheme.primary)).tr(),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Sign up link
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Get.off(() => SignupScreen());
                          },
                          child: RichText(
                            text: TextSpan(text: "Don't have an account? ", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), children: [TextSpan(text: 'Sign Up', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600))]),
                          ),
                        ),
                      ),

                      // Feature highlights
                      Card(
                        elevation: 1,
                        margin: EdgeInsets.symmetric(horizontal: 2.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: EdgeInsets.all(4.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _buildFeatureColumn(context, Images.confidential, 'Private &\nConfidential', theme, colorScheme)),
                              Expanded(child: _buildFeatureColumn(context, Images.verifiedAccount, 'Verified\nAstrologer', theme, colorScheme)),
                              Expanded(child: _buildFeatureColumn(context, Images.payment, 'Secure\nPayments', theme, colorScheme)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTab(ThemeData theme, ColorScheme colorScheme) {
    return GetBuilder<LoginController>(
      builder: (loginController) {
        return Column(
          children: [
            // Phone input
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                child: Theme(
                  data: theme.copyWith(
                    dialogTheme: DialogThemeData(contentTextStyle: TextStyle(color: Colors.black87), backgroundColor: Colors.white),
                    inputDecorationTheme: InputDecorationTheme(fillColor: Colors.white, filled: true, border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none),
                  ),
                  child: InternationalPhoneNumberInput(
                    textFieldController: loginController.phoneController,
                    inputDecoration: InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, fillColor: Colors.white, filled: true, hintText: 'Phone number', hintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[500])),
                    onInputValidated: (bool value) {
                      loginController.countryvalidator = value;
                      loginController.update();
                      print("Number valid? ${loginController.countryvalidator}");
                    },
                    selectorConfig: const SelectorConfig(leadingPadding: 2, selectorType: PhoneInputSelectorType.BOTTOM_SHEET),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(color: Colors.black87),
                    searchBoxDecoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)), hintText: "Search", hintStyle: TextStyle(color: Colors.grey[500])),
                    initialValue: _initialPhone,
                    formatInput: false,
                    keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: false),
                    inputBorder: InputBorder.none,
                    onSaved: (PhoneNumber number) {
                      log('On Saved: ${number.dialCode}');
                      loginController.updateCountryCode(number.dialCode);
                    },
                    onFieldSubmitted: (value) {
                      log('On onFieldSubmitted: $value');
                      FocusScope.of(context).unfocus();
                    },
                    onInputChanged: (PhoneNumber number) {
                      log('On onInputChanged: ${number.dialCode}');
                      log('On onInputChanged: ${number.phoneNumber}');
                      loginController.updateCountryCode(number.dialCode);
                    },
                    onSubmit: () {
                      log('On onSubmit:');
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            // Send OTP Button
            Container(
              width: double.infinity,
              height: 7.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Check if user exists before sending OTP
                  await loginController.checkUserExistsAndSendOTP();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Login', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)).tr(), SizedBox(width: 2.w), Icon(Icons.arrow_forward, color: Colors.white, size: 20)]),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmailTab(ThemeData theme, ColorScheme colorScheme) {
    return GetBuilder<LoginController>(
      builder: (loginController) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 2.h),
              // Google Sign-in button
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
                child: ElevatedButton(
                  onPressed: () {
                    global.showOnlyLoaderDialog(context);
                    loginController.signInWithGoogle();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Image.asset("assets/images/gmail.png", height: 3.h, width: 3.h, fit: BoxFit.contain), SizedBox(width: 3.w), Text('Continue with Google', style: theme.textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500))],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Divider with "OR"
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 3.w), child: Text('OR', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600], fontWeight: FontWeight.w500))),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              SizedBox(height: 2.h),
              // Email input
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
                child: TextField(
                  controller: loginController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Email address',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[500]),
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Password input
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(12), color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))]),
                child: TextField(
                  controller: loginController.passwordController,
                  obscureText: !loginController.isPasswordVisible,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    fillColor: Colors.white,
                    filled: true,
                    hintText: 'Password',
                    hintStyle: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
                    suffixIcon: IconButton(
                      icon: Icon(loginController.isPasswordVisible ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
                      onPressed: () {
                        loginController.togglePasswordVisibility();
                      },
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              // Login Button
              Container(
                width: double.infinity,
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    await loginController.signInWithEmail();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text('Login', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureColumn(BuildContext context, String imagePath, String title, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(height: 8.h, width: 8.h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: colorScheme.surfaceContainerHighest), child: Padding(padding: EdgeInsets.all(2.w), child: Image.asset(imagePath, fit: BoxFit.contain))),
        SizedBox(height: 1.h),
        Text(title, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w500)).tr(),
      ],
    );
  }
}
