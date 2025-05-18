// ignore_for_file: must_be_immutable

import 'package:trueastrotak/controllers/astrologerCategoryController.dart';
import 'package:trueastrotak/controllers/bottomNavigationController.dart';
import 'package:trueastrotak/controllers/chatController.dart';
import 'package:trueastrotak/utils/fonts.dart';
import 'package:trueastrotak/views/CustomText.dart';
import 'package:trueastrotak/views/callScreen.dart';
import 'package:trueastrotak/widget/commonAppbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:trueastrotak/utils/global.dart' as global;

class CategoryScreen extends StatelessWidget {
  CategoryScreen({super.key});
  BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
  ChatController chatController = Get.find<ChatController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(56), child: CommonAppBar(title: 'Categories')),
      body: Column(
        children: [
          SizedBox(height: FontSizes(context).height2()),
          GetBuilder<AstrologerCategoryController>(
            builder: (astrologyCat) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: FontSizes(context).width3()),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: astrologyCat.categoryList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisSpacing: FontSizes(context).width2(), mainAxisSpacing: FontSizes(context).height2(), mainAxisExtent: FontSizes(context).height15(), crossAxisCount: 4),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () async {
                        global.showOnlyLoaderDialog(context);
                        bottomNavigationController.astrologerList = [];
                        bottomNavigationController.astrologerList.clear();
                        bottomNavigationController.isAllDataLoaded = false;
                        bottomNavigationController.update();
                        chatController.isSelected = index + 1;
                        chatController.update();
                        await bottomNavigationController.astroCat(id: astrologyCat.categoryList[index].id!, isLazyLoading: false);
                        global.hideLoader();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CallScreen(flag: 1)));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(backgroundColor: Colors.white, radius: FontSizes(context).width7(), backgroundImage: NetworkImage("${global.imgBaseurl}${astrologyCat.categoryList[index].image}")),
                            SizedBox(height: FontSizes(context).height1()),
                            CustomText(text: "${astrologyCat.categoryList[index].name}", textAlign: TextAlign.center, maxLine: 2, fontWeight: FontWeight.w600, fontsize: FontSizes(context).font3()),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
