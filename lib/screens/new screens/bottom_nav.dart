

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/screens/new%20screens/home_screen.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hazini/screens/new%20screens/profile_page.dart';

import 'history_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;

  final screens = [
    HomeScreen(),
    HistoryPage(),
    ProfilePage(),





  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: screens[currentIndex],



        bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: IconThemeData(color: Colors.white)
            ),

            child: CurvedNavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          color: Color(0xff009BA5),
          buttonBackgroundColor: Color(0xff009BA5),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: <Widget>[
            Icon(Icons.home, size: 30, ),
            Icon(Icons.history, size: 30,),
            Icon(Icons.person, size: 30,),
          ],
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },






        ))

    );
  }


}