import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazini/screens/new%20screens/login_page.dart';
import 'package:http/http.dart' as http;

import 'otp_confirmation_page.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _phoneNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;






  Future<void> _requestOTP() async {
    setState(() {
      _isLoading = true;
    });

    final phone = formatNumber(_phoneNumberController.text);
    // Validate the phone number
    if (_formKey.currentState!.validate()) {
      await _storage.write(key: 'phone_number', value: phone);

      // Send the OTP request
      try {
        final url = Uri.parse('https://dev.hazini.com/ussd/forgot-password');
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'phone_number': phone,
          }),

        );


        if (response.statusCode == 200) {
          // OTP request success, navigate to the OTP confirmation screen
     Navigator.push(context, MaterialPageRoute(builder: (context)=>OTPConfirmationPage()));
        } else {
          // OTP request failed, show an error dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Invalid Phone number. Please try again.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {

        // Handle and show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred. Please try again later.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffE5EBEA),
        body: SingleChildScrollView(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [

             // SizedBox(height: 50,),

              Image(
                image: AssetImage('assets/images/haz2New.png'),
                height: 250,
                width: 350,
              ),
              Text(
                "Forgot Password",
                style: GoogleFonts.montserrat(color: Color(0xff009BA5), fontWeight: FontWeight.w600, fontSize: 18),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Please enter your phone number to receive your OTP",
                style: GoogleFonts.montserrat(color: Color(0xff555555), fontSize: 14, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 40,
              ),
              Form(
                  key: _formKey,
                  child: Column(children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x2E2E2E40),
                            offset: Offset(1, 3),
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                        color: Colors.white,
                      ),
                      child: TextFormField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: GoogleFonts.montserrat(color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            )),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          ;
                          return null;
                        },
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF23B0A5), Color(0xFF5357B1),],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.3, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton(



                          onPressed: _isLoading ? null: _requestOTP,
                          child: _isLoading
                              ? CircularProgressIndicator()
                              : Text(
                                  'SEND',
                                  style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                            backgroundColor: Colors.transparent,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shadowColor: Colors.transparent,
                          )),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>LoginPage()), (route) => false);
                      },
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff009BA5)),
                      ),
                    ),
                  ])),

              SizedBox(height: 50,),
            ]),


          )),
        ));
  }


  String formatNumber(String phone) {
    if (phone.isEmpty) {
      return '';
    }

    if (phone.startsWith('+') || phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    if (phone.length <= 8) {
      return '';
    }

    String subst = phone.substring(0, 4);

    if (subst.startsWith('+254')) {
      return phone;
    } else if (subst.startsWith('0')) {
      return '+254${phone.substring(1)}';
    } else if (phone.startsWith('254')) {
      return '+$phone';
    } else {
      return '+254$phone';
    }


  }
}
