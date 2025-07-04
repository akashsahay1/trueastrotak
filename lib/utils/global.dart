//import 'package:flutter/animation.dart';
// ignore_for_file: unused_local_variable, unnecessary_null_comparison, deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:trueastrotalk/controllers/splashController.dart';
import 'package:trueastrotalk/model/current_user_model.dart';
import 'package:trueastrotalk/model/hororscopeSignModel.dart';
import 'package:trueastrotalk/model/systemFlagNameListModel.dart';
import 'package:trueastrotalk/utils/services/api_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trueastrotalk/utils/global.dart' as global;

import '../controllers/loginController.dart';
import '../controllers/networkController.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../views/loginScreen.dart';

String currentLocation = '';
SharedPreferences? sp;
String? currencyISOCode3;
dynamic generalPayload;
SharedPreferences? spLanguage;

String timeFormat = '24';
String? appDeviceId;
String languageCode = 'en';
String? mapBoxAPIKey;
APIHelper apiHelper = APIHelper();
bool isRTL = false;
String status = "WAITING";
CurrentUserModel? currentUserPayment;
CurrentUserModel user = CurrentUserModel();
Color toastBackGoundColor = Colors.green;
Color textColor = Colors.black;
NetworkController networkController = Get.put((NetworkController()));
SplashController splashController = Get.find<SplashController>();
final DateFormat formatter = DateFormat("dd MMM yy, hh:mm a");

String stripeBaseApi = 'https://api.stripe.com/v1';

String baseUrl = "https://www.trueastrotalk.com/api";
String imgBaseurl = "https://www.trueastrotalk.com/";
String webBaseUrl = "https://www.trueastrotalk.com/api/";
String appMode = "LIVE";
Map<String, dynamic> appParameters = {
  "LIVE": {"apiUrl": "https://www.trueastrotalk.com/api", "imageBaseurl": "https://www.trueastrotalk.com/"},
  "DEV": {"apiUrl": "http://192.168.29.223:8001/api", "imageBaseurl": "http://192.168.29.223:8001/"},
};
String agoraChannelName = ""; //valid 24hr
String agoraToken = "";
String channelName = "astrowayLive";
String agoraLiveToken = "";
String liveChannelName = "astrowayLive";
String agoraChatUserId = "astrowayLive";
String chatChannelName = "astrowayLive";
String agoraChatToken = "";
String encodedString = "&&";
Color coursorColor = Color(0xFF757575);
int? currentUserId;
String agoraResourceId = "";
String agoraResourceId2 = "";
String agoraSid1 = "";
String agoraSid2 = "";
String? googleAPIKey;
String lat = "21.124857";
String lng = "73.112610";
var nativeAndroidPlatform = const MethodChannel('nativeAndroid');
int? localUid;
int? localLiveUid;
int? localLiveUid2;
bool isHost = false;

Future<void> callOnFcmApiSendPushNotifications({
  List<String?>? fcmTokem,
  String? subTitle,
  String? fcmToken,
  String? title,
  String? name,
  String? channelname,
  String? profile,
  String? waitListId,
  String? liveChatSUserName,
  String? sessionType,
  String? chatId,
  String? timeInInt,
  String? joinUserName,
  String? joinUserProfile,
}) async {
  var accountCredentials = await loadCredentials();
  var scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  var client = http.Client();
  try {
    var credentials = await obtainAccessCredentialsViaServiceAccount(ServiceAccountCredentials.fromJson(accountCredentials), scopes, client);
    if (credentials == null) {
      log('Failed to obtain credentials');
      return;
    }
    final headers = {'content-type': 'application/json', 'Authorization': 'Bearer ${credentials.accessToken.data}'};
    log("GENERATED TOKEN IS-> ${credentials.accessToken.data}");
    final data = {
      "message": {
        "token": fcmTokem![0].toString(),
        "notification": {"body": subTitle, "title": title},
        "data": {"name": name, "channelName": channelname, "profile": profile, "waitListId": waitListId, "liveChatSUserName": liveChatSUserName, "sessionType": sessionType, "chatId": chatId, "timeInInt": timeInInt, "joinUserName": joinUserName, "joinUserProfile": joinUserProfile},
        "android": {
          "notification": {"click_action": "android.intent.action.MAIN"},
        },
      },
    };
    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/trueastrotalk-1/messages:send');
    final response = await http.post(url, headers: headers, body: json.encode(data));
    log('noti response ${response.body}');
    if (response.statusCode == 200) {
      log('Notification sent successfully');
    } else {
      log('Failed to send notification: ${response.body}');
    }
  } catch (e) {
    print('Error sending notification: $e');
  } finally {
    client.close();
  }
}

