import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Monitors network connectivity and shows status notifications.
class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription _subscription;
  RxBool isOnline = true.obs;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) async {
      final previousStatus = isOnline.value;
      final connected = !result.contains(ConnectivityResult.none)
          ? await _verifyInternetAccess()
          : false;

      isOnline.value = connected;

      if (previousStatus != connected) {
        if (!connected) {
          _showSnackBar('No Internet Connection', background: Colors.red.shade400);
        } else {
          _showSnackBar(
            'Back Online',
            background: Colors.green.shade400,
            duration: const Duration(seconds: 2),
          );
        }
      }
    });
  }

  Future<bool> _verifyInternetAccess() async {
    try {
      final lookup = await InternetAddress.lookup('google.com');
      return lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  void _showSnackBar(
    String message, {
    Color? background,
    Duration duration = const Duration(days: 1),
  }) {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: background,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showAppMessage(
    String message, {
    Color? background,
    Duration? duration,
  }) {
    _showSnackBar(
      message,
      background: background ?? Colors.blueGrey.shade700,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
