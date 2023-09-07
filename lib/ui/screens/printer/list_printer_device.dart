import 'package:flutter/material.dart';
import 'dart:async';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../services/viewmodel/global_provider.dart';
import '../../widgets/app_bar.dart';

class ListPrinterDevice extends StatefulWidget {
  @override
  _ListPrinterDevice createState() => new _ListPrinterDevice();
}

class _ListPrinterDevice extends State<ListPrinterDevice> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  GlobalProvider? globalProv;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _device;
  bool _connected = false;
  bool _pressed = false;
  String? pathImage;

  @override
  void initState() {
    super.initState();
    globalProv = Provider.of<GlobalProvider>(context, listen: false);
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      print('ERR_404');
    }

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
        appBar: DefaultAppBar(
          context,
          "List printer device",
          isCenter: true,
          isRefresh: false,
        ),
        body: Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _devices.length,
            physics: BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              var listDevice = _devices[index];
              return Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        globalProv!.setSelectedPrinter(listDevice);
                        globalProv!.setSelectedPrinterName(listDevice.name!);
                        Navigator.of(context, rootNavigator: true).pop(context);
                      },
                      onLongPress: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey.shade200),
                          ),
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.bluetooth,
                                color: Colors.blue,
                              ),
                            ],
                          ),
                          title: Text(
                            listDevice.name!,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            listDevice.address!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              //Icon(FlutterIcons.ios_arrow_forward_ion),
                            ],
                          ),
                          isThreeLine: true,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
