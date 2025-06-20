import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/views/colors.dart';
import 'package:weather_app/views/myElevatedButton.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplaschScreenState();
  }
}

class _SplaschScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 90),
            child: Column(
              children: [
                Center(
                  child: Text(
                    'Discover The\n Weather in Your City',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/cloudlysun.png',
                  height: size.height * 0.5,
                ),
                SizedBox(height: 20),

                Text(
                  'Get to know your weather map and\n forecast ahead of eveyone to plan youd day nicely',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Myelevatedbutton(ontap: () {}, text: "Get started"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
