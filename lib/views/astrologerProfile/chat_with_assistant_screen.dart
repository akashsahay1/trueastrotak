// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:trueastrotalk/controllers/astrologer_assistant_controller.dart';
import 'package:trueastrotalk/model/chat_message_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatWithAstrologerAssistantScreen extends StatelessWidget {
  final int flagId;
  final String profileImage;
  final String astrologerName;
  final String fireBasechatId;
  final int chatId;
  final int astrologerId;
  ChatWithAstrologerAssistantScreen({super.key, required this.flagId, required this.profileImage, required this.astrologerName, required this.fireBasechatId, required this.astrologerId, required this.chatId});
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Get.theme.appBarTheme.systemOverlayStyle!.statusBarColor,
            title: GestureDetector(onTap: () async {}, child: Text("$astrologerName's ${tr("Assistant")}", style: Get.theme.primaryTextTheme.titleLarge!.copyWith(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.white))),
            leading: IconButton(
              onPressed: () async {
                Get.back();
              },
              icon: Icon(
                kIsWeb
                    ? Icons.arrow_back
                    : Platform.isIOS
                    ? Icons.arrow_back_ios
                    : Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          body: Container(
            color: Colors.white,
            child: Stack(
              children: [
                GetBuilder<AstrologerAssistantController>(
                  builder: (astrologerAssistantController) {
                    return Column(
                      children: [
                        Expanded(
                          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: astrologerAssistantController.getChatMessages(fireBasechatId, global.currentUserId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState.name == "waiting") {
                                return Center(child: CircularProgressIndicator());
                              } else {
                                if (snapshot.hasError) {
                                  return Text('snapShotError :- ${snapshot.error}');
                                } else {
                                  List<ChatMessageModel> messageList = [];
                                  for (var res in snapshot.data!.docs) {
                                    messageList.add(ChatMessageModel.fromJson(res.data()));
                                  }
                                  print(messageList.length);
                                  return ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 50),
                                    itemCount: messageList.length,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemBuilder: (context, index) {
                                      ChatMessageModel message = messageList[index];
                                      astrologerAssistantController.isMe = message.userId1 == '${global.currentUserId}';
                                      return Row(
                                        mainAxisAlignment: astrologerAssistantController.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: astrologerAssistantController.isMe ? Colors.grey[300] : Get.theme.primaryColor,
                                              borderRadius: BorderRadius.only(
                                                topLeft: const Radius.circular(12),
                                                topRight: const Radius.circular(12),
                                                bottomLeft: astrologerAssistantController.isMe ? const Radius.circular(0) : const Radius.circular(12),
                                                bottomRight: astrologerAssistantController.isMe ? const Radius.circular(0) : const Radius.circular(12),
                                              ),
                                            ),
                                            width: 140,
                                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                            child: Column(
                                              crossAxisAlignment: astrologerAssistantController.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                              children: [
                                                Text(messageList[index].message!, style: const TextStyle(color: Colors.white), textAlign: astrologerAssistantController.isMe ? TextAlign.end : TextAlign.start),
                                                messageList[index].createdAt != null
                                                    ? Padding(padding: const EdgeInsets.only(top: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [Text(DateFormat().add_jm().format(messageList[index].createdAt!), style: const TextStyle(color: Colors.grey, fontSize: 9.5))]))
                                                    : const SizedBox(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    child: GetBuilder<AstrologerAssistantController>(
                      builder: (astrologerAssistantController) {
                        return Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.all(Radius.circular(30.0))),
                                height: 50,
                                child: TextField(
                                  controller: messageController,
                                  onChanged: (value) {},
                                  cursorColor: Colors.black,
                                  style: TextStyle(color: Colors.black),
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30.0)), borderSide: BorderSide(color: Get.theme.primaryColor)),
                                    enabledBorder: OutlineInputBorder(borderRadius: const BorderRadius.all(Radius.circular(30.0)), borderSide: BorderSide(color: Get.theme.primaryColor)),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Material(
                                elevation: 3,
                                color: Colors.transparent,
                                borderRadius: const BorderRadius.all(Radius.circular(100)),
                                child: Container(
                                  height: 49,
                                  width: 49,
                                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Get.theme.primaryColor)),
                                  child: InkWell(
                                    onTap: () {
                                      if (messageController.text != "") {
                                        astrologerAssistantController.sendMessage(messageController.text, fireBasechatId, astrologerId);
                                        messageController.clear();
                                      }
                                    },
                                    child: const Padding(padding: EdgeInsets.only(left: 5.0), child: Icon(Icons.send, size: 25, color: Colors.grey)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
