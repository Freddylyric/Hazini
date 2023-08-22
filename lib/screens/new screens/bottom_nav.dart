

import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/screens/new%20screens/home_screen.dart';


import 'package:hazini/screens/new%20screens/profile_screen.dart';

import '../../adapters/user_model.dart';
import 'history_page.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();


}

class _BottomNavState extends State<BottomNav> {
  int currentIndex = 0;


  @override
  void initState() {
    super.initState();



  }

  final screens =[
    HomeScreen(),
    HistoryPage(),
    ProfileScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
        body: screens[currentIndex],



        bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              iconTheme: IconThemeData(color: Color(0xffE5EBEA))
            ),

            child: CurvedNavigationBar(
          height: 60,
          backgroundColor: Colors.transparent,
          color: Color(0xff009BA5),
          buttonBackgroundColor: Color(0xff009BA5),
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 300),
          items: [
            CurvedNavigationBarItem(
              child:  Icon(Icons.home, size: 30,),
              label: 'Home',
              labelStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w500, color: Color(0xffE5EBEA)),
            ),
            CurvedNavigationBarItem(
              child:  Icon(Icons.history, size: 30,),
              label: 'History',
              labelStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w500, color: Color(0xffE5EBEA)),

            ),
            CurvedNavigationBarItem(
              child:  Icon(Icons.person, size: 30,),
              label: 'Profile',
              labelStyle: TextStyle(fontSize: 12,fontWeight: FontWeight.w500, color: Color(0xffE5EBEA)),

            ),
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