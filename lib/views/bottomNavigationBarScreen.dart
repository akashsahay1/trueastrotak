// ignore_for_file: must_be_immutable, deprecated_member_use

import 'package:trueastrotalk/controllers/bottomNavigationController.dart';
import 'package:trueastrotalk/controllers/chatController.dart';
import 'package:trueastrotalk/controllers/history_controller.dart';
import 'package:trueastrotalk/controllers/homeController.dart';
import 'package:trueastrotalk/controllers/liveController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splashController.dart';
import '../utils/global.dart' as global;

class BottomNavigationBarScreen extends StatelessWidget {
  final int index;

  BottomNavigationBarScreen({this.index = 0}) : super();

  int? currentIndex;
  List<IconData> iconList = [Icons.home, Icons.chat, Icons.live_tv, Icons.call, Icons.edit_calendar_sharp];
  List<String> tabList = ['Home', 'Chat', 'Live', 'Call', 'History'];
  final homeController = Get.find<HomeController>();
  final historyController = Get.find<HistoryController>();
  final liveController = Get.find<LiveController>();
  final chatController = Get.find<ChatController>();
  final splashController = Get.find<SplashController>();
  final bottomNavigationController = Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GetBuilder<BottomNavigationController>(
        builder: (controller) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            bottomNavigationBar: GetBuilder<BottomNavigationController>(
              builder: (c) {
                return Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: NavigationBar(
                      backgroundColor: colorScheme.surface,
                      indicatorColor: colorScheme.secondaryContainer,
                      selectedIndex: bottomNavigationController.bottomNavIndex,
                      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                      height: kBottomNavigationBarHeight + 10,
                      destinations: _buildNavigationDestinations(context, colorScheme),
                      onDestinationSelected: (index) async {
                        await _handleNavigation(index, context);
                      },
                    ),
                  ),
                );
              },
            ),
            body: bottomNavigationController.screens().elementAt(bottomNavigationController.bottomNavIndex),
          );
        },
      ),
    );
  }
  
  List<NavigationDestination> _buildNavigationDestinations(BuildContext context, ColorScheme colorScheme) {
    return List.generate(iconList.length, (index) {
      _initializeShowFlags(index);
      
      switch (index) {
        case 0:
          return NavigationDestination(
            icon: Icon(iconList[index]),
            selectedIcon: Icon(iconList[index], color: colorScheme.onSecondaryContainer),
            label: tr(tabList[index]),
          );
        case 1:
          return NavigationDestination(
            icon: Icon(iconList[index]),
            selectedIcon: Icon(iconList[index], color: colorScheme.onSecondaryContainer),
            label: tr(tabList[index]),
          );
        case 2:
          return NavigationDestination(
            icon: _buildLiveIcon(false, colorScheme),
            selectedIcon: _buildLiveIcon(true, colorScheme),
            label: tr(tabList[index]),
          );
        case 3:
          return NavigationDestination(
            icon: const Icon(Icons.phone_in_talk_sharp),
            selectedIcon: Icon(Icons.phone_in_talk_sharp, color: colorScheme.onSecondaryContainer),
            label: tr(tabList[index]),
          );
        case 4:
          return NavigationDestination(
            icon: const Icon(Icons.history_sharp),
            selectedIcon: Icon(Icons.history_sharp, color: colorScheme.onSecondaryContainer),
            label: tr(tabList[index]),
          );
        default:
          return NavigationDestination(
            icon: Icon(iconList[index]),
            selectedIcon: Icon(iconList[index], color: colorScheme.onSecondaryContainer),
            label: tr(tabList[index]),
          );
      }
    });
  }
  
  Widget _buildLiveIcon(bool isSelected, ColorScheme colorScheme) {
    const double iconSize = 28.0;
    
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            "assets/images/live.gif",
            height: iconSize,
            width: iconSize,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    
    return ClipOval(
      child: Image.asset(
        "assets/images/live.gif",
        height: iconSize,
        width: iconSize,
        fit: BoxFit.cover,
      ),
    );
  }
  
  void _initializeShowFlags(int index) {
    switch (index) {
      case 0:
        if (bottomNavigationController.isValueShow == false) {
          bottomNavigationController.isValueShow = true;
        }
        break;
      case 1:
        if (bottomNavigationController.isValueShowChat == false) {
          bottomNavigationController.isValueShowChat = true;
        }
        break;
      case 2:
        if (bottomNavigationController.isValueShowLive == false) {
          bottomNavigationController.isValueShowLive = true;
        }
        break;
      case 3:
        if (bottomNavigationController.isValueShowCall == false) {
          bottomNavigationController.isValueShowCall = true;
        }
        break;
      case 4:
        if (bottomNavigationController.isValueShowHist == false) {
          bottomNavigationController.isValueShowHist = true;
        }
        break;
    }
  }
  
  Future<void> _handleNavigation(int index, BuildContext context) async {
    switch (index) {
      case 0:
        bottomNavigationController.setBottomIndex(index, bottomNavigationController.historyIndex);
        break;
      case 1:
      case 3:
        bottomNavigationController.setBottomIndex(index, bottomNavigationController.historyIndex);
        break;
      case 2:
        bool isLogin = await global.isLogin();
        if (isLogin) {
          global.showOnlyLoaderDialog(context);
          try {
            await bottomNavigationController.getLiveAstrologerList();
            bottomNavigationController.setBottomIndex(index, bottomNavigationController.historyIndex);
          } finally {
            global.hideLoader();
          }
        }
        break;
      case 4:
        bool isLogin = await global.isLogin();
        if (isLogin) {
          global.showOnlyLoaderDialog(context);
          try {
            await global.splashController.getCurrentUserData();
            await historyController.getPaymentLogs(global.currentUserId!, false);
            historyController.walletTransactionList = [];
            historyController.walletTransactionList.clear();
            historyController.walletAllDataLoaded = false;
            await historyController.getWalletTransaction(global.currentUserId!, false);
            bottomNavigationController.setBottomIndex(index, bottomNavigationController.historyIndex);
          } finally {
            global.hideLoader();
          }
        }
        break;
    }
  }
}
