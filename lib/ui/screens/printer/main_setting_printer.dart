import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../widgets/app_bar.dart';
import '../../constant/constant.dart';
import '../../../model/global_model.dart';
import '../../../services/config/config.dart';
import '../../../services/utils/dialog_utils.dart';
import '../../../services/utils/text_utils.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/config/router_generator.dart';

class MainSettingPrinter extends StatefulWidget {
  @override
  _MainSettingPrinter createState() => new _MainSettingPrinter();
}

class _MainSettingPrinter extends State<MainSettingPrinter> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _pressed = false;
  bool _isConnected = false;
  String? pathImage;
  GlobalProvider? globalProv;
  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    initPlatformState();
    initSavetoPath();
  }

  initSavetoPath() async {
    //read and write
    //image max 300px X 300px
    final filename = headerInvoiceImgName;
    var bytes = await rootBundle.load(icHeaderInvoice);
    String dir = (await getApplicationDocumentsDirectory()).path;
    writeToFile(bytes, '$dir/$filename');
    setState(() {
      pathImage = '$dir/$filename';
    });
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];

    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print('ERR_404');
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            _pressed = false;
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            _pressed = false;
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: DefaultAppBar(
          context,
          "Konfigurasi printer",
          isCenter: true,
          isRefresh: false,
        ),
        body: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Consumer<GlobalProvider>(
                      builder: (contex, globalProv, _) {
                        return Column(
                          children: <Widget>[
                            SizedBox(height: 20),
                            _headerInfo(globalProv),
                            SizedBox(height: 10),
                            _selectPrinter(),
                            _connectPrinter(context, globalProv),
                            if (_isConnected)
                              Column(
                                children: [
                                  if (clientType == 'KOPERASI')
                                    _btnSamplePrint(
                                      tittle: 'PRINT SAMPLE SIMP ANGGOTA',
                                      printAction: _formatAgt,
                                    ),
                                  _btnSamplePrint(
                                    tittle: 'PRINT SAMPLE TABUNGAN',
                                    printAction: _formatTab,
                                  ),
                                  _btnSamplePrint(
                                    tittle: 'PRINT SAMPLE SIMP BERENCANA',
                                    printAction: _formatJangka,
                                  ),
                                  _btnSamplePrint(
                                    tittle: clientType == 'KOPERASI'
                                        ? 'PRINT SAMPLE SIMP PINJAMAN'
                                        : 'PRINT SAMPLE KREDIT',
                                    printAction: _formatKredit,
                                  ),
                                  _disconnect(),
                                  // _sampleAgt(),
                                  // _sampleTabungan(),
                                  // _samplleJangka(),
                                  // _samplePinjaman(),
                                ],
                              )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerInfo(GlobalProvider globalProv) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: accentColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 30),
          Image.asset(
            "assets/images/bluetooth_logo.png",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 30),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Pilih koneksi printer dan klik connect printer untuk menghubungkan device anda",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              "Pastikan Bluetooth Anda telah aktif untuk dapat menggunakan fitur ini!",
              style: TextStyle(fontSize: 13, color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "SELECTED PRINTER : ",
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              globalProv.getSelectedPrinterName == null
                  ? "-"
                  : globalProv.getSelectedPrinterName,
              style: TextStyle(fontSize: 12, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _selectPrinter() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                RouterGenerator.listPrinterDevice,
              );
            },
            child: Center(
              child: Text(
                'Select printer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _disconnect() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              bool confirm = await DialogUtils.instance.dialogConfirm(
                context,
                'Disconnect printer from your device?',
              );
              if (confirm) {
                bluetooth.disconnect();
                setState(
                  () {
                    _pressed = true;
                    _isConnected = false;
                  },
                );
              }
            },
            child: Center(
              child: Text(
                'DISCONNECT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _btnSamplePrint({
    String? tittle,
    Function? printAction,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              printAction!();
            },
            child: Center(
              child: Text(
                tittle!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _connectPrinter(BuildContext context, GlobalProvider globalProv) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: globalProv.getSelectedPrinter == null
              ? Colors.grey
              : Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              connectToPrinter(context, globalProv.getSelectedPrinter);
            },
            child: Center(
              child: Text(
                'Connect printer',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void connectToPrinter(BuildContext context, BluetoothDevice? blDevice) {
    if (blDevice == null) {
      alertSnack(context, 'No device selected');
    } else {
      alertSnack(context, 'Printer connected successfully');
      setState(() {
        _isConnected = true;
      });
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(blDevice).catchError((error) {
            setState(() => _pressed = false);
          });
          setState(() => _pressed = true);
        }
      });
    }
  }

//write to app path
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  void _formatTab() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        //tabungan
        bluetooth.printImage(pathImage!);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("SETORAN TUNAI TABUNGAN", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Tanggal    : 10-10-2021 09:10:20", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("No.Slip    : T0000002", 1, 0);
        bluetooth.printCustom("No.Rek     : 001100.0000778", 1, 0);
        bluetooth.printCustom("Nama       : I PUTU SURYA ANTARA", 1, 0);
        bluetooth.printCustom("No.Telp    : 081887776554", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Saldo Awal : Rp 1.000.000", 1, 0);
        bluetooth.printCustom("Total      : Rp 200.000", 1, 0);
        bluetooth.printCustom("(Dua ratus ribu rupiah)", 1, 0);
        bluetooth.printCustom("Saldo Akhir: Rp 1.200.000", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Petugas    : MALIK", 1, 0);
        bluetooth.printCustom("089661348315", 1, 0);
        bluetooth.printCustom("081252797850", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }

  void _formatAgt() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        //tabungan
        bluetooth.printImage(globalProv!.getInvoiceImage);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("SETORAN TUNAI SIMPANAN WAJIB", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Tanggal    : 10-10-2021 09:10:20", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("No.Slip    : T0000003", 1, 0);
        bluetooth.printCustom("No.Rek     : 001100.00006676", 1, 0);
        bluetooth.printCustom("Nama       : I PUTU SURYA ANTARA", 1, 0);
        bluetooth.printCustom("No.Telp    : 081887776554", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Saldo Awal : Rp 1.000.000", 1, 0);
        bluetooth.printCustom("Total      : Rp 200.000", 1, 0);
        bluetooth.printCustom("(Dua ratus ribu rupiah)", 1, 0);
        bluetooth.printCustom("Saldo Akhir: Rp 1.200.000", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Petugas    : MALIK", 1, 0);
        bluetooth.printCustom("089661348315", 1, 0);
        bluetooth.printCustom("081252797850", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }

  void _formatJangka() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        //tabungan
        bluetooth.printImage(pathImage!);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("SETORAN TUNAI TABUNGAN BERJANGKA", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Tanggal    : 10-10-2021 09:10:20", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("No.Slip    : T0000004", 1, 0);
        bluetooth.printCustom("No.Rek     : 001100.000006654", 1, 0);
        bluetooth.printCustom("Nama       : I PUTU SURYA ANTARA", 1, 0);
        bluetooth.printCustom("No.Telp    : 081887776554", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Saldo Awal : Rp 2.000.000", 1, 0);
        bluetooth.printCustom("Total      : Rp 200.000", 1, 0);
        bluetooth.printCustom("(Dua ratus ribu rupiah)", 1, 0);
        bluetooth.printCustom("Saldo Akhir: Rp 2.200.000", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Petugas    : MALIK", 1, 0);
        bluetooth.printCustom("089661348315", 1, 0);
        bluetooth.printCustom("081252797850", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }

  void _formatKredit() async {
    bluetooth.isConnected.then((isConnected) {
      if (isConnected!) {
        //kredit
        bluetooth.printImage(pathImage!);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printCustom("PEMBAYARAN PINJAMAN TUNAI", 1, 1);
        bluetooth.printNewLine();
        bluetooth.printCustom("Tanggal    : 15-06-2021 09:10:20", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("No.Slip    : T0000005", 1, 0);
        bluetooth.printCustom("No.Krdt    : 001100.000001212", 1, 0);
        bluetooth.printCustom("Nama       : I PUTU SURYA ANTARA", 1, 0);
        bluetooth.printCustom("No.Telp    : 081887776554", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Pokok      : Rp 499.084", 1, 0);
        bluetooth.printCustom("Bunga      : Rp 100.916", 1, 0);
        bluetooth.printCustom("Denda      : Rp 0", 1, 0);
        bluetooth.printCustom("Jumlah     : Rp 600.000", 1, 0);
        bluetooth.printCustom("(Enam ratus ribu rupiah)", 1, 0);
        bluetooth.printCustom("Bakidebet  : Rp 10.313.326", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printCustom("Petugas    : MALIK", 1, 0);
        bluetooth.printCustom("089661348315", 1, 0);
        bluetooth.printCustom("081252797850", 1, 0);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth.printNewLine();
      }
    });
  }

  Future _show(String message,
      {Duration duration = const Duration(seconds: 3),
      BuildContext? ctx}) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    ScaffoldMessenger.of(ctx!).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
        duration: duration,
      ),
    );
  }

  void alertSnack(BuildContext ctx, String message) {
    // _scaffoldKey.currentState!.ShowSnackBar(
    ScaffoldMessenger.of(ctx).showSnackBar(
      new SnackBar(
        content: new Text(
          message,
          style: new TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ThermalPrinterAction {
  static ThermalPrinterAction instance = ThermalPrinterAction();

  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  String pathImage = '0', getPathImg = '0';

  dynamic printAction({
    BuildContext? contex,
    SuksesTransaksiModel? dataTrx,
  }) async {
    final _globalProv = Provider.of<GlobalProvider>(contex!, listen: false);
    String rekDesc = dataTrx!.groupProduk == 'KREDIT' ? 'No. Krdit' : 'No Rek';
    String saldoAkhirDesc =
        dataTrx.groupProduk == 'KREDIT' ? 'Bakidebet' : 'Saldo Akhir';

    bluetooth.printImage(_globalProv.getInvoiceImage);
    bluetooth.printNewLine();
    bluetooth.printCustom(dataTrx.kode!, 1, 0);
    bluetooth.printCustom("================================", 1, 0);
    bluetooth.printNewLine();
    bluetooth.printCustom("Tanggal    : " + dataTrx.trxDate! ?? '-', 1, 0);
    bluetooth.printCustom("No.Slip    : " + dataTrx.noReferensi! ?? '-', 1, 0);
    bluetooth.printCustom(rekDesc + "     : " + dataTrx.norek! ?? '-', 1, 0);
    bluetooth.printCustom("Nama       : " + dataTrx.nama! ?? '-', 1, 0);
    bluetooth.printCustom("No.Telp    : " + dataTrx.hp.toString() ?? '-', 1, 0);
    bluetooth.printNewLine();

    if (dataTrx.groupProduk != 'KREDIT')
      bluetooth.printCustom(
          "Saldo Awal : " + _currency(dataTrx.saldo_awal.toString()) ?? '-',
          1,
          0);

    if (dataTrx.groupProduk == 'KREDIT') {
      bluetooth.printCustom(
          "Pokok      : " + _currency(dataTrx.pokok.toString()) ?? '0', 1, 0);
      bluetooth.printCustom(
          "Bunga      : " + _currency(dataTrx.bunga.toString()) ?? '0', 1, 0);
      bluetooth.printCustom(
          "Denda      : " + _currency(dataTrx.denda.toString()) ?? '0', 1, 0);
    }

    bluetooth.printCustom(
        "Jumlah     : " + _currency(dataTrx.jumlah.toString()) ?? '-', 1, 0);

    bluetooth.printCustom("(" + dataTrx.terbilang! + ")", 1, 0);
    bluetooth.printCustom(
        saldoAkhirDesc + ": " + _currency(dataTrx.saldo_akhir.toString()) ??
            '-',
        1,
        0);
    bluetooth.printCustom("--------------------------------", 1, 0);
    bluetooth.printCustom("Petugas    : " + dataTrx.who! ?? '-', 1, 0);
    bluetooth.printCustom("================================", 1, 0);
    bluetooth.printCustom("Mohon dicek kembali.Terima kasih", 1, 0);
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
  }

  dynamic printActionV2({
    BuildContext? contex,
    String? groupProduk,
    String? kode,
    String? trxDate,
    String? noref,
    String? norek,
    String? nama,
    String? hp,
    String? saldoAwal,
    String? pokok,
    String? bunga,
    String? denda,
    String? lateCHarge,
    String? jumlah,
    String? terbilang,
    String? saldoAkhir,
    String? who,
  }) async {
    final _globalProv = Provider.of<GlobalProvider>(contex!, listen: false);
    String rekDesc = groupProduk == 'KREDIT' ? 'No.Krdt' : 'No.Rek';
    String saldoAkhirDesc =
        groupProduk == 'KREDIT' ? 'Bakidebet' : 'Saldo Akhir';

    bluetooth.printImage(_globalProv.getInvoiceImage);
    bluetooth.printNewLine();
    bluetooth.printCustom(kode ?? '-', 1, 1);
    bluetooth.printCustom("================================", 1, 0);
    bluetooth.printNewLine();
    bluetooth.printCustom("Tanggal    : " + trxDate! ?? ' - ', 1, 0);
    bluetooth.printCustom("No.Slip    : " + noref! ?? ' - ', 1, 0);
    if (groupProduk != 'KREDIT')
      bluetooth.printCustom(rekDesc + "     : " + norek! ?? '-', 1, 0);
    else
      bluetooth.printCustom(rekDesc + "    : " + norek! ?? '-', 1, 0);
    bluetooth.printCustom("Nama       : " + nama! ?? ' - ', 1, 0);
    bluetooth.printCustom("No.Telp    : " + hp! ?? ' - ', 1, 0);
    bluetooth.printNewLine();

    if (groupProduk != 'KREDIT')
      bluetooth.printCustom(
          "Saldo Awal : " + _currency(saldoAwal.toString()) ?? '-', 1, 0);

    if (groupProduk == 'KREDIT') {
      bluetooth.printCustom(
          "Pokok      : " + _currency(pokok.toString()) ?? '0', 1, 0);
      bluetooth.printCustom(
          "Bunga      : " + _currency(bunga.toString()) ?? '0', 1, 0);
      bluetooth.printCustom(
          "Denda      : " + _currency(denda.toString()) ?? '0', 1, 0);
    }

    bluetooth.printCustom(
        "Jumlah      : " + _currency(jumlah.toString()) ?? '-', 1, 0);

    bluetooth.printCustom("(" + terbilang! + ")", 1, 0);

    if (groupProduk != 'KREDIT')
      bluetooth.printCustom(
          saldoAkhirDesc + ": " + _currency(saldoAkhir.toString()) ?? '-',
          1,
          0);
    else
      bluetooth.printCustom(
          saldoAkhirDesc + "   : " + _currency(saldoAkhir.toString()) ?? '-',
          1,
          0);
    bluetooth.printCustom("--------------------------------", 1, 0);
    bluetooth.printCustom("Petugas    : " + who! ?? '-', 1, 0);
    bluetooth.printCustom("================================", 1, 0);
    bluetooth.printCustom("Mohon dicek kembali.Terima kasih", 1, 0);
    bluetooth.printNewLine();
    bluetooth.printNewLine();
    bluetooth.printNewLine();
  }

  String _currency(String val) {
    return TextUtils.instance.numberFormat(val ?? '0');
  }
}
