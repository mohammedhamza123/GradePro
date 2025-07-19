import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xff00577B);
const kCardRadius = 24.0;
const kCardShadow = [
  BoxShadow(
    color: Colors.grey,
    spreadRadius: 2,
    blurRadius: 7,
    offset: Offset(0, 3),
  ),
];
const kButtonStyle = ButtonStyle(
  backgroundColor: MaterialStatePropertyAll(kPrimaryColor),
  elevation: MaterialStatePropertyAll(4),
  shape: MaterialStatePropertyAll(RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  )),
);
const kTitleTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 20,
  color: kPrimaryColor,
  fontFamily: 'Tajawal',
);
const kBodyTextStyle = TextStyle(
  fontWeight: FontWeight.normal,
  fontSize: 16,
  color: Colors.black,
  fontFamily: 'Tajawal',
); 