Future<Map<String, dynamic>> loadCredentials() async {
  String credentialsPath = 'lib/utils/noti_service.json';
  String content = await rootBundle.loadString(credentialsPath);
  return json.decode(content);
}

//Strip implement finish

Future<void> createAndShareLinkForHistoryChatCall() async {
  try {
    Share.share('check out my website https://example.com');
    // await Share.share(
    //   title:
    //       'Check my call on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} app. You should also try and see your future. First call is free',
    //   text:
    //       'Check my call on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} app. You should also try and see your future. First call is free',
    //   linkUrl: '',
    // );
  } catch (e) {
    print("Exception - global.dart - referAndEarn():" + e.toString());
  }
}

Future<void> createAndShareLinkForBloog(String title) async {
  try {
    await Share.share('$title True Astrotalk', subject: '$title True Astrotalk');
  } catch (e) {
    print("Exception - global.dart - referAndEarn():" + e.toString());
  }
}

createAndShareLinkForDailyHorscope() async {
  await Share.share('${getSystemFlagValueForLogin(systemFlagNameList.appName)}', subject: "Check out your free daily horoscope on ${global.getSystemFlagValue(global.systemFlagNameList.appName)} & plan your day batter ").then((value) {}).catchError((e) {
    print(e);
  });
}

abstract class DateFormatter {
  static String? formatDate(DateTime timestamp) {
    if (timestamp == null) {
      return null;
    }
    String date = "${timestamp.day} ${DateFormat('MMMM').format(timestamp)} ${timestamp.year}";
    return date;
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static DateTime? toDateTime(Timestamp value) {
    if (value == null) return null;

    return value.toDate();
  }
}

showOnlyLoaderDialog(context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        //backgroundColor: Colors.transparent,
        child:
            kIsWeb
                ? Container(width: Get.width * 0.10, padding: EdgeInsets.all(18.0), child: Row(children: [CircularProgressIndicator(color: Colors.black), const SizedBox(width: 10), const Text("Please wait", style: TextStyle(color: Colors.black)).tr()]))
                : Padding(padding: const EdgeInsets.all(18.0), child: Row(children: [CircularProgressIndicator(color: Colors.black), const SizedBox(width: 10), const Text("Please wait", style: TextStyle(color: Colors.black)).tr()])),
      );
    },
  );
}

showSnackBar(String title, String text, {Duration? duration}) {
  return Get.snackbar(title, text, dismissDirection: DismissDirection.horizontal, showProgressIndicator: true, isDismissible: true, duration: duration != null ? duration : Duration(seconds: 2), snackPosition: SnackPosition.BOTTOM);
}

void hideLoader() {
  Get.back();
}

Future<bool> checkBody() async {
  bool result;
  try {
    await networkController.initConnectivity();
    if (networkController.connectionStatus.value != 0) {
      result = true;
    } else {
      print("No internet connection detected: ${networkController.connectionStatus.value}");
      // Only show snackbar if Get context is available and during normal app usage
      if (Get.context != null && Get.routing.current != '/') {
        Get.snackbar('Warning', 'No internet connection', snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 3), backgroundColor: Get.theme.primaryColor, colorText: Colors.white);
      }
      result = false;
    }

    return result;
  } catch (e) {
    print("Exception - checkBodyController - checkBody():" + e.toString());
    // Return true to allow app initialization to continue even if network check fails
    return true;
  }
}

