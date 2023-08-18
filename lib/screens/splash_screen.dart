import 'package:flutter/material.dart';
import 'package:hazini/screens/new%20screens/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _loadScreen();
  }

  Future<void> _loadScreen() async {
    await Future.delayed(Duration(seconds: 5)); // add a delay of 3 seconds

    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginPage()), (route) => false);
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  Scaffold(


      body: Container(

        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
        gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.2, 1.0],
        colors: [
          Color(0xFF23B0A5), // #019BA5
          Color(0xFF5357B1), // #62257B
    ],
    //transform: GradientRotation(360 * (3.1415926 / 45.0)),
    ),
    ),

        child: Center(
          child: Image.asset('assets/images/haziNew.png'),
        ),

      )
    );
  }
}
