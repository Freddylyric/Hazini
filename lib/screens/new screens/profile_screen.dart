import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/adapters/customer_model.dart';
import 'package:hazini/adapters/transactions_model.dart';
import 'package:hazini/main.dart';
import 'package:hazini/screens/new%20screens/help_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:google_fonts/google_fonts.dart';
import 'package:hazini/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:hazini/config.dart' as config;
import 'package:shimmer/shimmer.dart';
import '../../adapters/user_model.dart';
import 'forgot_password_page.dart';
import 'login_page.dart';

class ProfileScreen extends StatefulWidget {
  // final UserModel userModel;
  //

  const ProfileScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  late String storedValue;
  late Box<UserModel> userBox;

  @override
  void initState() {
    _getPhoneNumber();

    super.initState();
  }

  Future<void> _getPhoneNumber() async {
    storedValue = (await _storage.read(key: 'phone_number'))!;
    userBox = await Hive.openBox<UserModel>('userBox');

  }

  Future<void> _fetchAndSaveUserData() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse(config.profileDataUrl);
    final headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final userData = UserModel.fromJson(jsonData);


      final userBox = await Hive.openBox<UserModel>('userBox');
      await userBox.put('user', userData); 

      setState(() {});
    } else {
      throw Exception('Failed to load user data. Status code: ${response.statusCode}');
    }
  }


  Future<void> _refreshData() async {
    await _fetchAndSaveUserData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: Scaffold(
          backgroundColor: Color(0xffE5EBEA),
          body: FutureBuilder(
            future: Hive.openBox<UserModel>('userBox'),
            builder: (BuildContext context, AsyncSnapshot<Box<UserModel>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );

            }else{

              final userBox = snapshot.data;

              if (userBox!.isEmpty) {
                // Data doesn't exist in Hive, fetch from API
                _refreshData();
                return getShimmerLoading(); // Use shimmer effect during loading
              } else {
                final userModel = userBox.get('user');
                return RefreshIndicator(
                    onRefresh: _refreshData,
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Color(0xff009BA5),
                                        child: Icon(
                                          Icons.person_2_sharp,
                                          color: Color(0xffE5EBEA),
                                          size: 30,
                                        )),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      toTitleCase(userModel!.fullNames ?? ''),
                                      style: greenLargeText,
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                    //padding: EdgeInsets.all(24),
                                    children: [
                                  Text(
                                    'Your Identity details',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      _buildInfoRow('Full Name:', toTitleCase(userModel.fullNames) ?? ''),
                                      _buildInfoRow('Email Address:', userModel.email![String] ?? ''),
                                      _buildInfoRow('National ID:', userModel.nationalIdNumber ?? ''),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Your Employment Details',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      _buildInfoRow('Company:', userModel.companyName.toString() ?? ''),
                                      _buildInfoRow('Payroll number:', userModel.payrollNumber![String] ?? ''),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    'Your Mobile Money Details',
                                    style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      _buildInfoRow(storedValue ?? '', 'Verified'),
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
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => HelpScreen()));
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Help',
                                          style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(height: 10),
                                        Column(children: [
                                          _buildInfoRow('Privacy Policy', 'Terms & Conditions'),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ForgotPassword()), (route) => false);
                                    },
                                    child: Text(
                                      "Change password",
                                      textAlign: TextAlign.start,
                                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // Perform logout actions here
                                      _performLogout();

                                      // Add logout logic here
                                    },

                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.power_settings_new,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Log out',
                                          style: styles.greyUnderlinedText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                      ),

                );
              }}

            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return getShimmerLoading(); // Display shimmer loading effect
            } else {
              return Center(
                child: Text('An error occurred.'),
              );
            }
          }
    )
      ),
    );

  }

  String toTitleCase(String text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  void _performLogout() async {
    // Clear the Hive database
    await Hive.box<UserModel>('userBox').clear();
    await Hive.box<CustomerModel>('customer_details').clear();
    await Hive.box<TransactionModel>('transactions').clear();

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'phone_number');

    await _storage.deleteAll();

    // Navigate to the landing screen and remove all previous screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // This line removes all the previous routes from the stack
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
            ),
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
          ),
        ],
      ),
    );
  }


  Shimmer getShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[350]!,
      highlightColor: Colors.grey[100]!,
      child: Scaffold(

      ),
    );
  }
}


