import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/screens/new%20screens/bottom_nav.dart';
import 'package:http/http.dart' as http;
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/adapters/loan_model.dart';
import 'package:intl/intl.dart';

import '../utils/styles.dart';
import 'new screens/home_screen.dart';

class RequestScreen extends StatefulWidget {
  const RequestScreen({Key? key}) : super(key: key);

  @override
  State<RequestScreen> createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
  bool _isExpanded = true;
  final _storage = const FlutterSecureStorage();
  late String storedValue;
  late String storedToken;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();

  int? _loanLimit;
  int _requestedAmount = 0;
  List<LoanOffer> _loanOffers = [];

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  Future<void> _getToken() async {
    storedToken = (await _storage.read(key: 'token'))!;
    if (storedToken != null && storedToken.isNotEmpty) {
      _fetchLoanLimit(storedToken);
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
      final loanLimit = jsonResponse['limit'] as int;

      setState(() {
        _loanLimit = loanLimit;
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: const Text('Failed to fetch loan limit. Please try again later.'),
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

  Future<void> _fetchLoanOffers(String token, int amount) async {
    final url = Uri.parse('https://dev.hazini.com/ussd/loan-offers?amount=$amount');
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

  void _requestLoan(int amount, int offerId) async {
    final token = await _storage.read(key: 'token');

    if (token != null && token.isNotEmpty) {
      final url = Uri.parse('https://dev.hazini.com/ussd/process-loan');
      final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
      final body = json.encode({
        'offer_id': offerId,
        'amount': amount,
      });

      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Loan requested successfully.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    //Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav()));
                  },
                ),
              ],
            );
          },
        );
      } else {
        final jsonResponse = json.decode(response.body);
        final errorMessage = jsonResponse['message'] as String;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Loan Failure'),
              content: Text('Failed to request loan. $errorMessage.'),
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
    } else {
      // Handle the case when the token is null or empty
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: styles.secondaryColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: styles.backgroundColor,
        title: Text(
          'Request a Loan',
          style: styles.greenBigText,
        ),
      ),
      body: _loanLimit == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your loan limit is ${NumberFormat.currency(symbol: 'KES ').format(_loanLimit!)}',
                      style: styles.greenBigText,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please enter the amount you wish to borrow:',
                      style: blackText,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          _requestedAmount = int.tryParse(_amountController.text) ?? 0;
                        });
                        if (_requestedAmount > 0 && _requestedAmount <= _loanLimit!) {
                          _fetchLoanOffers(storedToken, _requestedAmount);
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Amount',
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_requestedAmount > 0 && _requestedAmount <= _loanLimit!) {
                            _fetchLoanOffers(storedToken, _requestedAmount);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Please enter a valid amount within your loan limit."),
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
                        child: Text('Fetch Loan Offers'),
                        style: ButtonStyleConstants.primaryButtonStyle,
                      ),
                    ),
                    SizedBox(height: 16),
                    _loanOffers.isEmpty
                        ? Center(
                          child: Text(
                              'No loan offers found',
                              style: styles.greenSmallText,
                            ),
                        )
                        :


                    Container(
                            height: 400,
                            width: double.infinity,
                            child: Column(
                              children: [
                                Text(
                                  "Select a loan offer",
                                  style: greenSmallText,
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _loanOffers.length,
                                    itemBuilder: (context, index) {
                                      LoanOffer offer = _loanOffers[index];
                                      return Card(
                                        child: ExpansionTile(
                                          title: Text(
                                            'Loan Product ID: ${offer.loanProductId}',
                                            style: styles.blackText,
                                          ),
                                          subtitle: Text(
                                            'Principal: ${NumberFormat.currency(symbol: 'KES').format(offer.principal)}',
                                            style: styles.blackText,
                                          ),
                                          initiallyExpanded: false,
                                          children: [
                                            ListTile(
                                              title: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('Interest Rate: ${offer.interestRate} %', style: styles.greenSmallText),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('Duration: ${offer.duration} days', style: styles.greenSmallText),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('Due On: ${offer.dueOn}', style: styles.greenSmallText),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('Due Amount: ${NumberFormat.currency(symbol: 'KES').format(offer.dueAmount)}', style: styles.greenSmallText),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text('Number of Installments: ${offer.numberOfInstallments}', style: styles.greenSmallText),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                ],
                                              ),
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text('Confirm Loan Request'),
                                                      content: Text('Are you sure you want to request this loan?'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(color: Colors.red),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            _requestLoan(_requestedAmount, offer.loanProductId);
                                                            Navigator.of(context).pop();
                                                          },
                                                          child: Text("Request"),
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
