import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../adapters/user_model.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel userModel;
  //

  const ProfileScreen( {Key? key, required this.userModel}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  late String storedValue;

  @override
  void initState() {
    super.initState();
    _getPhoneNumber();
  }

  Future<void> _getPhoneNumber() async {
    storedValue = (await _storage.read(key: 'phone_number'))!;
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;
    return SafeArea(
      child: Scaffold(

      body: ListView(

        padding: EdgeInsets.all(20),
        children: [
          Text( widget.userModel.name,
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
                  Text(widget.userModel.name), // Placeholder for name
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email address:'),
                  Text(widget.userModel.email ?? ''), // Placeholder for Email
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('National ID'),
                  Text(widget.userModel.companyId.toString() ?? ''), // Placeholder for ID
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
                  Text(widget.userModel.companyId.toString() ?? ''), // Placeholder for name
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payroll number:'),
                  Text(widget.userModel.companyId.toString() ?? ''), // Placeholder for number
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
                  Text(storedValue ?? '', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor)),
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
              style: styles.purpleUnderlinedText,
            ),
          ),
        ])));
  }
}
