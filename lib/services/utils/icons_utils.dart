import '../config/router_generator.dart';
import '../../model/global_model.dart';

class IconUtils {
  static IconUtils instance = IconUtils();

  List dataSetting() {
    return [
      ListModelKol(
        type: 'PRINTER_CONFIG',
        title: 'Konfigurasi Printer',
        navigator: RouterGenerator.mainSettingPrinter,
        icon: 'assets/icon/print.png',
      ),
      ListModelKol(
        type: 'MIGRASI_DATA',
        title: 'Data Migrasi',
        navigator: RouterGenerator.mainMigrasiData,
        icon: 'assets/icon/migrasi.png',
      ),
      ListModelKol(
        type: 'ABOUT',
        title: 'Tentang Aplikasi',
        navigator: RouterGenerator.about,
        icon: 'assets/icon/tentang.png',
      ),
      ListModelKol(
        type: 'LOGOUT',
        title: 'Log Out',
        navigator: RouterGenerator.about,
        icon: 'assets/icon/logout.png',
      ),
    ];
  }

  List dataMenuKolektor() {
    return [
      ListModelKol(
        type: 'TRX_KOL',
        title: 'Transaksi Kolektor',
        navigator: RouterGenerator.mainTransaksi,
        icon: 'assets/icon/transaksi.png',
      ),
      ListModelKol(
        type: 'KLAD',
        title: 'Daftar Klad',
        navigator: RouterGenerator.mainKlad,
        icon: 'assets/icon/daftar.png',
      ),
      ListModelKol(
        type: 'SALDOKOL',
        title: 'Saldo Kolektor',
        navigator: RouterGenerator.saldoKolektor,
        icon: 'assets/icon/saldo.png',
      ),
      ListModelKol(
        type: 'PENCARIAN_NASABAH',
        title: 'Pencarian Nasabah',
        navigator: RouterGenerator.pencarianNasabah,
        icon: 'assets/icon/pencarian.png',
      ),
      // ListModelKol(
      //   type: 'DATA_PENAGIHAN',
      //   title: 'Daftar Penagihan Pinjaman',
      //   navigator: RouterGenerator.pinjamanJatuhTempo,
      //   icon: 'assets/icon/icons8_jatemp.png',
      // ),
    ];
  }
}
