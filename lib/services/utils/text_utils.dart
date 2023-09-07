import 'package:intl/intl.dart';
import 'dart:math';

import '../config/config.dart' as config;

class TextUtils {
  static TextUtils instance = TextUtils();

  String capitalizeEachWord(String str) {
    var splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
      splitStr[i] = splitStr[i][0].toUpperCase() + splitStr[i].substring(1);
    }
    return splitStr.join(' ');
  }

  String? getBulanString({dynamic date, String? bulan}) {
    var bln;
    if (date != null)
      bln = date.split('-')[1];
    else
      bln = bulan;
    switch (int.parse(bln)) {
      case 1:
        return "Januari";
        break;
      case 2:
        return "Februari";
        break;
      case 3:
        return "Maret";
        break;
      case 4:
        return "April";
        break;
      case 5:
        return "Mei";
        break;
      case 6:
        return "Juni";
        break;
      case 7:
        return "Juli";
        break;
      case 8:
        return "Agustus";
        break;
      case 9:
        return "September";
        break;
      case 10:
        return "Oktober";
        break;
      case 11:
        return "November";
        break;
      case 12:
        return "Desember";
        break;
    }
    return null;
  }

  String getHariString(dynamic day) {
    switch (int.parse(day)) {
      case 0:
        return "Minggu";
        break;
      case 1:
        return "Senin";
        break;
      case 2:
        return "Selasa";
        break;
      case 3:
        return "Rabu";
        break;
      case 4:
        return "Kamis";
        break;
      case 5:
        return "Jumat";
        break;
      case 6:
        return "Sabtu";
        break;
      default:
        return "";
        break;
    }
  }

  dynamic numberFormat(dynamic number, {isRp = true}) {
    String currencyId = "Rp. ";
    if (!isRp) currencyId = "";

    return NumberFormat.currency(locale: 'id', decimalDigits: 0)
        .format(double.parse(number))
        .toString()
        .replaceAll("IDR", currencyId);
  }

  dynamic getProvider(hp) {
    hp = hp.replaceAll(' ', '').substring(0, 4);
    for (var provider in config.dataProvider!) {
      if (provider['value'] == hp) {
        return provider['jenis_provider'];
      }
    }

    return null;
  }

  dynamic getMinutesFromIntervalTwoDate(firstDate, lastDate) {
    DateTime dateTimefirstDate = DateTime.parse(firstDate);
    DateTime dateTimelastDate = DateTime.parse(lastDate);
    final differenceInMinutes =
        dateTimefirstDate.difference(dateTimelastDate).inSeconds;
    return differenceInMinutes;
  }

  dynamic customDecrypt(String decrypt) {
    String reDecrypt;
    if (decrypt.substring(0, 8) == '{value: ') {
      reDecrypt = decrypt.substring(8, decrypt.length);
      reDecrypt = reDecrypt.substring(0, reDecrypt.length - 1);
    } else {
      reDecrypt = decrypt;
    }
    return reDecrypt;
  }

  String? getDateIndo(String date) {
    if (date == null) return null;
    var newDate = date.split('-');
    String hari = newDate[0];
    String bulan = getBulanString(bulan: newDate[1]) as String;
    String tahunjam = newDate[2];
    return hari + " " + bulan + " " + tahunjam;
  }

  String getSmallDateIndo(String date) {
    if (date == null) return "";
    var newDate = date.split('-');
    String hari = newDate[0];
    String bulan = getBulanString(bulan: newDate[1])!.substring(0, 3);
    var tahunjam = newDate[2].toString().split(' ');
    String tahun = tahunjam[0];
    return hari + " " + bulan + " " + tahun;
  }

  String getRandomString({int length = 64}) {
    Random _rnd = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
