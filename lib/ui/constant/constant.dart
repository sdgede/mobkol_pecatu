import 'package:flutter/material.dart';

//* Device size
double deviceWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double deviceHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

double deviceHeightWithoutAppBar(BuildContext context, {double height = 25}) {
  return MediaQuery.of(context).size.height -
      (AppBar().preferredSize.height + height);
}

//colors
Color primaryColor = Color(0xfff78104);
Color accentColor = Color(0xfffaab36);

//images
String bgCustom = "assets/images/bg_custom.jpg";
final String companyLogo = "assets/images/logo.png";
final String splashLogo = "assets/images/logo.png";
final String noDataImage = "assets/images/no_data.png";
final String icDebet = "assets/icon/d_google.png";
final String icCredit = "assets/icon/c_google.png";
final String icHeaderInvoice = "assets/images/header_invoice.png";
final String headerInvoiceImgName = "header_invoice.png";
