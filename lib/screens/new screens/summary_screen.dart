import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/adapters/user_model.dart';

import 'package:hazini/screens/new%20screens/loan_repayment_screen.dart';
import 'package:hazini/screens/new%20screens/profile_screen.dart';
import 'package:hazini/widgets/display_tile.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../adapters/customer_model.dart';
import '../../adapters/loan_model.dart';
import '../../adapters/transactions_model.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:hazini/adapters/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:hazini/config.dart' as config;
import 'bottom_nav.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final _storage = const FlutterSecureStorage();

  final _amountController = TextEditingController();

  late String storedValue;
  late String storedToken;
  late String loansRequested = '';
  late String totalPaid = '';
  CustomerModel? _customerDetails; // Initialize with an empty instance

  List<LoanOffer> _loanOffers = [];
  List<TransactionModel> _transactions = [];
  num? _loanLimit = 0;
  num _requestedAmount = 0;

  bool _isLoanInfoExpanded = true;
  bool _loanProcessing = false;
  bool _isRequesting = false;
  bool _showLoanOffers = false;
  bool _isFetchingLoanOffers = false;
  bool _userDataLoaded = false;
  bool _isLoanLimitFetched = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _fetchLoanLimit();
    _readTransactionsFromHive();
    _readCustomerDetailsFromHive();
    _fetchUserData();

    super.initState();
  }

  Future<void> _refreshData() async {
    // Clear the data in Hive
    final customerDetailsBox = await Hive.openBox<CustomerModel>('customer_details');
    customerDetailsBox.clear();
    final transactionBox = await Hive.openBox<TransactionModel>('transactions');
    transactionBox.clear();

    await _storage.delete(key: 'loansRequested');
    await _storage.delete(key: 'totalPaid');

    // Fetch new data
    await _fetchUserData();
    await _fetchTransactions();
  }

  // Method to fetch user data from the API using phone number
  Future<void> _fetchUserData() async {
    final phoneNumber = await _storage.read(key: 'phone_number');
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final url = Uri.parse(config.fetchUserDataUrl);
      final requestBody = json.encode({'phone_number': phoneNumber});
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Create a CustomerDetails object with the response data
        CustomerModel customerDetails = CustomerModel.fromJson(jsonResponse);

        // Save the CustomerDetails object to Hive
        final customerDetailsBox = await Hive.openBox<CustomerModel>('customer_details');
        customerDetailsBox.put('data', customerDetails);


        // Update the state with the fetched customer details
        setState(() {
          _customerDetails = customerDetails;
          _userDataLoaded = true; // Mark data as loaded
        });
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch customer data. Please try again later.'),
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
  }

  Future<void> _fetchTransactions() async {
    final storedToken = (await _storage.read(key: 'token'))!;
    final phoneNumber = await _storage.read(key: 'phone_number');
    final url = Uri.parse(config.fetchTransactionsUrl);

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $storedToken'},
      body: json.encode({'phone_number': phoneNumber}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      loansRequested = jsonResponse['total_loan'];
      totalPaid = jsonResponse['total_paid'];

      await _storage.write(key: 'loansRequested', value: loansRequested);
      await _storage.write(key: 'totalPaid', value: totalPaid);

      final List<dynamic> disbursements = jsonResponse['disbursements'];
      final List<dynamic> payments = jsonResponse['payments'];

      final List<TransactionModel> transactions = [];

      for (final disbursement in disbursements) {
        transactions.add(TransactionModel.fromJson(disbursement));
      }

      for (final payment in payments) {
        transactions.add(TransactionModel.fromJson(payment));
      }

      // Sort transactions by date, most recent first
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Save transactions to Hive
      final transactionsBox = await Hive.openBox<TransactionModel>('transactions');

      await transactionsBox.clear();
      await transactionsBox.addAll(transactions);

      setState(() {
        _transactions = transactions; // Set the state with the fetched data
      });
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<void> _fetchLoanLimit() async {
    final storedToken = (await _storage.read(key: 'token'))!;
    final url = Uri.parse(config.loanLimitUrl);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $storedToken'},
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final loanLimit = jsonResponse['limit'] as int;

      setState(() {
        _loanLimit = loanLimit;
        _isLoanLimitFetched = true;
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

  Future<void> _fetchLoanOffers(num amount) async {
    setState(() {
      _isFetchingLoanOffers = true;
    });
    final storedToken = (await _storage.read(key: 'token'))!;
    final url = Uri.parse('${config.LoanOffersUrl}?amount=$amount');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $storedToken'},
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
        _showLoanOffers = true; // Show loan offers after fetching
      });

      Navigator.push(context, MaterialPageRoute(builder: (context) => _buildLoanOfferScreen()));
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
    setState(() {
      _isFetchingLoanOffers = false;
    });
  }

  void _requestLoan(num amount, int offerId) async {
    setState(() {
      _loanProcessing = true;
    });
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

    setState(() {
      _loanProcessing = false;
    });
  }

  Future<List<TransactionModel>> _readTransactionsFromHive() async {
    final transactionsBox = await Hive.openBox<TransactionModel>('transactions');
    final transactions = transactionsBox.values.toList();

    if (transactions.isEmpty) {
      // If the Hive box is empty, call _fetchTransactions to load new data
      await _fetchTransactions();
      return _transactions;
    } else {
      loansRequested = (await _storage.read(key: 'loansRequested'))!;
      totalPaid = (await _storage.read(key: 'totalPaid'))!;
      setState(() {
        _transactions = transactions;
      });
      return transactions;
    }
  }

  Future<CustomerModel?> _readCustomerDetailsFromHive() async {
    final customerDetailsBox = Hive.box<CustomerModel>('customer_details');
    final customerDetails = customerDetailsBox.get('data');

    if (customerDetails == null ) {
      // If the Hive box is empty, call _fetchUserData to load new data
      await _fetchUserData();
      return _customerDetails;
    } else {
      setState(() {
        _customerDetails = customerDetails;
      });
      return customerDetails;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalLoans = double.tryParse(_customerDetails?.outstandingLoan?['due_amount'] ?? "0.0".toString()) ?? 0.00;
    // Convert _loanLimit to double with proper error handling
    double loanLimit = 0.0;
    if (_loanLimit != null) {
      try {
        loanLimit = double.parse(_loanLimit.toString());
      } catch (e) {
        // Handle parsing error here, e.g., set loanLimit to a default value
        loanLimit = 0.0;
      }
    }
    double availableLoan = loanLimit - totalLoans;

    if (_customerDetails == null && !_isLoanLimitFetched) {
      // Return a loading indicator or some other UI until _userModel is initialized

      return getShimmerLoading();
    } else {
      return RefreshIndicator(
        onRefresh: _refreshData,
        child: Scaffold(
          backgroundColor: Color(0xffE5EBEA),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Summary",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff555555)),
                        ),
                        Text(
                          "Last 3 Months",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff555555)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(0),
                      width: double.infinity,
                      child: GridView.count(
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.2,
                        children: [
                          DisplayTile(tileName: "Loans \nRequested", tileValue: 'KES ${loansRequested}', tileColor: Color(0xff009BA5), dueOn: '', textColor: Color(0xffE5EBEA)),
                          DisplayTile(tileName: 'Total \nPaid', tileValue: 'KES ${totalPaid}', tileColor: Color(0xff5A2F7F), dueOn: '', textColor: Color(0xffE5EBEA)),
                          GestureDetector(
                            onTap: () {
                              _refreshData();
                            },
                            child: DisplayTile(
                                tileName: 'Pending \nLoan',
                                tileValue: '${NumberFormat.currency(
                                  symbol: 'KES ',
                                ).format(double.tryParse(_customerDetails?.outstandingLoan?['due_amount'] ?? '0') ?? 0.00)}',
                                tileColor: Color(0xff009BA5),
                                dueOn: 'Due: ${_customerDetails?.outstandingLoan?['due_on'] ?? ''}',
                                textColor: Color(0xffE5EBEA)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        if (!_userDataLoaded) {
                          // Return a loading indicator or some other UI until _userModel is initialized
                        } else {
                          // Your existing logic when _userModel is initialized
                          if (_customerDetails!.canBorrow == false) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => _buildPendingLoanScreen()));
                          } else if (_customerDetails!.canBorrow == true && _loanLimit != null && !_showLoanOffers) {
                            showModalBottomSheet(
                              enableDrag: true,
                              showDragHandle: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                              ),
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                  return SingleChildScrollView(
                                    child: Container(
                                      // height: MediaQuery.of(context).size.height * 0.8,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Loan Limit:  ${NumberFormat.currency(symbol: 'KES ').format(_loanLimit!)} ",
                                              style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff5C5C5C)),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              "How much do you wish to borrow? ",
                                              style: GoogleFonts.montserrat(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C)),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 50,
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Color(0x2E2E2E40),
                                                    offset: Offset(1, 3),
                                                    blurRadius: 3,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                                color: Colors.white,
                                              ),
                                              child: Center(
                                                child: TextFormField(
                                                  controller: _amountController,
                                                  keyboardType: TextInputType.number,

                                                  onChanged: (value) {
                                                    setState(() {
                                                      _requestedAmount = double.tryParse(_amountController.text) ?? 0;
                                                    });
                                                  },
                                                  //validate that the amount is more than 500
                                                  validator: (value) {
                                                    if (value == null || value.isEmpty) {
                                                      return 'The amount has to be at least 500';
                                                    }
                                                    if (double.tryParse(value) == null) {
                                                      return 'The amount has to be a number';
                                                    }
                                                    if (double.tryParse(value)! < 500) {
                                                      return 'The amount has to be at least 500';
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: "Amount",
                                                    hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                              Text(
                                                "KES 0",
                                                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C)),
                                              ),
                                              Text(
                                                "KES ${_loanLimit}",
                                                style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C)),
                                              ),
                                            ]),
                                            Slider(
                                                value: _requestedAmount.toDouble(),
                                                min: 0,
                                                max: double.tryParse(_loanLimit.toString()) ?? 0,
                                                divisions: _loanLimit as int,
                                                label: _requestedAmount.toString(),
                                                activeColor: Color(0xff009BA5),
                                                onChanged: (value) {
                                                  setState(() {
                                                    _requestedAmount = value.toInt();
                                                    _amountController.text = _requestedAmount.toString();
                                                    //  _fetchLoanOffers(storedToken, _requestedAmount);
                                                  });
                                                }),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              height: 56,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF23B0A5),
                                                    Color(0xFF5357B1),
                                                  ],
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  stops: [0.3, 1.0],
                                                ),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: ElevatedButton(
                                                  onPressed: _isFetchingLoanOffers
                                                      ? null
                                                      : () async {
                                                          if (_formKey.currentState!.validate()) {
                                                            if (_requestedAmount > 0 && _requestedAmount <= _loanLimit!) {
                                                              Navigator.pop(context);
                                                              // _fetchLoanOffers(storedToken, _requestedAmount);
                                                              await _fetchLoanOffers(_requestedAmount);
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
                                                          }
                                                        },
                                                  child: _isFetchingLoanOffers
                                                      ? CircularProgressIndicator()
                                                      : Text(
                                                          'NEXT',
                                                          style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
                                                        ),
                                                  style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                                                    backgroundColor: Colors.transparent,
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    shadowColor: Colors.transparent,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                });
                              },
                            );

                            // Navigator.push(context, MaterialPageRoute(builder: (context) => _buildBorrowForm()));
                          } else if (_showLoanOffers) {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => _buildLoanOfferScreen()));
                          } else {}
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x2E2E2E40),
                              offset: Offset(1, 3),
                              blurRadius: 3,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSummaryRow("Total Loans", "${NumberFormat.currency(symbol: '').format(totalLoans)} KES",
                                      TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xff555555)), TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xff555555))),
                                  _buildSummaryRow("Loan Limit", "${NumberFormat.currency(symbol: '').format(loanLimit)} KES",
                                      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff555555)), TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff555555))),
                                  _buildSummaryRow("Available Loan", "${NumberFormat.currency(symbol: '').format(availableLoan)} KES",
                                      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff555555)), TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xff555555))),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Transactions",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff555555)),
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 400,
                      child: _transactions == null
                          ? ShimmerTransactionsListView() // Show shimmer loading effect while data is loading
                          : _transactions!.isEmpty
                              ? Center(
                                  child: Text('You have not made any transactions yet'),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: _transactions!.length,
                                  // Use transactions.length instead of _transactions.length
                                  itemBuilder: (BuildContext context, int index) {
                                    final transaction = _transactions![index]; // Use transactions[index] instead of _transactions[index]

                                    // Define text color based on transaction type
                                    Color textColor = transaction.transactionType == 'LOAN_DISBURSEMENT'
                                        ? Colors.white // Set text color to white for 'LOAN_DISBURSEMENT'
                                        : Color(0xff555555); // Default text color

                                    return Card(
                                      color: transaction.transactionType == 'LOAN_DISBURSEMENT'
                                          ? Color(0xff5A2F7F) // Set the color to purple for 'LOAN_DISBURSEMENT'
                                          : Color(0xffD9D9D9), // Default color
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              transaction.transactionType == 'LOAN_DISBURSEMENT' || transaction.transactionType == 'OVERPAYMENT_REFUND'
                                                  ? 'Loan Received' // Display 'Loan received' for specified types
                                                  : 'Loan Paid', // Display 'Loan paid' for other types
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                            Text(
                                              '${NumberFormat.currency(
                                                symbol: 'KES ',
                                              ).format(
                                                (double.tryParse(transaction.amount) ?? 0).abs(),
                                              )}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: textColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              DateFormat('yyyy-MM-dd').format(transaction.createdAt),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: textColor,
                                              ),
                                            ),
                                            Container(
                                              width: 135,
                                              child: Text(
                                                'Transaction code: ${transaction.externalReference}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400,
                                                  color: textColor,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLoanOfferScreen() {
    return RefreshIndicator(
      onRefresh: _fetchUserData,
      child: Scaffold(
        backgroundColor: Color(0xffE5EBEA),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 40,
                  ),

                  // Display loan offers dropdown
                  // ... Your UI for displaying loan offers dropdown ...

                  if (_showLoanOffers && _loanOffers.isNotEmpty) ...[
                    Text(
                      'Hello ${toTitleCase(_customerDetails!.name ?? '')},',
                      style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Select your desired loan offer",
                      style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        height: 600,
                        child: ListView.builder(
                          padding: EdgeInsets.all(0),
                          itemCount: _loanOffers.length,
                          itemBuilder: (context, index) {
                            final loanOffer = _loanOffers[index];

                            return Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              shadowColor: Colors.grey,
                              elevation: 4,
                              child: ListTile(
                                minVerticalPadding: 10,
                                title: Text(
                                  'Offer ${index + 1}',
                                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF23B0A5)),
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildOfferInfoRow('Principal:', NumberFormat.currency(symbol: 'KES ').format(loanOffer.principal)),
                                          _buildOfferInfoRow('Interest Rate:', '${loanOffer.interestRate}%'),
                                          _buildOfferInfoRow('Duration:', '${loanOffer.duration} days'),
                                          _buildOfferInfoRow('Due Amount:', NumberFormat.currency(symbol: 'KES ').format(loanOffer.dueAmount)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Icon(Icons.arrow_forward_ios),
                                  ],
                                ),
                                onTap: () {
                                  // Handle tapping on a loan offer here, e.g., request the selected offer.
                                  int offerId = loanOffer.loanProductId;
                                  _requestLoan(_requestedAmount, offerId);

                                  _fetchUserData(); // Refresh user data after requesting a loan
                                  setState(() {
                                    _showLoanOffers = false; // Hide loan offers after requesting
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        )),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingLoanScreen() {
    return RefreshIndicator(
      onRefresh: _fetchUserData,
      child: Scaffold(
        backgroundColor: Color(0xffE5EBEA),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display loan offers dropdown
                // ... Your UI for displaying loan offers dropdown ...
                Text(
                  'Hello ${toTitleCase(_customerDetails!.name ?? '')},',
                  style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),
                ),

                Container(
                  padding: EdgeInsets.all(0),
                  //height: 300,
                  width: double.infinity,
                  child: GridView.count(
                      padding: EdgeInsets.zero,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.6,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        // DisplayTile(tileName: "Total \nLoans", tileValue: 'KES 2,500', tileColor: Color(0xff009BA5), textColor: Color(0xffE5EBEA),),
                        // DisplayTile(tileName: 'Pending \nLoan', tileValue: 'KES 2,500', tileColor: Color(0xff009BA5), textColor: Color(0xffE5EBEA),),
                        // DisplayTile(tileName: 'Total\nPaid', tileValue: 'KES 2,500', tileColor: Color(0xff009BA5), textColor: Color(0xffE5EBEA)),
                        // DisplayTile(tileName: 'Loan\nLimit', tileValue: 'KES 2,500', tileColor: Color(0xffE5EBEA), textColor: Color(0xff009BA5)),
                      ]),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Your loan details",
                  style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                ),

                SizedBox(
                  height: 30,
                ),

                Container(
                  height: 300,
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [
                    BoxShadow(
                      color: Color(0x2E2E2E40),
                      offset: Offset(1, 3),
                      blurRadius: 3,
                      spreadRadius: 1,
                    ),
                  ]),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Amount Due: ${NumberFormat.currency(
                            symbol: 'KES ',
                          ).format(double.tryParse(_customerDetails?.outstandingLoan?['due_amount'] ?? '0') ?? 0.00)}',
                          style: styles.greenLargeText,
                          textAlign: TextAlign.start,
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        _buildLoanInfoRow('Principal', 'KES ${_customerDetails?.outstandingLoan?['principal']?.toString() ?? 0.00}'),
                        _buildLoanInfoRow('Interest', '${_customerDetails?.outstandingLoan?['interest']?.toString() ?? 0.00} %'),
                        _buildLoanInfoRow(
                          'Balance',
                          'KES ${NumberFormat.currency(
                            symbol: '',
                            decimalDigits: 2,
                          ).format(double.tryParse(_customerDetails?.outstandingLoan?['due_amount'] ?? '0') ?? 0.00)}',
                        ),
                        _buildLoanInfoRow('Period', '${_customerDetails?.outstandingLoan?['duration']?.toString() ?? 0} Days'),
                        _buildLoanInfoRow('Date Borrowed', _customerDetails?.outstandingLoan?['requested_at'] ?? ''),
                        _buildLoanInfoRow('Deadline', _customerDetails?.outstandingLoan?['due_on'] ?? '')
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: 30,
                ),
                // Request loan button
                Container(
                  height: 56,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF23B0A5),
                        Color(0xFF5357B1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.3, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoanRepaymentScreen(
                                      customerDetails: _customerDetails!,
                                    )));
                      },
                      child: Text('REPAY LOAN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        backgroundColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shadowColor: Colors.transparent,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C))),
          ),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300, color: Color(0xff5C5C5C))),
        ],
      ),
    );
  }

  Widget _buildLoanInfoRow(
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: styles.blackText),
          ),
          Expanded(
            child: Text(value, style: styles.blackSmallText),
          ),
        ],
      ),
    );
  }

  String toTitleCase(String text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text.split(' ').map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  Widget getShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[350]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
            SizedBox(height: 50),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  )),
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  )),
              Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ))
            ]),
            SizedBox(height: 30),
            Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                )),
            SizedBox(height: 30),
            Container(
              height: 600,
              child: ListView.builder(
                padding: EdgeInsets.all(0),
                itemCount: 5, // You can adjust the number of shimmer items
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22.0),
                      ),
                      child: ListTile(
                        title: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        subtitle: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                        ),
                        trailing: Container(
                          width: 100,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget ShimmerTransactionsListView() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: 5, // You can adjust the number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22.0),
            ),
            child: ListTile(
              title: Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              subtitle: Container(
                width: double.infinity,
                height: 20,
                color: Colors.white,
              ),
              trailing: Container(
                width: 100,
                height: 20,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    TextStyle labelStyle,
    TextStyle valueStyle,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: labelStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}
