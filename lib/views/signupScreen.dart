import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:trueastrotalk/controllers/signupController.dart';
import 'loginScreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupController = Get.put(SignupController());
  final _initialPhone = PhoneNumber(isoCode: "IN");

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(75),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  
                  // Back button
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.black87,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  // Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/images/splash.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 3.h),
                  
                  // Title
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Create Your Account',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 1.h),
                  
                  Center(
                    child: Text(
                      'Join thousands of satisfied users',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  SizedBox(height: 4.h),
                  
                  GetBuilder<SignupController>(
                    builder: (controller) {
                      return Column(
                        children: [
                          // First Name
                          _buildInputField(
                            controller: controller.firstNameController,
                            hintText: 'First Name',
                            prefixIcon: Icons.person_outline,
                            theme: theme,
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Last Name
                          _buildInputField(
                            controller: controller.lastNameController,
                            hintText: 'Last Name',
                            prefixIcon: Icons.person_outline,
                            theme: theme,
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Email
                          _buildInputField(
                            controller: controller.emailController,
                            hintText: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            theme: theme,
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Password
                          _buildInputField(
                            controller: controller.passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: !controller.isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[500],
                              ),
                              onPressed: controller.togglePasswordVisibility,
                            ),
                            theme: theme,
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Phone Number
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                              child: Theme(
                                data: theme.copyWith(
                                  dialogTheme: DialogThemeData(
                                    contentTextStyle: TextStyle(color: Colors.black87),
                                    backgroundColor: Colors.white,
                                  ),
                                  inputDecorationTheme: InputDecorationTheme(
                                    fillColor: Colors.white,
                                    filled: true,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                  ),
                                ),
                                child: InternationalPhoneNumberInput(
                                  textFieldController: controller.phoneController,
                                  inputDecoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: 'Phone number',
                                    hintStyle: theme.textTheme.bodyLarge?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  onInputValidated: (bool value) {
                                    controller.countryvalidator = value;
                                    controller.update();
                                  },
                                  selectorConfig: const SelectorConfig(
                                    leadingPadding: 2,
                                    selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle: TextStyle(color: Colors.black87),
                                  searchBoxDecoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    hintText: "Search",
                                    hintStyle: TextStyle(color: Colors.grey[500]),
                                  ),
                                  initialValue: _initialPhone,
                                  formatInput: false,
                                  keyboardType: const TextInputType.numberWithOptions(
                                    signed: true,
                                    decimal: false,
                                  ),
                                  inputBorder: InputBorder.none,
                                  onInputChanged: (PhoneNumber number) {
                                    controller.updateCountryCode(number.dialCode);
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 3.h),
                          
                          // Terms and Conditions
                          Row(
                            children: [
                              Checkbox(
                                value: controller.acceptTerms,
                                onChanged: (value) {
                                  controller.toggleAcceptTerms();
                                },
                                activeColor: colorScheme.primary,
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      'I agree to the ',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launchUrl(Uri.parse(termsconditionUrl));
                                      },
                                      child: Text(
                                        'Terms & Conditions',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        launchUrl(Uri.parse(privacyUrl));
                                      },
                                      child: Text(
                                        'Privacy Policy',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: colorScheme.primary,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 3.h),
                          
                          // Signup Button
                          Container(
                            width: double.infinity,
                            height: 7.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                await controller.signUp();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 2.h),
                          
                          // Login link
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Get.off(() => LoginScreen());
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Login',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(height: 4.h),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required ThemeData theme,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey[500],
          ),
          prefixIcon: Icon(prefixIcon, color: Colors.grey[500]),
          suffixIcon: suffixIcon,
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        ),
      ),
    );
  }
}