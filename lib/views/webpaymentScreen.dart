// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:trueastrotalk/controllers/history_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/global.dart';
import '../widget/commonAppbar.dart';
import 'bottomNavigationBarScreen.dart';

import '../utils/global.dart' as global;

class PaymentScreen extends StatefulWidget {
  String url;
  PaymentScreen({Key? key, required this.url}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late WebViewController _controller;
  final historyController = Get.find<HistoryController>();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            log('start url: $url');
          },
          onPageFinished: (String url) async {
            log('onPageFinished called: $url');
            
            if (url.startsWith("${imgBaseurl}payment-success")) {
              await global.splashController.getCurrentUserData();
              await historyController.getChatHistory(global.currentUserId!, false);
              Get.off(() => BottomNavigationBarScreen(index: 0));
              Fluttertoast.showToast(msg: "Payment Success!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Get.theme.primaryColor, textColor: Colors.white, fontSize: 14.0);
            } else if (url.startsWith("${imgBaseurl}payment-failed")) {
              Get.off(() => BottomNavigationBarScreen(index: 0));
              Fluttertoast.showToast(msg: "Payment Failed!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Get.theme.primaryColor, textColor: Colors.white, fontSize: 14.0);
            }
          },
          onWebResourceError: (WebResourceError error) {
            log('error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaymentSuccess',
        onMessageReceived: (JavaScriptMessage message) {
          log('loaded PaymentSuccess: ${message.message}');
          Get.off(() => BottomNavigationBarScreen(index: 0));
          Fluttertoast.showToast(msg: "Payment Success!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Get.theme.primaryColor, textColor: Colors.white, fontSize: 14.0);
        },
      )
      ..addJavaScriptChannel(
        'PaymentFailed',
        onMessageReceived: (JavaScriptMessage message) {
          log('loaded PaymentFailed: ${message.message}');
          Get.off(() => BottomNavigationBarScreen(index: 0));
          Fluttertoast.showToast(msg: "Payment Failed!", toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: Get.theme.primaryColor, textColor: Colors.white, fontSize: 14.0);
        },
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(56), child: CommonAppBar(title: 'Payment Information')),
      body: Container(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
