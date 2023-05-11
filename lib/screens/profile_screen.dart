import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

class ProfileScreen extends StatelessWidget {
  //

  const ProfileScreen( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

      body: ListView(

        padding: EdgeInsets.all(20),
        children: [
          Text(
            'username',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'YOUR PROFILE',
            style: styles.greenBigText,
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          SizedBox(height: 10),
          Text(
            'Your identity details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Full names:'),
                  Text('UserName'), // Placeholder for name
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email address:'),
                  Text('email'), // Placeholder for Email
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('National ID'),
                  Text('ID'), // Placeholder for ID
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          SizedBox(height: 10),
          Text(
            'Your employment details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Company'),
                  Text('Company name'), // Placeholder for name
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payroll number:'),
                  Text('number'), // Placeholder for number
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(
            color: Colors.grey,
            thickness: 1,
          ),
          SizedBox(height: 10),
          Text(
            'Your mobile money details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0711223344'),
                  Text('Verified'), // Placeholder for name
                ],
              ),
              SizedBox(height: 10),
              Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              SizedBox(height: 10),
            ],

          ),
          GestureDetector(
            onTap: () {
              // Add logout logic here
            },
            child: const Text(
              'Logout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purpleAccent),
            ),
          ),
        ])));
  }
}
