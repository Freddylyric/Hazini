import 'package:flutter/material.dart';
import 'package:hazini/screens/home_screen.dart';
import 'package:hazini/screens/password_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/adapters/user_model.dart';

import '../utils/styles.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _storage = const FlutterSecureStorage();

  bool _obscurePin = true;
  bool _isLoading = false;

  // String? _phone;
  // String? _pin;
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

      print(response.body);
      print('loginokay');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final token = jsonResponse['token'];

        //save token &number in secure storage
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'phone_number', value: phoneNumber);
        print('token saved');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
      appBar: AppBar(
        backgroundColor: styles.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: styles.secondaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('LOG IN', style: styles.greenBigText,),
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
                const SizedBox(height: 20),

                // Phone number input field
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration:  InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
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
                const SizedBox(height: 20),
                // Pin input field
                TextFormField(
                  controller: _passwordController,
                  keyboardType: TextInputType.number,
                  obscureText: _obscurePin,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    labelText: 'PIN (5 digits)',
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
                    } else if (value.length != 5) {
                      return 'PIN must be 5 digits';
                    }
                    // Add any additional validation logic for the PIN here
                    return null;
                  },
                    // onSaved: (value) {
                    //   _pin = value;
                    // }
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                // Log in button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ButtonStyleConstants.primaryButtonStyle,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Login'),

                ),
                const SizedBox(height: 20),
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
      ]),
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
