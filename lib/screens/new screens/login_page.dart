import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hazini/screens/new%20screens/bottom_nav.dart';
import 'package:hazini/screens/new%20screens/forgot_password_page.dart';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../../adapters/user_model.dart';
import 'home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePin = true;
  bool _isLoading = false;

  final _storage = const FlutterSecureStorage();


  String _errorMessage = '';


  late Box<UserModel> _userBox;

  @override
  void initState() {
    super.initState();
    _userBox = Hive.box<UserModel>('userBox');
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  Future <void> _login() async {
    await Hive.box<UserModel>('userBox').clear();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final phoneNumber = formatNumber(_phoneNumberController.text);
    final password = _passwordController.text;

    try {
      print(phoneNumber);
      print(password);
      final response = await http.post(
        Uri.parse('https://dev.hazini.com/ussd/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );



      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['token'];

        //save token &number in secure storage
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'phone_number', value: phoneNumber);


        //Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomNav()),
              (route) => false, // This line removes all the previous routes from the stack
        );

      } else if (response.statusCode == 401) {
        setState(() {
          _errorMessage = 'Invalid credentials. Please try again';
        });
      } else {
        setState(() {
          _errorMessage = 'An error occurred. Please try again';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }
 

  

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Color(0xffE5EBEA),
      body: SingleChildScrollView(
        child: Center(
          child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [

                SizedBox(height: 50,),
                Image(
                  image: AssetImage('assets/images/haz2New.png'),
                  height: 250,
                  width: 350,
                ),
                SizedBox(height: 10,),


                //TODO: Login form with phone number and password textFields

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child:
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
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              labelStyle: GoogleFonts.montserrat( color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),
                              border: OutlineInputBorder(
                                borderSide:  BorderSide.none,
                                borderRadius: BorderRadius.circular(10),

                              )

                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter your phone number';
                              };
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 16,),


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
                            controller: _passwordController,
                            obscureText: _obscurePin,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: GoogleFonts.montserrat( color: Color(0xff515151), fontWeight: FontWeight.w400, fontSize: 14, height: 17),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePin ? Icons.visibility  : Icons.visibility_off, color: Color(0xff009BA5),),
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

                        const SizedBox(height: 20),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 20),


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

                            //onPressed: (){
                            //   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>BottomNav()), (route) => false);
                            // },
                            //   child: Text('SIGN IN', style: GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white),),

                              onPressed: _isLoading ? null :(){
                                if (_formKey.currentState!.validate()) {
                                  _login();
                                }
                              } ,

                              child: _isLoading
                                  ? const CircularProgressIndicator()
                                  : Text('SIGN IN', style: GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white),),

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
                          'FORGOT PASSWORD', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff009BA5)),
                        )




                        )
                      ]
                    )
                  ),
                ),
                //TODO: Login button
                //TODO: Forgot password button
                //TODO: Register button



        ])),
      ),
      
      
    );
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
