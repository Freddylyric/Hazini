import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/main.dart';
import 'package:hazini/screens/new%20screens/help_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:google_fonts/google_fonts.dart';
import 'package:hazini/utils/styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../../adapters/user_model.dart';
import 'forgot_password_page.dart';
import 'login_page.dart';

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
    // final phoneNumber = await _storage.read(key: 'phone_number');

    final url = Uri.parse('https://dev.hazini.com/get-user-details');
    final headers = {'Authorization': 'Bearer $token'};
    // final body = json.encode({'phone_number': phoneNumber});

    return http.get(url, headers: headers,);
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

        body: FutureBuilder<http.Response>(
          future: _fetchUserData(),
          builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: getShimmerLoading(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              final response = snapshot.data!;
              if (response.statusCode == 200) {
                // print(response.body);
                // final Map<String, dynamic> jsonData = json.decode(response.body);
                // final userData = jsonData['users'][0];
                final Map<String, dynamic> jsonData = json.decode(response.body);
                final userData = jsonData;


                return Scaffold(

                  backgroundColor: Color(0xffE5EBEA) ,
                 
                  
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      SizedBox(height: 60,),
                      Center(
                       child: Column(
                         children: [
                           CircleAvatar(

                             radius: 20,
                             backgroundColor: Color(0xff009BA5),
                               child: Icon(Icons.person_2_sharp, color: Color(0xffE5EBEA), size: 30,)),
                           SizedBox(height: 5,),
                           Text(toTitleCase(userData['full_names']?? ''), style: greenLargeText,)
                         ],
                       ),
                      ),

                      Expanded(
                        child: ListView(
                            padding: EdgeInsets.all(24),
                            children: [

                              Text(
                                'Your Identity details',
                                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                              ),
                              SizedBox(height: 10),
                              Column(
                                children: [
                                  _buildInfoRow('Full Name:', toTitleCase(userData['full_names'])?? ''),
                                  _buildInfoRow('Email Address:', userData['email']['String'].toString() ?? ''),
                                  _buildInfoRow('National ID:',userData['national_id_number'].toString() ?? ''),


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
                                  _buildInfoRow('Company:', userData ['company_name'].toString() ?? ''),
                                  _buildInfoRow('Payroll number:', userData['payroll_number']['String'].toString() ?? ''),

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
                                onTap:  () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=> HelpScreen()));
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
                                    Column(
                                        children: [
                                          _buildInfoRow('Privacy Policy', 'Terms & Conditions'),
                                        ]
                                    ),
                                  ],
                                ),
                              ),

                              Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                              SizedBox(height: 20,),



                              GestureDetector(
                                onTap: ()  {

                                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ForgotPassword()), (route) => false);

                                },
                                child: Text("Change password",
                                  textAlign: TextAlign.start,
                                  style:GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                                ),
                              ),
                              SizedBox(height: 30,),
                              GestureDetector(
                                onTap: () {
                                  // Perform logout actions here
                                  _performLogout();

                                  // Add logout logic here
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.power_settings_new, color: Colors.red,),
                                     SizedBox(width: 5,),
                                     Text(
                                      'Log out',
                                      style: styles.greyUnderlinedText,
                                    ),
                                  ],
                                ),
                              ),
                            ]
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(
                  child: Text('Failed to load user data. Status code: ${response.statusCode}'),
                );
              }
            }
          },


        )
    );
  }

  String toTitleCase(String text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }




  Widget _buildInfoRow(String label,  String value, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
                label,
                style: GoogleFonts.montserrat( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
            ),
          ),
          Spacer(),

          Text(
              value,
              style: GoogleFonts.montserrat( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
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


  void _performLogout() async {
    // Clear the Hive database
    await Hive.box<UserModel>('userBox').clear();

    await _storage.delete(key: 'token');
    await _storage.delete(key: 'phone_number');

    // Navigate to the landing screen and remove all previous screens from the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // This line removes all the previous routes from the stack
    );
  }

}
