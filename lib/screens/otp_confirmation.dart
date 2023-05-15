import 'package:flutter/material.dart';
import 'package:hazini/screens/home_screen.dart';
import 'package:hazini/screens/password_screen.dart';
import 'package:hazini/screens/sign_up_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;

import '../utils/styles.dart';

class OTPConfirmScreen extends StatefulWidget {
  @override
  _OTPConfirmScreenState createState() => _OTPConfirmScreenState();
}

class _OTPConfirmScreenState extends State<OTPConfirmScreen> {
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePin = true;
  bool _obscureConfirmPin = true;
  String? _phone;
  String? _pin;
  String? _otp;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: styles.backgroundColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: styles.secondaryColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('LOG IN', style: styles.greenBigText,),
          ),
          body: Padding(
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
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter your phone number';
                      //   }
                      //
                      //   // additional validation logic for the phone number
                      //   return null;
                      // },
                      onSaved: (value) {
                        _otp = value;
                      }
                  ),
                  const SizedBox(height: 30),
                  // TextFormField(
                  //     controller: _phoneNumberController,
                  //     keyboardType: TextInputType.phone,
                  //     decoration:  InputDecoration(
                  //       border: OutlineInputBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       labelText: 'Phone number',
                  //     ),
                  //     // validator: (value) {
                  //     //   if (value!.isEmpty) {
                  //     //     return 'Please enter your phone number';
                  //     //   }
                  //     //
                  //     //   // additional validation logic for the phone number
                  //     //   return null;
                  //     // },
                  //     onSaved: (value) {
                  //       _phone = value;
                  //     }
                  // ),

                  // Pin input field
                  TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: _obscurePin,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'PIN',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePin ? Icons.visibility : Icons.visibility_off,
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
                        } else if (value.length != 5) {
                          return 'PIN must be 5 digits';
                        }
                        // Add any additional validation logic for the PIN here
                        return null;
                      },
                      onSaved: (value) {
                        _pin = value;
                      }
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
                      labelText: 'Confirm PIN',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPin ? Icons.visibility : Icons.visibility_off,
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
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                        // Add login logic here
                      // }
                    },
                    style: ButtonStyleConstants.primaryButtonStyle,
                    child: Text('LOG IN'),
                  ),

                  const SizedBox(height: 30),
                  // Forgot PIN text
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PasswordScreen()));
                    },
                    child: const Text(
                      'I forgot my PIN',
                      style: styles.purpleUnderlinedText,
                    ),
                  ),


                ],
              ),
            ),
          ),
        ));
  }
}
