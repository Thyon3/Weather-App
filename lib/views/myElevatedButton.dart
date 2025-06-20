import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/views/colors.dart';

class Myelevatedbutton extends StatelessWidget {
  const Myelevatedbutton({super.key, required this.ontap, required this.text});
  final void Function() ontap;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: ontap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
        child: Text(
          text,
          style: GoogleFonts.lato(
            textStyle: TextStyle(color: Colors.white),
            fontSize: 35,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
