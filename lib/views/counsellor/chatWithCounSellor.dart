// ignore_for_file: deprecated_member_use

import 'package:trueastrotalk/controllers/bottomNavigationController.dart';
import 'package:trueastrotalk/controllers/counsellorController.dart';
import 'package:trueastrotalk/views/callIntakeFormScreen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

import '../../controllers/reviewController.dart';
import '../../controllers/walletController.dart';
import '../../utils/images.dart';
import '../astrologerProfile/astrologerProfile.dart';
import '../paymentInformationScreen.dart';

// ignore: must_be_immutable
class ChatWithCounSellor extends StatelessWidget {
  final CounsellorController counsellorController;
  ChatWithCounSellor({Key? key, required this.counsellorController}) : super(key: key);
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey<ScaffoldState>();
  WalletController walletController = Get.find<WalletController>();
  BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CounsellorController>(
      builder: (c) {
        return ListView.builder(
          controller: counsellorController.scrollController,
          physics: ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: counsellorController.counsellorList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                Get.find<ReviewController>().getReviewData(counsellorController.counsellorList[index].id);
                global.showOnlyLoaderDialog(context);
                await bottomNavigationController.getAstrologerbyId(counsellorController.counsellorList[index].id);
                global.hideLoader();
                Get.to(() => AstrologerProfile(index: index));
              },
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      height: 75,
                                      width: 75,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(7), border: Border.all(color: Get.theme.primaryColor)),
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundColor: Colors.white,
                                        child: CachedNetworkImage(
                                          height: 55,
                                          width: 55,
                                          imageUrl: '${global.imgBaseurl}${counsellorController.counsellorList[index].profileImage}',
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => Image.asset(Images.deafultUser, fit: BoxFit.cover, height: 50, width: 40),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(right: 0, top: 2, child: Image.asset(Images.right, height: 18)),
                                ],
                              ),
                              RatingBar.builder(initialRating: 0, itemCount: 5, allowHalfRating: false, itemSize: 15, ignoreGestures: true, itemBuilder: (context, _) => Icon(Icons.star, color: Get.theme.primaryColor), onRatingUpdate: (rating) {}),
                              counsellorController.counsellorList[index].totalOrder == 0 ? SizedBox() : Text('${counsellorController.counsellorList[index].totalOrder} ${tr("orders")}', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, fontSize: 9)),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${counsellorController.counsellorList[index].name}'),
                                  counsellorController.counsellorList[index].allSkill == "" || counsellorController.counsellorList[index].allSkill == null
                                      ? const SizedBox()
                                      : Text('${counsellorController.counsellorList[index].allSkill}', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.grey[600])),
                                  Text('${counsellorController.counsellorList[index].languageKnown}', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.grey[600])),
                                  Text('${tr("Experience")} : ${counsellorController.counsellorList[index].experienceInYears} ${tr("Years")}', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.w300, color: Colors.grey[600])),
                                  Text('${counsellorController.counsellorList[index].charge}/min', style: Get.theme.textTheme.titleMedium!.copyWith(fontSize: 12, fontWeight: FontWeight.w300, letterSpacing: 0)),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                  padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                                  fixedSize: WidgetStateProperty.all(Size.fromWidth(90)),
                                  backgroundColor: WidgetStateProperty.all(Colors.green),
                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.green))),
                                ),
                                onPressed: () async {
                                  bool isLogin = await global.isLogin();
                                  if (isLogin) {
                                    double charge = double.parse(counsellorController.counsellorList[index].charge.toString());
                                    if (charge * 5 <= global.splashController.currentUser!.walletAmount!) {
                                      global.showOnlyLoaderDialog(context);

                                      await Get.to(
                                        () => CallIntakeFormScreen(
                                          type: "Chat",
                                          astrologerId: counsellorController.counsellorList[index].id,
                                          astrologerName: counsellorController.counsellorList[index].name,
                                          astrologerProfile: counsellorController.counsellorList[index].profileImage ?? "",
                                          rate: counsellorController.counsellorList[index].profileImage.toString(),
                                        ),
                                      );
                                      global.hideLoader();
                                    } else {
                                      global.showOnlyLoaderDialog(context);
                                      await walletController.getAmount();
                                      global.hideLoader();
                                      openBottomSheetRechrage(context, (charge * 5).toString(), '${counsellorController.counsellorList[index].name}');
                                    }
                                  }
                                },
                                child: Text('Chat', style: Get.theme.primaryTextTheme.bodySmall!.copyWith(color: Colors.white)).tr(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  counsellorController.isMoreDataAvailable == true && !counsellorController.isAllDataLoaded && counsellorController.counsellorList.length - 1 == index ? const CircularProgressIndicator() : const SizedBox(),
                  index == counsellorController.counsellorList.length - 1 ? const SizedBox(height: 60) : const SizedBox(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void openBottomSheetRechrage(BuildContext context, String minBalance, String astrologer) {
    Get.bottomSheet(
      Container(
        height: 250,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: Get.width * 0.85,
                                    child:
                                        minBalance != ''
                                            ? Text(
                                              '${tr("Minimum balance of 5 minutes")}(${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} $minBalance) ${tr("is required to start chat with")} $astrologer ',
                                              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
                                            ).tr()
                                            : const SizedBox(),
                                  ),
                                  GestureDetector(
                                    child: Padding(padding: minBalance == '' ? const EdgeInsets.only(top: 8) : const EdgeInsets.only(top: 0), child: Icon(Icons.close, size: 18)),
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ],
                              ),
                              Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 5), child: Text('Recharge Now', style: TextStyle(fontWeight: FontWeight.w500)).tr()),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [Padding(padding: const EdgeInsets.only(right: 5), child: Icon(Icons.lightbulb_rounded, color: Get.theme.primaryColor, size: 13)), Expanded(child: Text('Tip:90% users recharge for 10 mins or more.', style: TextStyle(fontSize: 12)).tr())],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 3.8 / 2.3, crossAxisSpacing: 1, mainAxisSpacing: 1),
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(8),
                shrinkWrap: true,
                itemCount: walletController.rechrage.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Get.to(() => PaymentInformationScreen(flag: 0, amount: double.parse(walletController.payment[index])));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                        child: Center(child: Text('${global.getSystemFlagValueForLogin(global.systemFlagNameList.currency)} ${walletController.rechrage[index]}', style: TextStyle(fontSize: 13))),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.8),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    );
  }
}
