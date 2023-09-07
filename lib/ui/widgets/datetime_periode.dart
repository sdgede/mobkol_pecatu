import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/viewmodel/transaksi_provider.dart';
import '../../services/viewmodel/produk_provider.dart';
import '../../services/viewmodel/global_provider.dart';

GlobalProvider? globalProv;
TransaksiProvider? trxProv;
final format = "dd-MM-yyyy";

Widget getDatePeriode(BuildContext context, {bool isKlad = false}) {
  return Consumer<ProdukCollectionProvider>(builder: (contex, produkProv, _) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      margin: EdgeInsets.only(top: 10),
      child: Consumer<ProdukCollectionProvider>(
        builder: (context, produkProv, _) {
          return Row(
            children: <Widget>[
              Expanded(
                child: SfDateRangePicker(
                  // dateMask: format,
                  // onShowPicker: (context, currentValue) {
                  //   return showDatePicker(
                  //     context: context,
                  //     firstDate: DateTime(1900),
                  //     initialDate: DateTime.now(),
                  //     lastDate: DateTime(3100),
                  //     locale: const Locale('id', 'ID'),
                  //   );
                  // },
                  // initialValue: produkProv.tglAwal.toString(),
                  enablePastDates: false,
                  initialSelectedDate: produkProv.tglAwal,
                  // decoration: InputDecoration(
                  //   suffixIcon: Icon(Icons.calendar_today),
                  // ),
                  // textAlign: TextAlign.center,

                  onSelectionChanged: (currentValue) {
                    produkProv.setTglAwal(
                        DateTime.parse(currentValue.value.toString()), true);
                    if (produkProv.tglAwal
                            .difference(produkProv.tglAkhir)
                            .inDays <
                        1) {
                      produkProv.setMutasiLoading(true, true);
                      if (isKlad) produkProv.resetMutasiTransaksi();
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.arrow_forward,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: SfDateRangePicker(
                  // dateMask: format,
                  // onShowPicker: (context, currentValue) {
                  //   return showDatePicker(
                  //     context: context,
                  //     firstDate: DateTime(1900),
                  //     initialDate: DateTime.now(),
                  //     lastDate: DateTime(3100),
                  //     locale: const Locale('id', 'ID'),
                  //   );
                  // },
                  // initialValue: produkProv.tglAkhir.toString(),
                  enablePastDates: false,
                  initialSelectedDate: produkProv.tglAkhir,
                  // decoration: InputDecoration(
                  //   suffixIcon: Icon(Icons.calendar_today),
                  // ),
                  // textAlign: TextAlign.center,
                  onSelectionChanged: (currentValue) {
                    produkProv.setTglAkhir(
                        DateTime.parse(currentValue.value.toString()), true);
                    if (produkProv.tglAkhir
                            .difference(produkProv.tglAwal)
                            .inDays >
                        0) {
                      produkProv.setMutasiLoading(true, true);
                      if (isKlad) produkProv.resetMutasiTransaksi();
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  });
}

Widget getSingleDatePeriode(BuildContext context, {bool isKlad = false}) {
  return Consumer<ProdukCollectionProvider>(builder: (contex, produkProv, _) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
      margin: EdgeInsets.only(top: 10),
      child: Consumer<ProdukCollectionProvider>(
        builder: (context, produkProv, _) {
          return Expanded(
            child: SfDateRangePicker(
              // dateMask: format,
              // onShowPicker: (context, currentValue) {
              //   return showDatePicker(
              //     context: context,
              //     firstDate: DateTime(1900),
              //     initialDate: DateTime.now(),
              //     lastDate: DateTime(3100),
              //     locale: const Locale('id', 'ID'),
              //   );
              // },
              // initialValue: produkProv.tglAwal.toString(),
              // decoration: InputDecoration(
              //   suffixIcon: Icon(Icons.calendar_today),
              // ),
              // textAlign: TextAlign.right,
              onSelectionChanged: (currentValue) {
                produkProv.setTglAwal(
                    DateTime.parse(currentValue.value.toString()), true);
                if (produkProv.tglAwal.difference(produkProv.tglAkhir).inDays <
                    1) {
                  produkProv.setMutasiLoading(true, true);
                  if (isKlad) produkProv.resetMutasiTransaksi();
                }
              },
            ),
          );
        },
      ),
    );
  });
}
