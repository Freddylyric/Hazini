import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/main.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../adapters/user_model.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  // final UserModel userModel;
  //

  const ProfileScreen( {Key? key, }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  late String storedValue;

  @override
  void initState() {
    _getPhoneNumber();
    super.initState();

  }

  Future<void> _getPhoneNumber() async {
    storedValue = (await _storage.read(key: 'phone_number'))!;
    setState(() {});
  }

  Future<http.Response> _fetchUserData() async {
    final token = await _storage.read(key: 'token');
    final phoneNumber = await _storage.read(key: 'phone_number');

    final url = Uri.parse('https://dev.hazini.com/search-user-by-phone');
    final headers = {'Authorization': 'Bearer $token'};
    final body = json.encode({'phone_number': phoneNumber});

    return http.post(url, headers: headers, body: body);
  }


  @override
  Widget build(BuildContext context) {

    return SafeArea(
        child: Scaffold(

            body: FutureBuilder<http.Response>(
              future: _fetchUserData(),
              builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else  {
                  final response = snapshot.data!;
                  if (response.statusCode == 200){
                    final Map<String, dynamic> jsonData = json.decode(response.body);
                    final userData = jsonData['users'][0];

                    return ListView(
                        padding: EdgeInsets.all(20),
                        children: [
                          Text( userData['full_names'],
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
                                  Text(userData['full_names']), // Placeholder for name
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Email address:'),
                                  Text(userData['email'] ?? ''), // Placeholder for Email
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('National ID'),
                                  Text(userData['national_id_number'] ?? ''), // Placeholder for ID
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
                                  Text(userData ['company_name'] ?? ''), // Placeholder for name
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Payroll number:'),
                                  Text(userData['payroll_number']['String'] ?? ''),
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
                              // Perform logout actions here
                              _performLogout();

                              // Add logout logic here
                            },
                            child: const Text(
                              'Logout',
                              style: styles.purpleUnderlinedText,
                            ),
                          ),
                        ]
                    );
                  } else {
                    return Center(
                      child: Text('Failed to load user data. Status code: ${response.statusCode}'),
                    );
                  }


                }
              },


            )
        ));
  }


  void _performLogout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'phone_number');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }
}
