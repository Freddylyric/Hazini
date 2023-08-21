import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazini/screens/new%20screens/login_page.dart';
import 'package:http/http.dart' as http;

import 'forgot_password_page.dart';

class OTPConfirmationPage extends StatefulWidget {
  const OTPConfirmationPage({super.key});

  @override
  State<OTPConfirmationPage> createState() => _OTPConfirmationPageState();
}

class _OTPConfirmationPageState extends State<OTPConfirmationPage> {


  TextEditingController _pinController = TextEditingController();
  TextEditingController _confirmPinController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  // final _pinController = TextEditingController();
  // final _confirmPinController = TextEditingController();
  // final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  bool _isVerifying = false;
  String _message = '';

  final _storage = const FlutterSecureStorage();
  late String storedValue;


  @override
  void initState() {
    super.initState();
    _getPhoneNumber();
    _message = '';
  }

  Future<void> _getPhoneNumber() async {
    storedValue = (await _storage.read(key: 'phone_number'))!;
    setState(() {});
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _isVerifying = true;
    });


    final pin = _pinController.text;
    final pin2 = _confirmPinController.text;
    final otp = _otpController.text;



    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('https://dev.hazini.com/ussd/reset-password');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp,
          'password': pin2,
          'phone_number': storedValue,
        }),
      );
      if (response.statusCode == 200) {



        // Password reset success, automatically log in the user
        // logic to save the user session or token
        // and navigate to the home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        // Password reset failed, show an error dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to reset password. Please try again later.'),
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
      _isVerifying = false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(height: 50,),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 80,
                  child: Icon(Icons.lock_person_outlined, size: 80, color: Colors.grey,),
                ),

                SizedBox(height: 40,),

                Text("Reset Password", style: GoogleFonts.montserrat(color: Color(0xff009BA5), fontWeight: FontWeight.w600, fontSize: 18),),
                SizedBox(height: 10,),
                Text("Please enter your OTP and reset your password", style: GoogleFonts.montserrat(color: Color(0xff555555), fontSize: 14, fontWeight: FontWeight.w400, ), textAlign: TextAlign.center,),
                SizedBox(height: 40,),

                Form(
                    key: _formKey,
                    child: Column(
                        children: [

                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:  [
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
                              controller: _otpController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                  labelText: 'OTP',
                                  labelStyle: GoogleFonts.montserrat( color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),
                                  border: OutlineInputBorder(
                                    borderSide:  BorderSide.none,
                                    borderRadius: BorderRadius.circular(10),

                                  )

                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter the OTP';
                                };
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 10,),


                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:  [
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
                              controller: _pinController,
                              obscureText: _obscurePin,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                labelStyle: GoogleFonts.montserrat( color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),
                                suffixIcon: IconButton(
                                    icon: Icon(_obscurePin ? Icons.visibility_off  : Icons.visibility, color: Color(0xff009BA5),),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePin = !_obscurePin;
                                      });
                                    }
                                ),
                                border: OutlineInputBorder(
                                  borderSide:  BorderSide.none,
                                  borderRadius: BorderRadius.circular(10),

                                ),

                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your PIN';
                                } else if (value.length != 5) {
                                  return 'PIN must be 5 digits';
                                }
                                // Add any additional validation logic for the PIN here
                                return null;
                              },

                            ),
                          ),
                          const SizedBox(height: 10),


                          Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              boxShadow:  [
                                BoxShadow(
                                  color: Color(0x2E2E2E40),
                                  offset: Offset(1, 3),
                                  blurRadius: 3,
                                  spreadRadius: 1,
                                ),
                              ],
                              color: Colors.white,
                            ),
                            child:
                            TextFormField(
                              controller: _confirmPinController,
                              keyboardType: TextInputType.number,
                              obscureText: _obscureConfirmPin,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide:  BorderSide.none,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                labelText: 'Confirm Password',
                                labelStyle: GoogleFonts.montserrat( color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),

                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                                    color: Color(0xff009BA5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPin = !_obscureConfirmPin;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please confirm your PIN';
                                } else if (value != _pinController.text) {
                                  return 'PINs do not match';
                                }
                                return null;
                              },
                            ),
                          ),


                          const SizedBox(height: 32),


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
                                onPressed: _isVerifying ? null : () {
                                  if (_formKey.currentState!.validate()) {
                                    _changePassword();
                                    // Add login logic here
                                  }
                                },

                                child: _isVerifying
                                    ? CircularProgressIndicator()
                                    : Text('RESET PASSWORD', style: GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white),),
                                style:  ElevatedButton.styleFrom(

                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(11)
                                  ),

                                  backgroundColor: Colors.transparent,

                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shadowColor: Colors.transparent,

                                )

                            ),
                          ),

                          SizedBox(height: 10,),



                          TextButton(onPressed: () {
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ForgotPassword()), (route) => false);
                          },

                              child: Text(
                                'REQUEST OTP', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff009BA5)),
                              )




                          )
                        ]
                    )
                ),



              ]
            ),
          )
        ),
      ),

    );
  }
}
