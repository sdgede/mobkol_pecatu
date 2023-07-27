import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/config/config.dart' as config;
import '../../../services/config/router_generator.dart';
import '../../../services/viewmodel/global_provider.dart';
import '../../../services/viewmodel/produk_provider.dart';
import '../../../database/databaseHelper.dart';
import '../../constant/constant.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseHelper.instance;
  AnimationController animationController;
  Animation<double> animation;
  List<Color> colors = [
    Colors.black,
  ];

  ProdukCollectionProvider produkProv;
  GlobalProvider globalProv;

  int durationSplashScreen = 5;

  startTimeout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('first_time');
    var _redirectPage;

    _redirectPage = RouterGenerator.pageLogin;

    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacementNamed(context, _redirectPage);
    });
  }

  loadAllData() async {
    await dbHelper.database;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var nama = prefs.getString('nama');
    if (nama != "" && nama != null) config.PersonName = nama;

    produkProv.dataProduk(context);
  }

  @override
  void initState() {
    super.initState();

    produkProv = Provider.of<ProdukCollectionProvider>(context, listen: false);
    globalProv = Provider.of<GlobalProvider>(context, listen: false);

    loadAllData();

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

    animation = new CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    animation.addListener(() => this.setState(() {}));
    animationController.forward();

    startTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        position: DecorationPosition.background,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgCustom),
            fit: BoxFit.cover,
          ),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black87.withOpacity(.3),
          //     offset: Offset(0.0, 8.0),
          //     blurRadius: 5.0,
          //   )
          // ],
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: 50,
              right: 50,
              child: FadeTransition(
                opacity: animation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      splashLogo,
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    // Text(
                    //   config.companySlogan,
                    //   style: TextStyle(
                    //     fontWeight: FontWeight.bold,
                    //     letterSpacing: 1.5,
                    //     fontSize: 15,
                    //     color: Colors.black,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // )
                  ],
                ),
              ),
            ),
            // Positioned(
            //   bottom: 50,
            //   left: 50,
            //   right: 50,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       ColorLoader(
            //         colors: colors,
            //         duration: Duration(milliseconds: 1200),
            //       ),
            //     ],
            //   ),
            // ),
            Positioned(
              bottom: 40,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Powered By',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.5,
                      fontSize: 12.5,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Sevanam ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        TextSpan(
                          text: 'Enterprise',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
