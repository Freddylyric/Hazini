

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final Color primaryColor = Color(0xff0B615E);
final Color secondaryColor = Color(0xffB504AF);
final Color backgroundColor = Color(0xffCED9F7);

class ButtonStyleConstants {
  static const double buttonHeight = 50.0;
  static const double buttonWidth = 335.0;
  static const double borderRadius = 16.0;
  static const EdgeInsetsGeometry buttonPadding =
  EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0);
  static const Color primaryColor = Color(0xffB504AF);
  static const Color secondaryColor = Color(0xffCED9F7);

  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    primary: primaryColor,
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    minimumSize: Size(buttonWidth, buttonHeight),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    primary: secondaryColor,
    padding: buttonPadding,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    ),
    minimumSize: Size(buttonWidth, buttonHeight),
  );
}

const greenBigText = TextStyle(
  fontFamily: 'Guerrer Light',
  fontSize: 24,
  fontWeight: FontWeight.w500,
  height: 1.23,
  letterSpacing: 0.5,
  color: Color(0xff0B615E),
);

const purpleText = TextStyle(
    fontFamily: 'Guerrer Light',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Color(0xffB504AF)
);

const whiteText = TextStyle(
    fontFamily: 'Guerrer Light',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Colors.white
);

const blackText = TextStyle(
    fontFamily: 'Guerrer Light',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Colors.black
);
const greenSmallText = TextStyle(
    fontFamily: 'Guerrer Light',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: Color(0xff0B615E)
);

