import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import '../../../services/utils/dialog_utils.dart';
import '../../../ui/widgets/datetime_periode.dart';
import '../../../ui/constant/constant.dart';
import '../../../ui/widgets/app_bar.dart';
import '../../../services/viewmodel/produk_provider.dart';

class MainMigrasiData extends StatefulWidget {
  MainMigrasiData({Key key}) : super(key: key);

  @override
  _MainMigrasiData createState() => _MainMigrasiData();
}

class _MainMigrasiData extends State<MainMigrasiData> {
  ProdukCollectionProvider produkProv;
  final format = DateFormat("dd-MM-yyyy");
  DateTime _tglAwal = DateTime.parse(DateTime.now().year.toString() +
      (DateTime.now().month < 10 ? "-0" : "-") +
      DateTime.now().month.toString() +
      "-01");
  DateTime _tglAkhir = DateTime.now();
  String tglAwalParse, tglAkhirParse;

  var dataListMigrasi = [
    {
      'title': 'Master Nasabah',
      'desc': 'Migrasi data master nasabah',
      'icon': 'assets/icon/icons8-nas_migrate.png',
      'rekCd': 'MASTER_NASABAH',
      'groupProduk': 'MASTER_NASABAH',
      'color': '0xff1967d2',
      'color2': '0xff03d0ea',
      'isDev': false,
    },
    {
      'title': 'Data Akun',
      'desc': 'Migrasi data akun kolektor',
      'icon': 'assets/icon/icons8-user-100.png',
      'rekCd': 'DATA_AKUN',
      'groupProduk': 'DATA_AKUN',
      'color': '0xff1967d2',
      'color2': '0xff03d0ea',
      'isDev': false,
    },
    {
      'title': 'Master Tabungan',
      'desc': 'Migrasi data Tabungan',
      'icon': 'assets/icon/tabrela.png',
      'rekCd': 'TABRELA',
      'groupProduk': 'TABUNGAN',
      'color': '0xff1967d2',
      'color2': '0xff03d0ea',
      'isDev': false,
    },
    // {
    //   'title': 'Master SiMapan Duo',
    //   'desc': 'Migrasi data SiMapan Duo',
    //   'icon': 'assets/icon/tabrela.png',
    //   'rekCd': 'TABDUO',
    //   'groupProduk': 'TABUNGAN',
    //   'color': '0xff0b8043',
    //   'color2': '0xff57bb8a',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Master SiMapan Lestari',
    //   'desc': 'Migrasi data SiMapan Lestari',
    //   'icon': 'assets/icon/tabrela.png',
    //   'rekCd': 'TABLESTARI',
    //   'groupProduk': 'TABUNGAN',
    //   'color': '0xff0b8043',
    //   'color2': '0xff57bb8a',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Master SiMas',
    //   'desc': 'Migrasi data SiMas',
    //   'icon': 'assets/icon/tabrela.png',
    //   'rekCd': 'SIMAS',
    //   'groupProduk': 'TABUNGAN',
    //   'color': '0xff0b8043',
    //   'color2': '0xff57bb8a',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Master Simpanan Anggota',
    //   'desc': 'Migrasi data simpanan anggota',
    //   'icon': 'assets/icon/anggota.png',
    //   'rekCd': 'SIMP_ANGGOTA',
    //   'groupProduk': 'ANGGOTA',
    //   'color': '0xff1967d2',
    //   'color2': '0xff03d0ea',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Master Simpanan Sijapa',
    //   'desc': 'Migrasi data simpanan jangka waktu',
    //   'icon': 'assets/icon/deposito.png',
    //   'rekCd': 'SIRENA',
    //   'groupProduk': 'BERENCANA',
    //   'color': '0xff1967d2',
    //   'color2': '0xff03d0ea',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Master Simpanan Sihari',
    //   'desc': 'Migrasi data simpanan hari raya',
    //   'icon': 'assets/icon/deposito.png',
    //   'rekCd': 'SIHARI',
    //   'groupProduk': 'BERENCANA',
    //   'color': '0xff1967d2',
    //   'color2': '0xff03d0ea',
    //   'isDev': false,
    // },
    // {
    //   'title': 'Data Config',
    //   'desc': 'Migrasi data config',
    //   'icon': 'assets/icon/icons8_config.png',
    //   'rekCd': 'CONFIG',
    //   'groupProduk': 'CONFIG',
    //   'color': '0xff1967d2',
    //   'color2': '0xff03d0ea',
    //   'isDev': false,
    // },
  ];

