import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:http/http.dart' as http;

import 'otp_confirmation.dart';

class PasswordScreen extends StatefulWidget {
  PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
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
      print(phone);
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
        print(response.body);

        if (response.statusCode == 200) {
          // OTP request success, navigate to the OTP confirmation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPConfirmScreen(),
            ),
          );
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
        print('Error');
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
          appBar: AppBar(
            leading: IconButton(onPressed: () {
              Navigator.of(context).pop();
            }, icon: Icon(Icons.arrow_back, color: styles.secondaryColor),),
            backgroundColor: Colors.white,
            title: Text('REQUEST OTP', style: styles.greenBigText),


          ),
          body: Form(
              key: _formKey,
              child: ListView(
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 16,),
                              Text('Enter your phone number to receive an OTP',
                                style: styles.greenSmallText,
                                textAlign: TextAlign.center,),
                              SizedBox(height: 32,),
                              TextFormField(
                                controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    labelText: 'Phone number',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter your phone number';
                                    }

                                    // additional validation logic for the phone number
                                    return null;
                                  },
                                  // onSaved: (value) {
                                  //   _phone = value;
                                  // }
                              ),
                              SizedBox(height: 32,),

                              ElevatedButton(
                                onPressed: _isLoading ? null: _requestOTP,
                                style: ButtonStyleConstants.primaryButtonStyle,
                                child: _isLoading
                                    ? CircularProgressIndicator()
                                    : Text('Request OTP'),
                              ),
                            ])
                    )
                  ]
              )
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

