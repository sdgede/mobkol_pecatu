import 'dart:io';
import 'package:animations/animations.dart';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sevanam_mobkol/firebase_options.dart';
import 'package:sevanam_mobkol/services/utils/location_utils.dart';
import 'package:sevanam_mobkol/services/utils/notification_utils.dart';
import 'package:sevanam_mobkol/ui/widgets/dialog/info_dialog.dart';
import 'package:sevanam_mobkol/services/config/config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/config/config.dart' as config;
import 'services/config/router_generator.dart';
import 'services/viewmodel/produk_provider.dart';
import 'services/viewmodel/global_provider.dart';
import 'services/viewmodel/transaksi_provider.dart';
import 'services/utils/platform_utils.dart';
import 'services/utils/connectivity_utils.dart';
import 'setup.dart';
import 'ui/constant/constant.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> firebaseMessagingBackgroundHandler(BuildContext context, RemoteMessage message) async {
  if (message.notification == null) return;
  NotificationUtils.instance.showNotification(context, message.notification?.title ?? "", message.notification?.body ?? "");
}

Future<void> setupFirebaseMessaging(BuildContext context) async {
  FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
    firebaseMessagingBackgroundHandler(context, message);
  });
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    firebaseMessagingBackgroundHandler(context, message);
  });

  try {
    String? token = await messaging.getToken();
    if (token != null) {
      debugPrint("FCM Token: $token");

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? firebaseId = prefs.getString("firebase_id");
      if (firebaseId != '' || firebaseId != null) {
        firebaseId = token;
        prefs.setString('firebase_id', firebaseId);
      }
      config.firebaseId = firebaseId ?? "";
      config.platform = await PlatformUtils.distance.initPlatformState();
    } else {
      debugPrint("FCM Token: failed");
    }
  } catch (e) {
    debugPrint("FCM Token: failed :: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check if Firebase is already initialized, if not, initialize it
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      name: DefaultFirebaseOptions.currentPlatform.projectId,
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    // Use existing Firebase app
    Firebase.app();
  }

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
  bool _modalOpened = false;
  bool _firebaseInitialized = false;

  Future<void> _initFirebase(BuildContext context) async {
    if (_firebaseInitialized) return;
    _firebaseInitialized = true;
    await setupFirebaseMessaging(context);
  }

  @override
  void initState() {
    super.initState();
    _requestIOSPermissions();
    Future.delayed(Duration.zero, () {
      ConnectivityUtils.distance.onCheckConnectivity(navigatorKey.currentState!.overlay!.context);
      _initFirebase(navigatorKey.currentState!.overlay!.context);
    });
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
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
      child: Builder(builder: (context) {
        return MaterialApp(
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
        );
      }),
    );
  }
}
