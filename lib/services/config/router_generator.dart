import 'package:flutter/material.dart';
import '../../ui/screens/daftar_penagihan_pinjaman/daftar_penagihan_pinjaman.dart';
import '../../ui/screens/klad/adapter_pencarian_klad.dart';

//model
import '../../model/global_model.dart';
//landing page and login screen
import '../../ui/screens/login/splash_page.dart';
import '../../ui/screens/login/landing_page.dart';
import '../../ui/screens/login/login_form.dart';
//setting
import '../../ui/screens/setting/about.dart';
import '../../ui/screens/setting/reset_password.dart';
import '../../ui/screens/setting/reset_pin.dart';
//printer
import '../../ui/screens/printer/list_printer_device.dart';
import '../../ui/screens/printer/main_setting_printer.dart';
//home kolektor
import '../../ui/screens/home_page/home_kolektor.dart';
//transaksi
import '../../ui/screens/transaksi/hasil_pencarian_produk.dart';
import '../../ui/screens/transaksi/main_transaksi.dart';
import '../../ui/screens/transaksi/mutasi_kredit.dart';
import '../../ui/screens/transaksi/mutasi_transaksi.dart';
import '../../ui/screens/transaksi/sukses_transaksi.dart';
//saldokol
import '../../ui/screens/saldo_kolektor/main_saldo_kolektor.dart';
//klad kolektor
import '../../ui/screens/klad/main_klad.dart';
//nasabah
import '../../ui/screens/nasabah/adapter_pencarian_nasabah.dart';
import '../../ui/screens/nasabah/pencarian_nasabah.dart';
//migrasi data
import '../../ui/screens/migrasi_data/main_migrasi_data.dart';

class RouterGenerator {
  //* Routing list
  static const pageSplash = "/";
  static const pageLanding = "/pageLanding";
  static const pageHomeLogin = "/pageHomeLogin";
  static const pageLogin = "/pageLogin";
  static const homePage = "/homePage";
  static const homeKolektor = "/homeKolektor";
  static const pinLogin = "/pinLogin";

  //settings
  static const resetPassword = "/settings/resetPassword";
  static const resetPin = "/settings/resetPin";
  static const kontakKami = "/settings/kontakKami";
  static const about = "/settings/about";

  //menu transaksi
  static const mainTransaksi = "/transaksi/mainTransaksiPage";
  static const suksesTransaksi = "/transaksi/suksesTransaksiPage";
  static const hasilPencarianProduk = "/transaksi/hasilPencarianProdukPage";
  static const mutasiTransaksi = "/transaksi/mutasiTransaksiPage";
  static const mutasiKredit = "/transaksi/mutasiKreditPage";
  //menu klad
  static const mainKlad = "/klad/mainKladPage";
  static const adapterPencarianKlad = "/nasabah/asapterPencarianKladPage";
  // menu saldokol
  static const saldoKolektor = "/saldoKolektor/mainSaldoKolektorPage";
  // menu nasabah
  static const pencarianNasabah = "/nasabah/pencarianNasabahPage";
  static const adapterPencarianNasabah = "/nasabah/asapterPencarianNasabahPage";
  // menu printer
  static const mainSettingPrinter = "/printer/mainSettingPrinter";
  static const listPrinterDevice = "/printer/listPrinterDevice";
  // menu printer
  static const mainMigrasiData = "/migrasi/mainMigrasiDataPage";
  // menu daftar pinjaman jatuh tempo
  static const pinjamanJatuhTempo = "/migrasi/pinjamanJatuhTempoPage";
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      // routes main, login, homepage
      case pageSplash:
        return MaterialPageRoute(builder: (_) => SplashPage());
        break;
      case pageLanding:
        return MaterialPageRoute(builder: (_) => LandingPage());
        break;
      case pageLogin:
        return MaterialPageRoute(builder: (_) => LoginPage());
        break;
      case homeKolektor:
        return MaterialPageRoute(builder: (_) => HomeKolektor());
        break;

      //setting
      case resetPassword:
        var param = args as Map;
        return MaterialPageRoute(
            builder: (_) => ResetPassword(
                  isBuat: param['isBuat'] ?? false,
                ));
        break;
      case resetPin:
        var param = args as Map;
        return MaterialPageRoute(
            builder: (_) => ResetPin(
                  isBuat: param['isBuat'] ?? false,
                ));
        break;
      case about:
        return MaterialPageRoute(builder: (_) => AboutScreen());
        break;

      //transaksi
      case mainTransaksi:
        return MaterialPageRoute(builder: (_) => MainTransaksi());
        break;
      case hasilPencarianProduk:
        return MaterialPageRoute(
          builder: (_) => HasilPencarianProduk(
            arguments: args,
          ),
        );
        break;

      case suksesTransaksi:
        if (args is SuksesTransaksiModel) {
          return MaterialPageRoute(
            builder: (_) => SeuksesTransaksiScreen(
              dataSuksesTransaksi: args,
            ),
          );
        }
        break;
      case mutasiTransaksi:
        return MaterialPageRoute(
          builder: (_) => MutasiTransaksi(
            arguments: args,
          ),
        );
        break;
      case mutasiKredit:
        return MaterialPageRoute(
          builder: (_) => MutasiKredit(
            arguments: args,
          ),
        );
        break;
      //

      //klad
      case mainKlad:
        return MaterialPageRoute(builder: (_) => MainKlad());
        break;
      case adapterPencarianKlad:
        return MaterialPageRoute(builder: (_) => AdapterPencarianKlad());
        break;
      //klad
      case saldoKolektor:
        return MaterialPageRoute(builder: (_) => MainSaldoKolektor());
        break;
      //nasabah
      case pencarianNasabah:
        return MaterialPageRoute(builder: (_) => PencarianNasabah());
        break;
      case adapterPencarianNasabah:
        return MaterialPageRoute(builder: (_) => AdapterPencarianNasabah());
        break;
      //printer
      case mainSettingPrinter:
        return MaterialPageRoute(builder: (_) => MainSettingPrinter());
        break;
      case listPrinterDevice:
        return MaterialPageRoute(builder: (_) => ListPrinterDevice());
        break;
      //migrasi data
      case mainMigrasiData:
        return MaterialPageRoute(builder: (_) => MainMigrasiData());
        break;
      case pinjamanJatuhTempo:
        return MaterialPageRoute(builder: (_) => DaftarPenagihanPinjaman());
        break;
    }
  }
}
