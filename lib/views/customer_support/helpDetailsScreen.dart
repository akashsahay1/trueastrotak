import 'package:trueastrotalk/widget/helpDetailTileWidget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/customer_support_controller.dart';
import '../../widget/commonAppbar.dart';

class HelpDetailsScreen extends StatelessWidget {
  final String title;
  final int helpSupportQuestionId;
  final int index;
  final String helpSupportQuestion;
  HelpDetailsScreen({Key? key, required this.title, required this.helpSupportQuestion, required this.index, required this.helpSupportQuestionId}) : super(key: key);
  final CustomerSupportController customerSupportController = Get.find<CustomerSupportController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(56), child: CommonAppBar(title: 'Help and Support')),
      body:
          customerSupportController.helpAndSupportQuestion[index].answers!.isNotEmpty
              ? Center(child: Text('Answers not Available').tr())
              : SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: Text(title, style: Get.textTheme.titleSmall!.copyWith(fontSize: 18))),
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: customerSupportController.helpSupportSubCat.length,
                      itemBuilder: (context, i) {
                        return HelpDetailTileWidget(
                          subject: customerSupportController.helpSupportSubCat[i].title ?? "",
                          isImage: false,
                          helpSupportQuestionId: helpSupportQuestionId,
                          isChatWithUs: customerSupportController.helpSupportSubCat[i].isChatWithus ?? 0,
                          text: customerSupportController.helpSupportSubCat[i].description ?? "",
                          ontap: () {},
                          helpSupportQuestion: helpSupportQuestion,
                          helpSupportSubQuestion: title,
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
