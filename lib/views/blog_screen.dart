import 'dart:io';

import 'package:trueastrotalk/controllers/reviewController.dart';
import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/images.dart';

// ignore: must_be_immutable
class BlogScreen extends StatelessWidget {
  final String link;
  final String title;
  final String? videoTitle;
  final String? date;
  final YoutubePlayerController? controller;
  BlogScreen({super.key, required this.link, this.controller, this.title = 'News', this.date, this.videoTitle});
  final ReviewController reviewController = Get.find<ReviewController>();
  SplashController splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
        title: Text('Astrology $title', style: Get.theme.primaryTextTheme.titleLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white)).tr(),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            kIsWeb
                ? Icons.arrow_back
                : Platform.isIOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
            color: Colors.white, //Get.theme.iconTheme.color,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              splashController.createAstrologerShareLink();
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.white), borderRadius: BorderRadius.circular(5)),
                child: Row(children: [Image.asset(Images.whatsapp, height: 40, width: 40), Padding(padding: const EdgeInsets.all(8.0), child: Text('Share', style: Get.textTheme.titleMedium!.copyWith(fontSize: 12, color: Colors.white)).tr())]),
              ),
            ),
          ),
        ],
      ),
      body:
          title == "News"
              ? WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setBackgroundColor(Colors.transparent)
                  ..loadRequest(Uri.parse(link)),
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: Center(
                      child: YoutubePlayer(
                      controller: controller!,
                      aspectRatio: 16 / 13,
                    ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(padding: const EdgeInsets.all(8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: Get.width * 0.7, child: Text('$videoTitle').tr()), Text('$date', textAlign: TextAlign.end)])),
                ],
              ),
    );
  }
}
