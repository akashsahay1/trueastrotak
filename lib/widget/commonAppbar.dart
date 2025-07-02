// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

import '../controllers/bottomNavigationController.dart';
import '../utils/images.dart';
import '../views/bottomNavigationBarScreen.dart';

class CommonAppBar extends StatelessWidget {
  final int flagId;
  final String title;
  final isProfilePic;
  final String? profileImg;
  List<Widget>? actions;
  CommonAppBar({Key? key, required this.title, this.isProfilePic = false, this.profileImg, this.actions, this.flagId = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AppBar(
      actions: actions,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: theme.appBarTheme.elevation,
      centerTitle: theme.appBarTheme.centerTitle,
      title: isProfilePic
          ? Row(
              children: [
                profileImg == ""
                    ? CircleAvatar(backgroundImage: AssetImage(Images.deafultUser))
                    : CachedNetworkImage(
                        imageUrl: "${global.imgBaseurl}$profileImg",
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            backgroundImage: imageProvider,
                          );
                        },
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return CircleAvatar(
                            backgroundColor: colorScheme.primary,
                            child: Image.asset(
                              Images.deafultUser,
                              fit: BoxFit.fill,
                              height: 40,
                            ),
                          );
                        },
                      ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    title,
                    style: theme.appBarTheme.titleTextStyle ??
                        theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.appBarTheme.foregroundColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ).tr(),
                ),
              ],
            )
          : Text(
              title,
              style: theme.appBarTheme.titleTextStyle ??
                  theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: theme.appBarTheme.foregroundColor,
                  ),
            ).tr(),
      leading: IconButton(
        onPressed: () {
          if (flagId == 1) {
            BottomNavigationController bottomNavigationController = Get.find<BottomNavigationController>();
            bottomNavigationController.setIndex(0, 0);
            Get.to(() => BottomNavigationBarScreen(index: 0));
          } else {
            Get.back();
          }
        },
        icon: Icon(
          kIsWeb
              ? Icons.arrow_back_rounded
              : Platform.isIOS
                  ? Icons.arrow_back_ios_rounded
                  : Icons.arrow_back_rounded,
          color: theme.appBarTheme.foregroundColor,
        ),
        tooltip: 'Back',
      ),
    );
  }
}
