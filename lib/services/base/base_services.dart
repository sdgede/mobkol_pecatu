import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../base/config_services.dart';
import '../config/router_generator.dart';
import '../utils/mcrypt_utils.dart';
import '../utils/auth_utils.dart';
import '../utils/dialog_utils.dart';
import '../../services/config/config.dart';
import '../../services/viewmodel/global_provider.dart';

enum RequestType { GET, POST, DELETE }

enum RequestTypeToken { APK, BERITA, MERCHANT }

enum TypeEncrypt { APK, MERCHANT }

class BaseServices {
  GlobalProvider? globalProv;

  Dio _dio = new Dio();
  Options? _headersOption;

  Future _getTokenAPK() async {
    var _token = await AuthUtils.instance.getTokenAPK();
    _headersOption = ConfigServices.getHeadersAPK(token: _token);
  }

  Future _getTokenMerchant() async {
    var _token = await AuthUtils.instance.getTokenMerchant();
    _headersOption = ConfigServices.getHeadersMerchant(token: _token);
  }

  Future<dynamic> request({
    String? url,
    RequestType? type,
    BuildContext? context,
    dynamic data,
    RequestTypeToken typeToken = RequestTypeToken.APK,
    TypeEncrypt typeEncrypt = TypeEncrypt.APK,
  }) async {
    Response? response;
    DioErrorType? errorType;

    await _addGlobalvalue(context!, data);
    print(data);
    if (typeToken == RequestTypeToken.APK) {
      await _getTokenAPK();
    } else if (typeToken == RequestTypeToken.MERCHANT) {
      await _getTokenMerchant();
    } else {
      _headersOption = null;
    }
    try {
      switch (type) {
        case RequestType.POST:
          if (typeToken == RequestTypeToken.MERCHANT)
            response = await _dio.post(url!,
                data: data != null ? data : null, options: _headersOption);
          else
            response = await _dio.post(url!,
                data: data != null ? FormData.fromMap(data) : null,
                options: _headersOption);
          break;
        case RequestType.GET:
          response = await _dio.get(url!, options: _headersOption);
          break;
        case RequestType.DELETE:
          response = await _dio.delete(url!,
              data: data != null ? data : null, options: _headersOption);
          break;
      }
    } on DioError catch (e) {
      print(e);
      response = e.response!;
      errorType = e.type;
    }

    int statusCode = response!.statusCode!;

    if (errorType == DioErrorType.connectionTimeout ||
        errorType == DioErrorType.receiveTimeout ||
        errorType == DioErrorType.unknown) {
      await DialogUtils.instance.showError(
        context: context,
        text:
            "Tidak dapat terhubung ke server. Silakan periksa koneksi internet Anda...",
      );
      return null;
    }

    if (statusCode == 403) {
      bool res = await DialogUtils.instance.showError(
            context: context,
            text: "Session Expired, silahkan login kembali...",
          ) ??
          false;
      if (res) {
        Navigator.pushNamedAndRemoveUntil(
            context, RouterGenerator.pageHomeLogin, (route) => false);
      }
      return null;
    }

    if (typeToken == RequestTypeToken.APK) {
      try {
        String body = response.data;
        print(body);
        var result;
        if (typeEncrypt == TypeEncrypt.APK) {
          result = McryptUtils.instance.decrypt(body.trim());
        } else {
          result = McryptUtils.instance.decryptMerchant(body.trim());
        }
        return result;
      } on Exception {
        return null;
      } catch (e) {
        print(e);
        return null;
      }
    } else {
      return response.data;
    }
  }

  _addGlobalvalue(BuildContext context, Map<String, dynamic> dataParse) async {
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    var user = dataLogin.containsKey('username') ? dataLogin['username'] : '0';
    var pwd = dataLogin.containsKey('password') ? dataLogin['password'] : '0';
    var imei = dataLogin.containsKey('imei') ? dataLogin['imei'] : '0';
    var groupCdKol =
        dataLogin.containsKey('group_cd') ? dataLogin['group_cd'] : '0';
    var wilayahCdKol =
        dataLogin.containsKey('wilayah') ? dataLogin['wilayah'] : '0';

    dataParse["user_kol"] = _encrypt(user);
    dataParse["pwd_kol"] = _encrypt(pwd);
    dataParse["imei_kol"] = _encrypt(imei);
    dataParse["groupCd_kolektor"] = _encrypt(groupCdKol);
    dataParse["wilayahCd_kolektor"] = _encrypt(wilayahCdKol);
    dataParse["lat"] = _encrypt(globalProv!.myLatitude.toString());
    dataParse["longi"] = _encrypt(globalProv!.myLongitude.toString());
  }

  String _encrypt(String val) {
    return McryptUtils.instance.encrypt(val ?? '0');
  }

  String _decrypt(String val) {
    return McryptUtils.instance.decrypt(val ?? '0');
  }
}
