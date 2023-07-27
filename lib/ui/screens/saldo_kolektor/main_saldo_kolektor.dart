import 'package:flutter/material.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_ticket_widget/flutter_ticket_widget.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/produk_provider.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/config/config.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../ui/widgets/loader/lottie_loader.dart';
import '../../widgets/floating_action_button.dart';
import '../../constant/constant.dart';
import '../../widgets/app_bar.dart';

class MainSaldoKolektor extends StatefulWidget {
  @override
  _MainSaldoKolektor createState() => _MainSaldoKolektor();
}

class _MainSaldoKolektor extends State<MainSaldoKolektor> {
  ProdukCollectionProvider produkProvider;
  GlobalProvider globalProvider;
  var searchController = TextEditingController();
  double _width, _primaryPadding = 15;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController produkScrollCOntroller;

  @override
  void initState() {
    super.initState();
    produkProvider =
        Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProvider = Provider.of<GlobalProvider>(context, listen: false);
    //produkProvider.refreshSaldoKolektor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionSwitchMode(context),
      appBar: DefaultAppBar(
        context,
        "Saldo Kolektor",
        isCenter: true,
        isRefresh: true,
        onRefresh: () => produkProvider.refreshSaldoKolektor(),
      ),
      key: scaffoldKey,
      body: Consumer<ProdukCollectionProvider>(
        builder: (contex, produkProv, _) {
          if (produkProv.saldoKolektorCollection == null) {
            produkProv.getDataSaldoKolektor(context);
            return LottiePrimaryLoader();
          }
          return Container(
            width: deviceWidth(context),
            height: deviceHeight(context),
            color: Colors.grey.shade200,
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: <Widget>[
                  _ticketViewSaldokol(produkProv.saldoKolektorCollection[0]),
                  SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _ticketViewSaldokol(dynamic produkProv) {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
        left: 15,
        right: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FlutterTicketWidget(
            isCornerRounded: true,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Wrap(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, left: 12.0),
                    child: Row(
                      children: [
                        Image.asset('assets/icon/rp.png',
                            width: 40, height: 40),
                        SizedBox(width: 10),
                        Text(
                          'Saldo Kolektor',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Column(
                      children: <Widget>[
                        Column(
                          children: [
                            if (globalProvider.getConnectionMode == onlineMode)
                              Column(
                                children: [
                                  _fieldTicketViewProduk(
                                    isHeader: true,
                                    headerTxt: 'Kas Awal',
                                  ),
                                  _fieldTicketViewProduk(
                                    firstField: 'Kas Awal Kolektor',
                                    secondField: produkProv.kas_awal,
                                    isCurrency: true,
                                  ),
                                  Divider(),
                                ],
                              ),
                            _fieldTicketViewProduk(
                              isHeader: true,
                              headerTxt: 'Kas Dari Transaksi',
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Kas Masuk',
                              secondField: produkProv.tot_kredit,
                              isCurrency: true,
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Kas Keluar',
                              secondField: produkProv.tot_debet,
                              isCurrency: true,
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Selisih Saldo',
                              secondField: produkProv.tot_saldo,
                              isCurrency: true,
                            ),
                            Divider(),
                            if (globalProvider.getConnectionMode == onlineMode)
                              Column(
                                children: [
                                  _fieldTicketViewProduk(
                                    isHeader: true,
                                    headerTxt: 'Rincian Kas Fisik',
                                  ),
                                  _fieldTicketViewProduk(
                                    firstField: 'Kas Fisik Keluar 1',
                                    secondField: produkProv.kas_keluar1,
                                    isCurrency: true,
                                  ),
                                  _fieldTicketViewProduk(
                                    firstField: 'Kas Fisik Keluar 2',
                                    secondField: produkProv.kas_keluar2,
                                    isCurrency: true,
                                  ),
                                  _fieldTicketViewProduk(
                                    firstField: 'Sisa Kas Fisik',
                                    secondField: produkProv.kas_sisa,
                                    isCurrency: true,
                                  ),
                                  Divider(),
                                ],
                              ),
                            _fieldTicketViewProduk(
                              isHeader: true,
                              headerTxt: 'Transaksi Simpanan Sukarela',
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Kas Masuk',
                              secondField: produkProv.kredit_tab.toString(),
                              isCurrency: true,
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Kas Keluar',
                              secondField: produkProv.debet_tab.toString(),
                              isCurrency: true,
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Selisih Saldo',
                              secondField: produkProv.saldo_tab.toString(),
                              isCurrency: true,
                            ),
                            Divider(),
                            _fieldTicketViewProduk(
                              isHeader: true,
                              headerTxt: 'Transaksi Produk Lainnya',
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Simpanan Anggota',
                              secondField: produkProv.kredit_agt.toString(),
                              isCurrency: true,
                            ),
                            _fieldTicketViewProduk(
                              firstField: 'Tirtayatra',
                              secondField: produkProv.kredit_taberna.toString(),
                              isCurrency: true,
                            ),
                            if (globalProvider.getConnectionMode == onlineMode)
                              Column(
                                children: [
                                  _fieldTicketViewProduk(
                                    firstField: 'Pembayaran Pinjaman',
                                    secondField: produkProv.kredit_kredit,
                                    isCurrency: true,
                                  ),
                                ],
                              ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldTicketViewProduk({
    bool isHeader: false,
    String headerTxt: '-',
    String firstField: '-',
    String secondField: '0',
    bool isCurrency: false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isHeader)
                Text(
                  headerTxt,
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              if (!isHeader)
                Row(
                  children: [
                    SizedBox(height: 25),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        firstField,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (!isHeader)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    (isCurrency)
                        ? TextUtils.instance
                            .numberFormat(secondField.toString() ?? "0")
                        : secondField.toString(),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget dashDivider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Dash(
        direction: Axis.horizontal,
        length: 340,
        dashLength: 12,
        dashColor: Colors.grey.shade400,
      ),
    );
  }
}
