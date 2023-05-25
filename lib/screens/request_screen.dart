import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

import 'package:hazini/adapters/loan_model.dart';
import 'package:intl/intl.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool _isExpanded = true;
  final _storage = const FlutterSecureStorage();
  late String storedValue;


  List<LoanOffer> _loanOffers = [];


  @override
  void initState() {
    super.initState();
    _getToken();
  }

  Future<void> _getToken() async {
    final token = (await _storage.read(key: 'token'))!;
    if (token != null && token.isNotEmpty) {
      _fetchLoanLimit(token);
      _fetchLoanOffers(token);
    }
    setState(() {});
  }



  Future<void> _fetchLoanLimit(String token) async {
    final url = Uri.parse('https://dev.hazini.com/ussd/loan-limit');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final loanLimit = jsonResponse['limit'];

      // Use the loan limit value as needed
      print('Loan Limit: $loanLimit');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch loan limit. Please try again later.'),
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


  Future<void> _fetchLoanOffers(String token) async {
    final url = Uri.parse('https://dev.hazini.com//ussd/loan-offers?amount=10000');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<LoanOffer> loanOffers = [];

      for (var item in jsonResponse) {
        LoanOffer offer = LoanOffer(
          loanProductId: item['loan_product_id'],
          interestRate: item['interest_rate'],
          duration: item['duration'],
          principal: item['principal'],
          dueOn: item['due_on'],
          dueAmount: item['due_amount'],
          numberOfInstallments: item['number_of_installments'],
        );

        loanOffers.add(offer);
      }

      setState(() {
        _loanOffers = loanOffers;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch loan offers. Please try again later.'),
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



  void _requestLoan(int amount) async {
    // final token = await _storage.read(key: 'token');
    //
    // if (token != null && token.isNotEmpty) {
    //   final url = Uri.parse('https://dev.hazini.com/ussd/process-loan');
    //   final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    //   final body = json.encode({
    //     'offer_id': _loanOffers[0].loanProductId,
    //     'amount': amount,
    //   });
    //
    //   final response = await http.post(
    //     url,
    //     headers: headers,
    //     body: body,
    //   );
    //
    //   if (response.statusCode == 200) {
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: Text('Success'),
    //           content: Text('Loan requested successfully.'),
    //           actions: [
    //             TextButton(
    //               child: Text('OK'),
    //               onPressed: () {
    //                 Navigator.of(context).pop();
    //               },
    //             ),
    //           ],
    //         );
    //       },
    //     );
    //   } else {
    //     showDialog(
    //       context: context,
    //       builder: (BuildContext context) {
    //         return AlertDialog(
    //           title: Text('Error'),
    //           content: Text('Failed to request loan. Please try again later.'),
    //           actions: [
    //             TextButton(
    //               child: Text('OK'),
    //               onPressed: () {
    //                 Navigator.of(context).pop();
    //               },
    //             ),
    //           ],
    //         );
    //       },
    //     );
    //   }
    // } else {
    //
    // }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: styles.secondaryColor,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: styles.backgroundColor,
        title: Text('Request a Loan', style: styles. greenBigText,),
      ),
      body: ListView.builder(
          itemCount: _loanOffers.length,
          itemBuilder: (context, index){
            LoanOffer offer = _loanOffers[index];
            return Card(

              child: ExpansionTile(
                title: Text('Loan Product ID: ${offer.loanProductId}', style: styles.blackText,),
                subtitle: Text('Principal: ${NumberFormat.currency(symbol: 'KES').format(offer.principal)}', style: styles.blackText,),
            // Text(
            // NumberFormat.currency(
            // symbol: 'KES',
            // ).format(_userModel?.balance ?? 0),
                initiallyExpanded: false,


              children: [
                ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Interest Rate: ${offer.interestRate} %', style: styles.greenSmallText),
                    SizedBox(height: 5,),
                    Text('Duration: ${offer.duration} days', style: styles.greenSmallText),
                    SizedBox(height: 5,),
                    Text('Due On: ${offer.dueOn}', style: styles.greenSmallText),
                    SizedBox(height: 5,),
                    Text('Due Amount: ${NumberFormat.currency(symbol: 'KES').format(offer.dueAmount)}', style: styles.greenSmallText),
                    SizedBox(height: 5,),
                    Text('Number of Installments: ${offer.numberOfInstallments}', style: styles.greenSmallText),
                    SizedBox(height: 5,),
                  ],
                ),  onTap: () {
                  // _requestLoan(offer.principal);
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      int loanAmount = 0; // variable to store the loan amount entered by the user

                      return AlertDialog(
                        title: Text('Enter Loan amount'),
                        content: TextField(
                          keyboardType: TextInputType.number,
                          decoration:  InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: 'Amount',
                          ),
                          onSubmitted: (value) {
                            loanAmount = int.parse(value);
                          },
                        ),
                        actions: [TextButton(
                          child: const Text('Cancel'  ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ), TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            if (loanAmount != null && loanAmount > 0) { // Check if loanAmount is not null and greater than zero
                              _requestLoan(loanAmount); // Call the _requestLoan method with the loan amount entered by the user
                              Navigator.pop(context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text("Please enter a valid loan amount."),
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
                        ),

                        ],
                      );
                    },
                  );


                },

                ),
              ],
            ),


            );



      }),
    );
  }
}


