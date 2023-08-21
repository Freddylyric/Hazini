import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/screens/new%20screens/bottom_nav.dart';
import 'package:hazini/screens/new%20screens/home_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../adapters/user_model.dart';

class LoanRepaymentScreen extends StatefulWidget {
  final UserModel userModel;

  const LoanRepaymentScreen({Key? key, required this.userModel,}) : super(key: key);

  @override
  _LoanRepaymentScreenState createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  double? _repayAmount;
  final _storage = const FlutterSecureStorage();


  bool _isProcessing = false;


  void _makeRepayment() async {

    setState(() {
      _isProcessing = true;
    });
    final token = await _storage.read(key: 'token');
    if (token != null && token.isNotEmpty) {
      final url = Uri.parse('https://dev.hazini.com/ussd/initiate-stk-push');
      final requestBody1 = json.encode({'amount': _repayAmount});
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
        body: requestBody1,
      );

      if (response.statusCode == 200) {

        // TODO: Repayment request successful, handle the response accordingly
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Success'),
              content: const Text('Payment Initiated.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    //Navigator.of(context).pop();

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BottomNav()));
                  },
                ),
              ],
            );
          },
        );


      } else {

        //ToDo: Repayment request failed, handle the error
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to initiate repayment. Please try again later.'),
              actions: [
                TextButton(
                  child: const Text('OK'),
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
      _isProcessing = false;
    });
  }





    @override
  Widget build(BuildContext context) {
    final userModel = widget.userModel;

    double amount = double.tryParse(widget.userModel.outstandingLoan?['due_amount'] ?? '0') ?? 0;

    // // Format the amount as currency
    // String formattedAmount = NumberFormat.currency(
    //   symbol: 'KES ',
    // ).format(amount);


    return  Scaffold(

      body:


      SingleChildScrollView(
        child:
          Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 70,),
              Text("Hello ${toTitleCase(userModel.name?? '')},", style: blackSmallText ,),
              SizedBox(height: 5,),
              Text('Repay Current Loan,', style: styles.blackBigText),
              const SizedBox(height: 30,),
              Text('Amount Due: ${NumberFormat.currency(symbol: 'KES ', decimalDigits: 2,).format(double.tryParse(userModel.outstandingLoan? ['due_amount'] ?? '0.0')?? 0.00) }', style: styles.blackBigText),


              const SizedBox(height: 10),
               Text('How much would you like to repay?', style: blackSmallText, ),
              const SizedBox(height: 5,),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 16,),


              Text("Amount", style: styles.blackBigText,),
              const SizedBox(height: 10,),
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
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide:  BorderSide.none,
                      borderRadius: BorderRadius.circular(16),

                    ),
                    hintText: 'Enter Amount',
                    hintStyle: styles.blackSmallText,
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),


                  onChanged: (value) {
                    setState(() {
                      _repayAmount = double.tryParse(value);
                    });
                  },
                ),
              ),
              SizedBox(height: 32),
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
                  onPressed: () {
                    if (_isProcessing) {
                      return null; // Disable the button while processing && _repayAmount! <= amount
                    } else if (_repayAmount != null && _repayAmount! > 0 &&  _repayAmount! <= amount) {
                      _makeRepayment();
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text("Please enter a valid amount."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text("OK"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: _isProcessing
                      ? CircularProgressIndicator() // Show the progress indicator
                      :  Text('REPAY LOAN',  style: GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white),),

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
              SizedBox(height: 20,),
              Center(
                child: TextButton(onPressed: () {
                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ForgotPassword()), (route) => false);
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNav()));
                },

                    child: Text(
                      'CANCEL', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff009BA5)),
                    )


                ),
              )


            ],
          ),
        ),
      ),
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
}
