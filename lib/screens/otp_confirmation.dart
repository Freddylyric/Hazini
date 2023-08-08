import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/screens/home_screen.dart';
import 'package:hazini/screens/forgot_password_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:http/http.dart' as http;

import '../utils/styles.dart';
import 'login_screen.dart';

class OTPConfirmScreen extends StatefulWidget {
  @override
  _OTPConfirmScreenState createState() => _OTPConfirmScreenState();
}

class _OTPConfirmScreenState extends State<OTPConfirmScreen> {

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

  final _storage = const FlutterSecureStorage();
  late String storedValue;
  String _message = '';

  String? _pin;
  String? _otp;

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
            builder: (context) => LoginScreen(),
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
          appBar: AppBar(
            backgroundColor: styles.backgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: styles.secondaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Reset you PIN', style: styles.greenBigText,),
          ),
          body: ListView(
            children: [
              Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),

                    // Phone number input field
                    TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration:  InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'OTP',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your OTP';
                          }

                          // additional validation logic for the phone number
                          return null;
                        },

                    ),
                    const SizedBox(height: 30),


                    // Pin input field
                    TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: _obscurePin,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelText: 'New PIN (5 digits)',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePin ? Icons.visibility_off : Icons.visibility,
                              color: Colors.purple,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePin = !_obscurePin;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your PIN';
                          }
                          else if (value.length != 5) {
                            return 'PIN must be 5 digits';
                          }
                          // Add any additional validation logic for the PIN here
                          return null;
                        },

                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _confirmPinController,
                      keyboardType: TextInputType.number,
                      obscureText: _obscureConfirmPin,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Confirm New PIN',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                            color: Colors.purple,
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
                    const SizedBox(height: 30),
// Log in button
                    ElevatedButton(
                      onPressed: _isVerifying ? null : () {
                         if (_formKey.currentState!.validate()) {
                         _changePassword();
                          // Add login logic here
                         }
                      },
                      style: ButtonStyleConstants.primaryButtonStyle,
                      child: _isVerifying
                        ? CircularProgressIndicator()
                      : Text('RESET PIN'),
                    ),

                    const SizedBox(height: 30),
                    // Forgot PIN text
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PasswordScreen()));
                      },
                      child: const Text(
                        'Request OTP',
                        style: styles.purpleUnderlinedText,
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ]),
        );
  }
}