//check login
Future<bool> isLogin() async {
  sp = await SharedPreferences.getInstance();
  if (sp!.getString("token") == null && sp!.getInt("currentUserId") == null && currentUserId == null) {
    Get.to(() => LoginScreen());
    return false;
  } else {
    return true;
  }
}

logoutUser() async {
  await apiHelper.logout();
  sp = await SharedPreferences.getInstance();
  sp!.remove("currentUser");
  sp!.remove("currentUserId");
  sp!.remove("token");
  sp!.remove("tokenType");
  user = CurrentUserModel();
  sp!.clear();
  final LoginController loginController = Get.find<LoginController>();
  loginController.phoneController.clear();
  loginController.update();
  log("current user logout:- ${sp!.getString('currentUserId')}");
  currentUserId = null;
  splashController.currentUser = null;
  Get.off(() => LoginScreen());
}

//save current user
// CurrentUserModel? user;
saveCurrentUser(int id, String token, String tokenType) async {
  try {
    sp = await SharedPreferences.getInstance();
    await sp!.setInt('currentUserId', id);
    await sp!.setString('token', token);
    await sp!.setString('tokenType', tokenType);
  } catch (e) {
    print("Exception - gloabl.dart - saveCurrentUser():" + e.toString());
  }
}

getCurrentUser() async {
  try {
    sp = await SharedPreferences.getInstance();
    currentUserId = sp!.getInt('currentUserId');
    log('user ID is :- $currentUserId');
  } catch (e) {
    print("Exception - gloabl.dart - getCurrentUser():" + e.toString());
  }
}

String appId =
    kIsWeb
        ? '1'
        : Platform.isAndroid
        ? "1"
        : "1";
AndroidDeviceInfo? androidInfo;
IosDeviceInfo? iosInfo;
WebBrowserInfo? webBrowserInfo;
DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
var appVersion = "1.0.0";
String? deviceId;
String? fcmToken;
String? deviceLocation;
String? deviceManufacturer;
String? deviceModel;
SystemFlagNameList systemFlagNameList = SystemFlagNameList();
List<HororscopeSignModel> hororscopeSignList = [];

String getAppVersion() {
  PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  return appVersion;
}

String getSystemFlagValue(String flag) {
  try {
    if (splashController.currentUser?.systemFlagList == null) {
      debugPrint('SystemFlagList is null, returning fallback for flag: $flag');
      return _getFallbackValue(flag);
    }

    // Try to find the flag
    try {
      var flagItem = splashController.currentUser!.systemFlagList!.firstWhere((e) => e.name == flag);
      return flagItem.value;
    } on StateError {
      debugPrint('System flag not found in currentUser: $flag, using fallback');
      return _getFallbackValue(flag);
    }
  } catch (e) {
    debugPrint('Error getting system flag "$flag": $e');
    return _getFallbackValue(flag);
  }
}

String getSystemFlagValueForLogin(String flag) {
  try {
    if (splashController.syatemFlag.isEmpty) {
      debugPrint('syatemFlag list is empty, returning fallback for flag: $flag');
      return _getFallbackValue(flag);
    }

    // Try to find the flag
    try {
      var flagItem = splashController.syatemFlag.firstWhere((e) => e.name == flag);
      return flagItem.value;
    } on StateError {
      debugPrint('System flag not found: $flag, using fallback');
      return _getFallbackValue(flag);
    }
  } catch (e) {
    debugPrint('Error getting system flag "$flag": $e');
    return _getFallbackValue(flag);
  }
}

String _getFallbackValue(String flag) {
  // Fallback values for common flags based on actual flag names
  switch (flag) {
    case 'currencySymbol':
      return '\$';
    case 'AppName':
      return 'True Astrotalk';
    case 'PaymentMode':
      return 'Razorpay';
    case 'Gst':
      return '18';
    case 'BehindScenes':
      return '0'; // Default to disabled to prevent video loading errors
    default:
      debugPrint('No fallback value available for flag: $flag');
      return '';
  }
}

