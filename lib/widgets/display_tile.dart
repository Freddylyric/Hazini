import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class DisplayTile extends StatelessWidget {
  final String tileName;
  final String tileValue;
  final String dueOn;
  final Color tileColor;
  final Color textColor;



  const DisplayTile({
    required this.tileName,
    required this.tileValue,
    required this.tileColor,
    required this.dueOn,
    required this.textColor,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
          color: tileColor,
          borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E2E2E40),
            offset: Offset(1, 3),
            blurRadius: 3,
            spreadRadius: 1,
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tileName,
            style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 1 , color: textColor),textAlign: TextAlign.left, ),
          // Spacer(),

          Text(
            tileValue,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textColor
            ),

          ),
          Text(
            dueOn,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: textColor
            ),

          ),

        ],
      ),
    );
  }
}
