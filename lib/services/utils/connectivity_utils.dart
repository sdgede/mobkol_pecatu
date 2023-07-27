import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../config/config.dart' as config;
import '../utils/dialog_utils.dart';

class ConnectivityUtils {
  static ConnectivityUtils distance = ConnectivityUtils();
  ConnectivityResult previous;
  Timer alert;
  var timer = 30;

  onCheckConnectivity(context) {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult connresult) {
      if (connresult == ConnectivityResult.none) {
        // no internet
        EasyLoading.show(status: config.Reconnect);
        alert = Timer(Duration(seconds: timer), () {
          EasyLoading.dismiss();
          _alertTimeout(context);
        });
      } else if (previous == ConnectivityResult.none) {
        // internet conn
        EasyLoading.dismiss();
        alert.cancel();
      }
      previous = connresult;
    });
  }

  _checkConnectivity(context) {
    try {
      InternetAddress.lookup('google.com').then((result) {
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          // internet conn available
          EasyLoading.dismiss();
          alert.cancel();
        } else {
          // no conn
          EasyLoading.show(status: config.Reconnect);
          alert = Timer(Duration(seconds: timer), () {
            EasyLoading.dismiss();
            _alertTimeout(context);
          });
        }
      }).catchError((error) {
        // no conn
        EasyLoading.show(status: config.Reconnect);
        alert = Timer(Duration(seconds: timer), () {
          EasyLoading.dismiss();
          _alertTimeout(context);
        });
      });
    } on SocketException catch (_) {
      // no internet
      EasyLoading.show(status: config.Reconnect);
      alert = Timer(Duration(seconds: timer), () {
        EasyLoading.dismiss();
        _alertTimeout(context);
      });
    }
  }

  _alertTimeout(BuildContext context) async {
    bool res = await DialogUtils.instance.showInfo(
          context: context,
          clickCancelText: 'Muat Ulang',
          clickOKText: 'Keluar',
          text:
              'Koneksi terputus. Silakan periksa kembali koneksi anda. Jika sedang melakukan transaksi mohon cek mutasi rekening anda.',
          title: 'Opps...',
        ) ??
        false;

    if (!res) {
      _checkConnectivity(context);
    } else {
      SystemNavigator.pop();
    }
  }
}
