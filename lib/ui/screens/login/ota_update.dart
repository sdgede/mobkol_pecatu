import 'package:flutter/material.dart';
import 'package:sevanam_mobkol/services/config/config.dart';
import 'package:sevanam_mobkol/ui/constant/constant.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

final _shorebirdUpdater = ShorebirdUpdater();

class OtaUpdatePage extends StatefulWidget {
  @override
  State<OtaUpdatePage> createState() => _OtaUpdatePageState();
}

class _OtaUpdatePageState extends State<OtaUpdatePage> {
  final _isShorebirdAvailable = _shorebirdUpdater.isAvailable;
  bool downloading = false;
  bool updated = false;

  Future<void> _downloadUpdate() async {
    setState(() {
      downloading = true;
    });

    try {
      await Future.wait([
        _shorebirdUpdater.update(),
        Future<void>.delayed(const Duration(milliseconds: 500)),
      ]);

      setState(() {
        downloading = false;
        updated = true;
      });
    } on UpdateException catch (error) {
      // Handle error
      setState(() {
        downloading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh pembaharuan: ${error.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget downloadingUpdate() {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 3),
            height: 14,
            width: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: accentColor,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Mengunduh pembaharuan...',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget restartApp() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Text(
            '* Aplikasi berhasil diperbaharui. Silahkan restart aplikasi.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            height: 50,
            child: primaryButton(
              onPress: () => Restart.restartApp(),
              title: 'Restart Aplikasi',
            ),
          ),
        ],
      ),
    );
  }

  Widget updateApp() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 50,
        child: primaryButton(
          onPress: _downloadUpdate,
          title: "Perbaharui",
        ));
  }

  Widget primaryButton({
    void Function()? onPress,
    required String title,
  }) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, accentColor],
        ),
        borderRadius: BorderRadius.circular(6.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black87.withOpacity(.2),
            offset: Offset(0.0, 5.0),
            blurRadius: 8.0,
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPress,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 30,
        ),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/icon/logo.png',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        width: 70,
                        height: 70,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Perbaharui aplikasi anda ke versi terbaru',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 40,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                          'Pembaharuan tersedia untuk aplikasi $mobileName. Lakukan pembaruan untuk meningkatkan pengalaman pengguna.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1),
                    ],
                  ),
                ),
              ),
              Builder(builder: (context) {
                if (_isShorebirdAvailable) {
                  if (downloading) {
                    return downloadingUpdate();
                  }

                  if (updated) {
                    return restartApp();
                  }

                  return updateApp();
                }
                return Text(
                  'Terjadi kesalahan. Silahkan buka ulang aplikasi.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                );
              })
            ],
          ),
        ),
      )),
    );
  }
}
