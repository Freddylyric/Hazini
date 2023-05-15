import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

import 'otp_confirmation.dart';

class PasswordScreen extends StatefulWidget {
  PasswordScreen({Key? key}) : super(key: key);

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  String? _phone;

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
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 16,),
                Text('Enter your phone number to receive an OTP', style: styles.greenSmallText, textAlign: TextAlign.center,),
                SizedBox(height: 32,),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  decoration:  InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    labelText: 'Phone number',
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
                SizedBox(height: 32,),

                ElevatedButton(
                  onPressed: () {
                    // if (_formKey.currentState!.validate()) {

                    // Add request OTP logic here
                    // }
                    Navigator.push(context, MaterialPageRoute(builder: (context) => OTPConfirmScreen()));
                  },
                  style: ButtonStyleConstants.primaryButtonStyle,
                  child: Text('Request OTP'),
                ),
                 ] )
                )
              ]
            )
    );
  }
}
