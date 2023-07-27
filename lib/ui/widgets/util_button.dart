import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget btnTxtAndIcon({
  BuildContext context,
  Color icColor = Colors.black,
  Color txtColor = Colors.black,
  IconData icon,
  String label = '',
  Function onTap,
  bool isEnable = true,
}) {
  return FlatButton.icon(
    disabledColor: Colors.grey,
    padding: EdgeInsets.all(0),
    onPressed: () => isEnable == true ? onTap() : null,
    icon: Icon(
      icon,
      color: isEnable ? icColor : Colors.grey,
    ),
    label: Text(
      label,
      style: TextStyle(
        color: isEnable ? txtColor : Colors.grey,
      ),
    ),
  );
}
