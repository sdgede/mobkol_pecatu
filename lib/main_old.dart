import 'dart:io';
import 'package:animations/animations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sevanam_mobkol/services/utils/location_utils.dart';
import 'package:sevanam_mobkol/ui/widgets/dialog/info_dialog.dart';
import 'package:sevanam_mobkol/services/config/config.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'firebase_options.dart';
import 'services/config/config.dart' as config;
import 'services/config/router_generator.dart';
import 'services/viewmodel/produk_provider.dart';
import 'services/viewmodel/global_provider.dart';
import 'services/viewmodel/transaksi_provider.dart';
import 'services/utils/platform_utils.dart';
import 'services/utils/connectivity_utils.dart';
import 'setup.dart';
import 'ui/constant/constant.dart';
import 'services/utils/firebase_utils.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
final BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

NotificationAppLaunchDetails? notificationAppLaunchDetails;

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );

  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // IOSInitializationSettings
  var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification: (int id, String? title, String? body, String? payload) async {
        didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id, title: title!, body: body!, payload: payload!));
      });
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    //     onSelectNotification: (String? payload) async {
    //   debugPrint('notification payload: ' + payload!);
    //   selectNotificationSubject.add(payload);
    // }
  );

  await dotenv.load(fileName: ".env");

  setupApp();
  configLoading();
  runApp(MyApp());
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.black
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = false;
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final MethodChannel platform = MethodChannel('crossingthestreams.io/resourceResolver');
  bool _initialized = false;
  bool _modalOpened = false;

  @override
  void initState() {
    super.initState();
    _setFirebaseIdPlatform();
    _initFirebase();
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    Future.delayed(Duration.zero, () {
      ConnectivityUtils.distance.onCheckConnectivity(navigatorKey.currentState!.overlay!.context);
    });
  }

  void _setFirebaseIdPlatform() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? firebaseId = prefs.getString("firebase_id");

    if (firebaseId != '' || firebaseId != null) {
      firebaseId = await _firebaseMessaging.getToken();
      prefs.setString('firebase_id', firebaseId!);
    }

    print('MY FCM : ' + (firebaseId ?? ''));
    config.firebaseId = (firebaseId ?? '');
    config.platform = await PlatformUtils.distance.initPlatformState();
  }

  Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) async {
    print(message);
    if (message.containsKey('data') || Platform.isIOS) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        Platform.isAndroid ? "ANDROID" : "IOS",
        config.companyName,
        channelDescription: config.companyFullName,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        styleInformation: BigTextStyleInformation(''),
      );
      // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
      var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
      // var platformChannelSpecifics = NotificationDetails({
      //     android: androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics
      // });
      var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
        0,
        Platform.isIOS ? message['aps']['alert']['title'] : message['notification']['title'],
        Platform.isIOS ? message['aps']['alert']['body'] : message['notification']['body'],
        platformChannelSpecifics,
        payload: 'Default_Sound',
      );

      FirebaseUtils.instance.setDataFirebase(navigatorKey.currentState!.overlay!.context, message);
    }
    return null;
  }

  Future<dynamic> _initFirebase() async {
    if (!_initialized) {
      _firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
      );
      // _firebaseMessaging.configure(
      //   onMessage: onBackgroundMessage,
      //   onLaunch: onBackgroundMessage,
      //   onResume: onBackgroundMessage,
      // );
      _initialized = true;
    }
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream.listen((ReceivedNotification receivedNotification) async {
      print(receivedNotification);
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != "" ? Text(receivedNotification.title) : null,
          content: receivedNotification.body != "" ? Text(receivedNotification.body) : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) =>
                //         SecondScreen(receivedNotification.payload),
                //   ),
                // );
                print(receivedNotification);
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      // await Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => SecondScreen(payload)),
      // );
      print(payload);
    });
  }

  void _checkLocation() async {
    bool location = await LocationUtils.instance.getLocationOnly();
    if (!_modalOpened && !location) {
      _modalOpened = true;
      return showModal(
        context: navigatorKey.currentState!.overlay!.context,
        configuration: FadeScaleTransitionConfiguration(barrierDismissible: false),
        builder: (context) {
          return InfoDialog(
            title: "Opps...",
            text: "Pastikan Anda mengizinkan $mobileName untuk mengakses lokasi Anda.",
            clickOKText: "OK",
            onClickOK: () async {
              Navigator.of(navigatorKey.currentState!.overlay!.context, rootNavigator: true).pop();
              location = await LocationUtils.instance.getLocationOnly();
              if (!location) AppSettings.openLocationSettings();
              // if (!location)
              //   AppSettings.openAppSettings(type: AppSettingsType.location);
            },
            isCancel: false,
          );
        },
      ).then((value) => _modalOpened = false);
    }
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProdukTabunganProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ProdukCollectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => GlobalProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => TransaksiProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: config.companyName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            accentColor: accentColor,
            backgroundColor: Colors.white,
            cardColor: Colors.white,
          ).copyWith(
            secondary: accentColor,
            background: Colors.white,
            surfaceTint: Colors.white,
          ),
          primaryColor: primaryColor,
          textTheme: GoogleFonts.ubuntuTextTheme(Theme.of(context).textTheme),
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.white,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          pageTransitionsTheme: PageTransitionsTheme(
            builders: {
              TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
              ),
              TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                transitionType: SharedAxisTransitionType.horizontal,
              ),
            },
          ),
        ),
        builder: (BuildContext context, Widget? child) {
          return FlutterEasyLoading(
            child: GestureDetector(
              onTap: () {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
              },
              child: Listener(onPointerUp: (PointerEvent details) => _checkLocation(), child: child),
            ),
          );
        },
        initialRoute: RouterGenerator.pageSplash,
        onGenerateRoute: RouterGenerator.generateRoute,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', 'US'),
          const Locale('id', 'ID'),
        ],
      ),
    );
  }
}
