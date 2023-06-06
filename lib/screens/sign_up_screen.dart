import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hazini/screens/home_screen.dart';
import 'package:hazini/screens/sign_up_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;

import '../utils/styles.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _phoneNumberController = TextEditingController();
  final _pinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePin = true;
  bool _agree = false;
  String? _phone;
  String? _pin;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _pinController.dispose();
    super.dispose();
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
            title: Text('SIGN UP', style: styles.greenBigText,),
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
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      decoration:  InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        labelText: 'Your phone number',
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
                        _phone = value;
                      }
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
                        labelText: 'Your new Hazini security PIN',
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
                      // validator: (value) {
                      //   if (value!.isEmpty) {
                      //     return 'Please enter your PIN';
                      //   } else if (value.length != 5) {
                      //     return 'PIN must be 5 digits';
                      //   }
                      //   // Add any additional validation logic for the PIN here
                      //   return null;
                      // },
                      onSaved: (value) {
                        _pin = value;
                      }
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Checkbox(
                        value: _agree,
                        onChanged: (value) {
                          setState(() {
                            _agree = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: "I agree to Hazini's ", style: styles.greenSmallText),
                              TextSpan(
                                text: 'Terms of service',
                                style:  styles.greenUnderlinedText,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: add logic to open terms of service link
                                  },
                              ),
                              const TextSpan(text: ' and ', style: styles.greenSmallText),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: styles.greenUnderlinedText,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: add logic to open privacy policy link
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 30),


                  // Log in button
                  ElevatedButton(
                    onPressed: () {
                      // if (_formKey.currentState!.validate()) {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()));
                      // Add signup logic here
                      // }
                    },
                    style: ButtonStyleConstants.primaryButtonStyle,
                    child: Text('Continue'),
                  ),
                  const SizedBox(height: 30),
                  // Forgot PIN text
                  GestureDetector(
                    onTap: () {
                      // Add any "forgot PIN" logic here
                    },
                    child: const Text(
                      'Am already registered',
                      style: styles.purpleUnderlinedText,
                    ),
                  ),


                ],
              ),
            ),
          ),
        );
  }
}
