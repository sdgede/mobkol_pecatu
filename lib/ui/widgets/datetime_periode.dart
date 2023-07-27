import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../services/viewmodel/transaksi_provider.dart';
import '../../services/viewmodel/produk_provider.dart';
import '../../services/viewmodel/global_provider.dart';
import '../../services/config/config.dart' as config;

GlobalProvider globalProv;
TransaksiProvider trxProv;
final format = DateFormat("dd-MM-yyyy");

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
                child: DateTimeField(
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(3100),
                      locale: const Locale('id', 'ID'),
                    );
                  },
                  initialValue: produkProv.tglAwal,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (currentValue) {
                    produkProv.setTglAwal(currentValue, true);
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
                child: DateTimeField(
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: DateTime.now(),
                      lastDate: DateTime(3100),
                      locale: const Locale('id', 'ID'),
                    );
                  },
                  initialValue: produkProv.tglAkhir,
                  decoration: InputDecoration(
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  textAlign: TextAlign.center,
                  onChanged: (currentValue) {
                    produkProv.setTglAkhir(currentValue, true);
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
            child: DateTimeField(
              format: format,
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  initialDate: DateTime.now(),
                  lastDate: DateTime(3100),
                  locale: const Locale('id', 'ID'),
                );
              },
              initialValue: produkProv.tglAwal,
              decoration: InputDecoration(
                suffixIcon: Icon(Icons.calendar_today),
              ),
              textAlign: TextAlign.right,
              onChanged: (currentValue) {
                produkProv.setTglAwal(currentValue, true);
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