showToast({required String message, required Color textColor, required Color bgColor}) async {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT, gravity: ToastGravity.BOTTOM, timeInSecForIosWeb: 1, backgroundColor: bgColor, textColor: textColor, fontSize: 14.0);
}

Future<Widget> showHtml({required String html, Map<String, Style>? style}) async {
  try {
    return Html(data: html, style: style ?? {});
  } catch (e) {
    return Html(data: html, style: style ?? {});
  }
}

Future<BottomNavigationBarItem> showBottom({required String text, required Widget widget}) async {
  return BottomNavigationBarItem(icon: widget, label: text);
}

Future<InputDecoration> showDecorationHint({required String hint, InputBorder? inputBorder}) async {
  return InputDecoration(hintText: hint, border: inputBorder);
}

Future getDeviceData() async {
  log('in getDeviceData');

  await PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
    appVersion = packageInfo.version;
  });
  if (kIsWeb) {
    if (webBrowserInfo == null) {
      webBrowserInfo = await deviceInfo.webBrowserInfo;
    }
    String browserNameString = 'Unknow browser';
    switch (webBrowserInfo!.browserName) {
      case BrowserName.firefox:
        browserNameString = 'Firefox';
        break;
      case BrowserName.samsungInternet:
        browserNameString = 'Samsung Internet Browser';
        break;
      case BrowserName.opera:
        browserNameString = 'opera';
        break;
      case BrowserName.msie:
        browserNameString = 'msie';
        break;
      case BrowserName.edge:
        browserNameString = 'edge';
        break;
      case BrowserName.chrome:
        browserNameString = 'chrome';
        break;
      case BrowserName.safari:
        browserNameString = 'safari';
        break;
      default:
        browserNameString = 'Unknown browser';
    }
    deviceModel = browserNameString;
    deviceManufacturer = webBrowserInfo!.vendor;
    deviceId = webBrowserInfo!.productSub;
    fcmToken = await FirebaseMessaging.instance.getToken();
    log('fcm token:- $fcmToken');
    log('deviceManufacturer:- $browserNameString');
    log('vendor:- ${webBrowserInfo!.vendor}');
    log('platorm:- ${webBrowserInfo!.platform}');
    log('product snub:- ${webBrowserInfo!.productSub}');

    //webBrowserInfo
  } else {
    if (Platform.isAndroid) {
      if (androidInfo == null) {
        androidInfo = await deviceInfo.androidInfo;
      }
      deviceModel = androidInfo!.model;
      deviceManufacturer = androidInfo!.manufacturer;
      deviceId = androidInfo!.id;
      fcmToken = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      if (iosInfo == null) {
        iosInfo = await deviceInfo.iosInfo;
      }
      deviceModel = iosInfo!.model;
      deviceManufacturer = "Apple";
      deviceId = iosInfo!.identifierForVendor;
      fcmToken = await FirebaseMessaging.instance.getToken();
    }
  }
}

saveUser(CurrentUserModel user) async {
  try {
    sp = await SharedPreferences.getInstance();
    await sp!.setString('currentUser', json.encode(user.toJson()));
  } catch (e) {
    print("Exception - global.dart - saveUser(): ${e.toString()}");
  }
}

//Api Header
Future<Map<String, String>> getApiHeaders(bool authorizationRequired) async {
  Map<String, String> apiHeader = new Map<String, String>();

  if (authorizationRequired) {
    sp = await SharedPreferences.getInstance();
    String? token = sp!.getString("token");
    String tokenType = sp!.getString("tokenType") ?? "Bearer";

    if (token != null && token.isNotEmpty) {
      debugPrint('Using authentication token');
      apiHeader.addAll({"Authorization": " $tokenType $token"});
    } else {
      debugPrint('No valid authentication token found - user may need to log in');
      // Don't add Authorization header if no valid token exists
    }
  }
  apiHeader.addAll({"Content-Type": "application/json"});
  apiHeader.addAll({"Accept": "application/json"});
  return apiHeader;
}
