// ignore_for_file: must_be_immutable

import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/life_cycle_controller.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);
  final splashController = Get.put(SplashController());
  final homeCheckController = Get.put(HomeCheckController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive sizing based on screen dimensions
            final screenHeight = constraints.maxHeight;
            final screenWidth = constraints.maxWidth;
            final isTablet = screenWidth > 600;
            final logoSize = isTablet ? 80.0 : 60.0;
            
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 400 : screenWidth * 0.8,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Material 3 styled logo container
                    Container(
                      width: logoSize * 2,
                      height: logoSize * 2,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/splash.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.star,
                              size: logoSize,
                              color: colorScheme.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // App name with Material 3 typography and loading state
                    GetBuilder<SplashController>(
                      builder: (s) {
                        if (splashController.appName.isEmpty) {
                          return Column(
                            children: [
                              // Material 3 loading indicator
                              SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: colorScheme.primary,
                                  backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.02),
                              Text(
                                'Loading...',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          );
                        }
                        
                        return Column(
                          children: [
                            Text(
                              splashController.appName,
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'Welcome',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
