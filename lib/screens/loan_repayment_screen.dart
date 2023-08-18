import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/screens/new%20screens/home_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
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

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>HomeScreen()));
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

      body: ListView(
        children:[
          Container(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20,),
              const Text('AMOUNT', style: styles.greenBigText),
              const SizedBox(height: 20,),
              Text('Your loan is KES ${NumberFormat.currency(symbol: '', decimalDigits: 2,).format(double.tryParse(userModel.outstandingLoan? ['due_amount'] ?? '0.0')?? 0.00) }', style: styles.greenSmallText),


              const SizedBox(height: 20),
              const Text('How much would you like to repay?', ),
              const SizedBox(height: 10,),
              const Divider(
                color: Colors.grey,
                thickness: 1,
              ),
              const SizedBox(height: 10,),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),

                  ),
                  hintText: 'Enter Amount',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  setState(() {
                    _repayAmount = double.tryParse(value);
                  });
                },
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_isProcessing) {
                    return null; // Disable the button while processing && _repayAmount! <= amount
                  } else if (_repayAmount != null && _repayAmount! > 0 ) {
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
                style: styles.ButtonStyleConstants.primaryButtonStyle,
                child: _isProcessing
                    ? CircularProgressIndicator() // Show the progress indicator
                    : const Text('Repay', style: styles.whiteText),
              ),


            ],
          ),
        ),
      ]),
    );
  }
}
