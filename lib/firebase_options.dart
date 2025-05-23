import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // case TargetPlatform.windows:
      //   return web;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyDIyKdtH6FeOaI3I3XZ8vtwECLATnwy7Sw",
    authDomain: "trueastrotalk-1.firebaseapp.com",
    projectId: "trueastrotalk-1",
    storageBucket: "trueastrotalk-1.firebasestorage.app",
    messagingSenderId: "540290890159", //381086206621
    appId: "1:540290890159:ios:e889c01ea401aa4904175a",
    measurementId: "",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyDIyKdtH6FeOaI3I3XZ8vtwECLATnwy7Sw",
    authDomain: "trueastrotalk-1.firebaseapp.com",
    projectId: "trueastrotalk-1",
    storageBucket: "trueastrotalk-1.firebasestorage.app",
    messagingSenderId: "540290890159", //381086206621
    appId: "1:540290890159:ios:e889c01ea401aa4904175a",
    iosBundleId: 'com.trueastrotalk.user',
    measurementId: "",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyA3ngfZXqLCK8hZBMS3WipbxMAbsvXm3JE",
    authDomain: "trueastrotalk-1.firebaseapp.com",
    projectId: "trueastrotalk-1",
    storageBucket: "trueastrotalk-1.firebasestorage.app",
    messagingSenderId: "540290890159",
    appId: "1:540290890159:web:de97f96cd9867c1504175a",
    measurementId: "G-3HNMK2RYLF",
    databaseURL: "https://trueastrotalk-1-default-rtdb.firebaseio.com/",
  );
}
