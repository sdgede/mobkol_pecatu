import 'package:intl/intl.dart';

//con mode
String onlineMode = "ONLINE";
String offlineMode = "OFFLINE";
dynamic forbidenOffline = ['KREDIT', 'PINJAMAN'];

// api map
String apiMapMobile = "AIzaSyDF_bYDSiB2MLpjE0x-wr6NZPEYjP253_k";
String apiMapIOS = "";

// versi apk
String versiApkMobile = "1.0.3";
String versiApkIOS = "1.0.3";

//company profile
String mobileName = "AWBP Mobile Kolektor";
String companyName = "KOP ARYA WANG BANG PINATIH";
String companyFullName = "Mobile Kolektor";
String companySlogan = "AWBP";
String companyShortName = "AWBP";
String nomorCompany = "0361751392";
String nomorWhatsAppCompany = "0361751392";
String emailCompany = "pusat@mobkol.com";
String clientType = "LPD"; //KOEPRASI OR LPD

String imageName = "YOGAARTHA_";
String jamAwalVC = "09.00";
String jamAkhirVC = "16.00";

// api berita link
String apiBeritaLink =
    "https://newsapi.org/v2/top-headlines?country=id&category=business&apiKey=";

// api ws link
String vendorApp = 'Sevanam Enterprise';
String baseURL = "https://microfis.net/kop_awbp_dev/ws_mobile_kolektor/";
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
String secretKey = "kkdUIKWkxHCmApwB";
String iv = "AmvuNe0vAwbPErKI";
String secretKeyMerchant = "a6DMerCtLink2019";
String ivMerchant = "MercHantLink2019";
String clientId = "2021KOLToGHaArta#*";
String clientSecret = "#*arthAyoGakOl2021";

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
