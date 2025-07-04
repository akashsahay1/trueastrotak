// ignore_for_file: must_be_immutable

import 'package:trueastrotalk/controllers/customer_support_controller.dart';
import 'package:trueastrotalk/views/customer_support/customerSupportChatScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

import '../../widget/commonAppbar.dart';

class CreateTiketScreen extends StatelessWidget {
  final String subject;
  final String helpSupportQuestion;
  final int helpSupportQuestionId;
  final String helpSupportSubQuestion;
  CreateTiketScreen({Key? key, required this.helpSupportQuestion, required this.helpSupportSubQuestion, required this.subject, required this.helpSupportQuestionId}) : super(key: key);

  CustomerSupportController customerSupportController = Get.find<CustomerSupportController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(preferredSize: Size.fromHeight(56), child: CommonAppBar(title: 'Create Ticket')),
      body: GetBuilder<CustomerSupportController>(
        builder: (c) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject', style: Get.textTheme.titleMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.w600)).tr(),
                  Text(helpSupportSubQuestion, style: Get.textTheme.titleMedium!.copyWith(fontSize: 15, color: Colors.grey)),
                  SizedBox(height: 15),
                  Text('Description', style: Get.textTheme.titleMedium!.copyWith(fontSize: 18, fontWeight: FontWeight.w600)).tr(),
                  Text('Please mention your complete concern here', style: Get.textTheme.titleMedium!.copyWith(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w300)).tr(),
                  TextField(
                    keyboardType: TextInputType.multiline,
                    minLines: 7,
                    maxLines: 7,
                    controller: customerSupportController.descriptionController,
                    onChanged: (val) {
                      customerSupportController.textLength = val.length;
                      customerSupportController.update();
                      print('text length : ${customerSupportController.textLength}');
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: tr("Type your concern here..."),
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    ),
                  ),
                  SizedBox(height: 15, child: Align(alignment: Alignment.bottomRight, child: Text('${customerSupportController.textLength}/50', style: Get.textTheme.titleMedium!.copyWith(fontSize: 10, color: Colors.grey)))),
                ],
              ),
            ),
          );
        },
      ),
      bottomSheet: GetBuilder<CustomerSupportController>(
        builder: (c) {
          return GestureDetector(
            onTap: () async {
              if (customerSupportController.textLength < 50) {
                global.showToast(message: tr('Please enter more than 50 words'), textColor: global.textColor, bgColor: global.toastBackGoundColor);
              } else {
                customerSupportController.textLength = 0;
                global.showOnlyLoaderDialog(context);
                await customerSupportController.createCustomerTickets(subject, helpSupportQuestionId, helpSupportQuestion, helpSupportSubQuestion);
                global.hideLoader();
                Get.to(() => CustomerSupportChat());
              }
            },
            child: Container(
              color: customerSupportController.textLength < 50 ? Color.fromARGB(255, 196, 191, 191) : Get.theme.primaryColor,
              height: 50,
              alignment: Alignment.center,
              width: double.infinity,
              child: Text('Chat with us', style: Get.theme.textTheme.titleMedium!.copyWith(fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0, color: Colors.grey)).tr(),
            ),
          );
        },
      ),
    );
  }
}