  @override
  void initState() {
    super.initState();
    var produkProv =
        Provider.of<ProdukCollectionProvider>(context, listen: false);
    produkProv.setTglAwal(_tglAwal);
    produkProv.setTglAkhir(_tglAkhir);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(context, 'Migrasi Data'),
      body: Consumer<ProdukCollectionProvider>(
        builder: (context, mutasiProdukProvider, _) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: deviceWidth(context),
            height: deviceHeight(context),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: getDatePeriode(context),
                ),
                SizedBox(height: 15),
                Divider(),
                _listDaftarMigrasiData(mutasiProdukProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _listDaftarMigrasiData(ProdukCollectionProvider mutasiProdukProvider) {
    print(DateTime.now());
    return Expanded(
      child: Container(
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: dataListMigrasi.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                if (dataListMigrasi[index]['isDev']) {
                  DialogUtils.instance.showError(
                    context: context,
                    text: "Layanan sedang dalam fase pengembangan!",
                  );
                } else {
                  mutasiProdukProvider.getDataMigrasi(
                    context: context,
                    rekCd: dataListMigrasi[index]['rekCd'],
                    groupProduk: dataListMigrasi[index]['groupProduk'],
                    descMigrasi: dataListMigrasi[index]['desc'],
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(7)),
                    gradient: LinearGradient(
                      colors: [
                        Color(int.parse(dataListMigrasi[index]['color'])),
                        Color(int.parse(dataListMigrasi[index]['color2'])),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(20),
                    leading: Image.asset(dataListMigrasi[index]['icon']),
                    title: Text(
                      dataListMigrasi[index]['title'],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      dataListMigrasi[index]['desc'],
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget _getDatePeriodeMigrasi(ProdukCollectionProvider mutasiProdukProvider) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 0),
  //     margin: EdgeInsets.only(top: 10),
  //     child: Consumer<ProdukCollectionProvider>(
  //       builder: (context, mutasiProdukProvider, _) {
  //         return Row(
  //           children: <Widget>[
  //             Expanded(
  //               child: DateTimeField(
  //                 format: format,
  //                 onShowPicker: (context, currentValue) {
  //                   return showDatePicker(
  //                     context: context,
  //                     firstDate: DateTime(1900),
  //                     initialDate: DateTime.now(),
  //                     lastDate: DateTime(3100),
  //                     locale: const Locale('id', 'ID'),
  //                   );
  //                 },
  //                 initialValue: mutasiProdukProvider.tglAwal,
  //                 decoration: InputDecoration(
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 onChanged: (currentValue) {
  //                   mutasiProdukProvider.setTglAwal(currentValue, true);
  //                   if (mutasiProdukProvider.tglAwal
  //                           .difference(mutasiProdukProvider.tglAkhir)
  //                           .inDays <
  //                       1) {
  //                     mutasiProdukProvider.setMutasiLoading(true, true);
  //                   }
  //                 },
  //               ),
  //             ),
  //             Container(
  //               margin: EdgeInsets.symmetric(horizontal: 10),
  //               child: Icon(
  //                 Icons.arrow_forward,
  //                 size: 30,
  //                 color: Colors.grey,
  //               ),
  //             ),
  //             Expanded(
  //               child: DateTimeField(
  //                 format: format,
  //                 onShowPicker: (context, currentValue) {
  //                   return showDatePicker(
  //                     context: context,
  //                     firstDate: DateTime(1900),
  //                     initialDate: DateTime.now(),
  //                     lastDate: DateTime(3100),
  //                     locale: const Locale('id', 'ID'),
  //                   );
  //                 },
  //                 initialValue: mutasiProdukProvider.tglAkhir,
  //                 decoration: InputDecoration(
  //                   suffixIcon: Icon(Icons.calendar_today),
  //                 ),
  //                 textAlign: TextAlign.center,
  //                 onChanged: (currentValue) {
  //                   mutasiProdukProvider.setTglAkhir(currentValue, true);
  //                   if (mutasiProdukProvider.tglAkhir
  //                           .difference(mutasiProdukProvider.tglAwal)
  //                           .inDays >
  //                       0) {
  //                     mutasiProdukProvider.setMutasiLoading(true, true);
  //                   }
  //                 },
  //               ),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
}
