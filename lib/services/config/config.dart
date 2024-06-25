import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//con mode
String onlineMode = "ONLINE";
String offlineMode = "OFFLINE";
dynamic forbidenOffline = ['KREDIT', 'PINJAMAN'];

// api map
String apiMapMobile = dotenv.env['API_MAP_ANDROID_KEY'] ?? '';
String apiMapIOS = dotenv.env['API_MAP_IOS_KEY'] ?? '';

// versi apk
String versiApkMobile = dotenv.env['VERSION_ANDROID'] ?? '';
String versiApkIOS = dotenv.env['VERSION_IOS'] ?? '';

//company profile
String mobileName = dotenv.env['MOBILE_NAME'] ?? '';
String companyName = dotenv.env['COMPANY_NAME'] ?? '';
String companyFullName = dotenv.env['COMPANY_FULL_NAME'] ?? '';
String companySlogan = dotenv.env['COMPANY_SLOGAN'] ?? '';
String companyShortName = dotenv.env['COMPANY_SHORT_NAME'] ?? '';
String nomorCompany = dotenv.env['COMPANY_NOMOR'] ?? '';
String nomorWhatsAppCompany = dotenv.env['COMPANY_NOMOR_WA'] ?? '';
String emailCompany = dotenv.env['COMPANY_EMAIL'] ?? '';
String clientType = dotenv.env['CLIENT_TYPE'] ?? '';

String imageName = dotenv.env['IMAGE_NAME'] ?? '';
String jamAwalVC = "09.00";
String jamAkhirVC = "16.00";

// api berita link
String apiBeritaLink =
    "https://newsapi.org/v2/top-headlines?country=id&category=business&apiKey=";

// api ws link
String vendorApp = dotenv.env['VENDOR_APP'] ?? '';
String baseURL = dotenv.env['BASE_URL'] ?? '';
String iconLink = "${baseURL}assets/icon/";
String urlApiLogin = "${baseURL}Login";
String urlApiNasabah = "${baseURL}Nasabah";
String urlApiNasabahProduk = "${baseURL}Nasabah_tabungan";
String urlApiNasabahKredit = "${baseURL}Nasabah_kredit";
String urlApiNasabahDeposito = "${baseURL}Nasabah_deposito";
String urlApiPembelian = "${baseURL}Pembelian";
String urlApiMerchant = "${baseURL}Merchant";
String urlApiTransaksiTabungan = "${baseURL}Trans_tabungan";
String urlApiTransaksiDeposito = "${baseURL}Trans_deposito";
String urlApiTransaksiKredit = "${baseURL}Trans_kredit";
String urlApiNotifikasi = "${baseURL}Notifikasi";
String urlApiEform = "${baseURL}Eform";
String urlApiTransferBank = "${baseURL}Transfer_bank";
bool isAlvaibleTfBank = false;
String urlImg = "${baseURL}assets/foto/";

// mcrypt
String secretKey = dotenv.env['SECRET_KEY'] ?? '';
String iv = dotenv.env['IV'] ?? '';
String secretKeyMerchant = dotenv.env['SECRET_KEY_MERCHANT'] ?? '';
String ivMerchant = dotenv.env['IV_MERCHANT'] ?? '';
String clientId = dotenv.env['CLIENT_ID'] ?? '';
String clientSecret = dotenv.env['CLIENT_SECRET'] ?? '';

//custom
String SKIP = "Selesai";
String PREVIOUS = "Sebelumnya";
String NEXT = "Selanjutnya";
String Loading = "Loading...";
String Reconnect = "Menghubungkan...";
String ForgetPassword = "Lupa username/password ?";
String PersonName = "User";
String DateSystem = DateFormat("yyyy-MM-dd").format(new DateTime.now());
String Date = DateFormat("dd-MM-yyyy").format(new DateTime.now());
String Greeting = ((DateTime.now().hour >= 0 && DateTime.now().hour < 11)
    ? "Selamat Pagi"
    : ((DateTime.now().hour >= 11 && DateTime.now().hour < 15)
        ? "Selamat Siang"
        : ((DateTime.now().hour >= 15 && DateTime.now().hour < 18)
            ? "Selamat Sore"
            : "Selamat Malam")));
String firebaseId = "0";
String? platform;
String RelateApp = "Aplikasi Terbaru";
String PIN = "PIN Anda";
String payName = "AMM-PAY";
String Jelajahi = "Jelajahi";
Map<String, dynamic> dataLogin = {}, dataSetting = {}, dataUser = {};
List<dynamic>? dataProvider, plnWarning;
String tabName = "TABUNGAN";
String defaultRekSumber = "";
String defaultNamaRekSumber = "";
String defaultPemilikNamaRekSumber =
    defaultRekSumber + " - " + defaultNamaRekSumber;
String currentRoutes = "/";

// updates
const MANDATORY_UPDATE = 'MANDATORY';
const NORMAL_UPDATE = 'NORMAL_UPDATE';
const NO_UPDATE = 'NO_UPDATE';
const MAINTENANCE = 'MAINTENANCE';
