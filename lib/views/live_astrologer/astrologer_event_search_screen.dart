import 'dart:io';

import 'package:trueastrotalk/controllers/bottomNavigationController.dart';
import 'package:trueastrotalk/controllers/languageController.dart';
import 'package:trueastrotalk/controllers/reportController.dart';
import 'package:trueastrotalk/controllers/reportTabFiltter.dart';
import 'package:trueastrotalk/controllers/reviewController.dart';
import 'package:trueastrotalk/controllers/skillController.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:trueastrotalk/utils/global.dart' as global;
import 'package:share_plus/share_plus.dart';

import '../../controllers/upcoming_controller.dart';
import '../../utils/images.dart';
import '../astrologerProfile/astrologerProfile.dart';

// ignore: must_be_immutable
class SearchLiveAstrologer extends StatelessWidget {
  SearchLiveAstrologer({Key? key}) : super(key: key);

  ReportController reportController = Get.find<ReportController>();
  ReportFilterTabController reportFilter = Get.find<ReportFilterTabController>();
  SkillController skillController = Get.find<SkillController>();
  LanguageController languageController = Get.find<LanguageController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            kIsWeb
                ? Icons.arrow_back
                : Platform.isIOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
            color: Get.theme.iconTheme.color,
          ),
        ),
        title: GetBuilder<UpcomingController>(
          builder: (upcomingSearch) {
            return FutureBuilder(
              future: global.showDecorationHint(hint: 'Search by Name', inputBorder: OutlineInputBorder(borderSide: BorderSide.none)),
              builder: (context, snapsort) {
                return TextField(
                  autofocus: true,
                  onChanged: (value) async {
                    print('$value');
                    await upcomingSearch.getSearchResult(value);
                  },
                  decoration: snapsort.data ?? null,
                );
              },
            );
          },
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search, color: Get.theme.iconTheme.color))],
      ),
      body: GetBuilder<UpcomingController>(
        builder: (upcomingController) {
          return ListView.builder(
            itemCount: upcomingController.searchUpComing.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () async {
                  print('search astro id:- ${upcomingController.searchUpComing[index].id!}');
                  Get.find<ReviewController>().getReviewData(upcomingController.searchUpComing[index].id!);
                  BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
                  global.showOnlyLoaderDialog(context);
                  await bottomNavigationController.getAstrologerbyId(upcomingController.searchUpComing[index].id!);
                  global.hideLoader();
                  Get.to(() => AstrologerProfile(index: index));
                },
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                              child: Container(
                                height: 65,
                                width: 65,
                                decoration: BoxDecoration(border: Border.all(color: Get.theme.primaryColor), borderRadius: BorderRadius.circular(7)),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: Colors.white,
                                  child: CachedNetworkImage(
                                    imageUrl: '${global.imgBaseurl}${upcomingController.searchUpComing[index].profileImage}',
                                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                    errorWidget: (context, url, error) => Image.asset(Images.deafultUser, fit: BoxFit.cover, height: 50, width: 40),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${upcomingController.searchUpComing[index].name}', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.black)),
                                Text("${DateFormat("dd MMM,EEEE").format(DateTime.now())}", style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.grey[600])),
                                upcomingController.searchUpComing[index].isTimeSlotAvailable == true
                                    ? Container(
                                      height: 20,
                                      width: 110,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: upcomingController.searchUpComing[index].availableTimes!.length,
                                        itemBuilder: (BuildContext context, int index2) {
                                          return (upcomingController.searchUpComing[index].availableTimes![index2].fromTime != null && upcomingController.searchUpComing[index].availableTimes![index2].toTime != null)
                                              ? Container(
                                                margin: EdgeInsets.only(left: 2),
                                                padding: EdgeInsets.all(2),
                                                decoration: BoxDecoration(color: Colors.grey[300], border: Border.all(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(10))),
                                                child: Text("${upcomingController.searchUpComing[index].availableTimes![index2].fromTime} - ${upcomingController.searchUpComing[index].availableTimes![index2].toTime}", style: TextStyle(fontSize: 9.5)),
                                              )
                                              : Text("No Time set yet!", style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.red)).tr();
                                        },
                                      ),
                                    )
                                    : Text("No Time set yet!", style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.red)).tr(),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await SharePlus.instance.share(
                                  ShareParams(
                                    text: "Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career. I would recommend you to connect with best Astrologer at ${global.getSystemFlagValue(global.systemFlagNameList.appName)}.",
                                    subject: "Hey! I am using ${global.getSystemFlagValue(global.systemFlagNameList.appName)} to get predictions related to marriage/career. I would recommend you to connect with best Astrologer at ${global.getSystemFlagValue(global.systemFlagNameList.appName)}.",
                                  ),
                                );
                              },
                              child: Icon(Icons.share_outlined, size: 20),
                            ),
                            SizedBox(height: 25),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
