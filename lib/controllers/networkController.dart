//flutter
// ignore_for_file: cancel_subscriptions

import 'dart:async';
//packages
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  //** variables
  var connectionStatus = 0.obs;
  //** objects
  final Connectivity _connectivity = Connectivity();
  // ignore: unused_field
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(updateConnectivity);
  }
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await _connectivity.checkConnectivity();
    } catch (e) {
      print(e.toString());
    }

    return updateConnectivity(result);
  }

  updateConnectivity(List<ConnectivityResult> result) {

    switch (result[0]) {
      case ConnectivityResult.wifi:
        connectionStatus.value = 1;
        break;
      case ConnectivityResult.mobile:
        connectionStatus.value = 2;
        break;
      case ConnectivityResult.none:
        connectionStatus.value = 0;
        // Disable snackbar during initialization to prevent crashes
        print('No internet connection detected');
        break;
      default:
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
