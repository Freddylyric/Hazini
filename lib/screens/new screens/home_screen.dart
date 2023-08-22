import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hazini/adapters/user_model.dart';
import 'package:hazini/screens/loan_repayment_screen.dart';
import 'package:hazini/screens/new%20screens/profile_screen.dart';
import 'package:hazini/screens/request_screen.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:google_fonts/google_fonts.dart';

import '../../adapters/loan_model.dart';
import '../../main.dart';
import 'dart:convert';
import 'package:hazini/adapters/user_model.dart';
import 'package:http/http.dart' as http;
import 'bottom_nav.dart';

class HomeScreen extends StatefulWidget {




  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();


  late int _selectedOption;
  late String storedValue;
  late String storedToken;
  late UserModel _userModel;



  List<LoanOffer> _loanOffers = [];
  LoanOffer? _selectedLoanOffer;

  String _repaymentPeriod = '';
  List<String> _repaymentItems = [];
  int _selectedLoanProductId = -1;
  int? _loanLimit;
  num _requestedAmount = 0;

  bool _isLoanInfoExpanded = true;
  bool _loanProcessing = false;
  bool _isRequesting = false;
  bool _showLoanOffers = false;
  bool _isFetchingLoanOffers = false;
  bool _userDataLoaded = false;








  @override
  void initState() {
    _getUserData();
    _getToken();
    // _fetchLoanLimit( storedToken);

    super.initState();

  }



  Future<void> _fetchRepaymentItems(String token, num amount) async {
    await _fetchLoanOffers(storedToken, _requestedAmount);
    // Fetch loan offers here
    // ...
    // Assuming _loanOffers is the list of loan offers fetched


    _repaymentItems = _loanOffers.map((offer) => '${offer.duration} days').toList();

    _repaymentPeriod = _repaymentItems.isNotEmpty ? _repaymentItems[0] : ' ';
  }





  Future<void> _getToken() async {
    storedToken = (await _storage.read(key: 'token'))!;
    if (storedToken != null && storedToken.isNotEmpty) {
     await _fetchLoanLimit(storedToken);
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



  Future<void> _fetchLoanOffers(String token, num amount) async {
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









  // Method to refresh user data
  Future<void> _refreshUserData() async {
    // Clear the user data from the Hive box
    final box = Hive.box<UserModel>('userBox');
    box.clear();

    // Fetch new user data using the phone number from the API
    final phoneNumber = await _storage.read(key: 'phone_number');
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      await _fetchUserData(phoneNumber);
    }
  }



  // Method to fetch user data from the API using phone number
  Future<void> _fetchUserData(String phoneNumber) async {
    final url = Uri.parse('https://dev.hazini.com/ussd');
    final requestBody = json.encode({'phone_number': phoneNumber});
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);


      // Create a UserModel object with the response data
      UserModel user = UserModel(
        name: jsonResponse['name'],
        email: jsonResponse['email'],
        balance: jsonResponse['balance'],
        salary: jsonResponse['salary'],
        kraPin: jsonResponse['kra_pin'],
        maxLoan: jsonResponse['max_loan'],
        status: jsonResponse['status'],
        companyId: jsonResponse['company_id'],
        canBorrow: jsonResponse['can_borrow'],
        cannotBorrowReason: jsonResponse['cannot_borrow_reason'],
        outstandingLoan: jsonResponse['outstanding_loan'],
      );

      // Save the user model to the Hive database
      final box = Hive.box<UserModel>('userBox');
      box.add(user);


      // Update the state with the fetched user data
      setState(() {
        _userModel = user;
      });

    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to fetch user data. Please try again later.'),
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

  //methd to fetch user data from hive
  Future<void> _getUserData() async {
    final box = Hive.box<UserModel>('userBox');
    final user = box.get(0);
    if (user != null) {
      setState(() {
        _userModel = user;
        _userDataLoaded = true;
      });

    } else {
      // Clear the user data from the Hive box
      box.clear();

      // Fetch the user data using the phone number from the API
      final phoneNumber = await _storage.read(key: 'phone_number');
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        await _fetchUserData(phoneNumber);
      }
      setState(() {
        _userDataLoaded = true; // Mark data as loaded
      });

    }
  }



  @override
  Widget build(BuildContext context) {
    if (!_userDataLoaded) {
      // Return a loading indicator or some other UI until _userModel is initialized
      return  const Center(child: CircularProgressIndicator());
    } else {
      // Your existing logic when _userModel is initialized
      if (_userModel.canBorrow == false) {
        return _buildPendingLoanScreen();
      } else if (_userModel.canBorrow == true && _loanLimit != null && !_showLoanOffers) {
        return _buildBorrowForm();
      } else if (_showLoanOffers) {
        return _buildLoanOfferScreen();
      }
      else{
        return const Center(child: CircularProgressIndicator());
      }
    }
  }





  Widget _buildBorrowForm() {
    return Scaffold(
      backgroundColor: Color(0xffE5EBEA),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


              // Display loan limit and borrow form here
              // ... Your UI for displaying loan limit and borrow form ...

              SizedBox(height: 100,),
              Text('Hello ${toTitleCase(_userModel!.name?? '')},', style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),),
              SizedBox(height: 5,),
              Text("Your loan details", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),

              SizedBox(height: 20,),
              Text("Loan Limit:  ${NumberFormat.currency(symbol: 'KES ').format(_loanLimit!)} ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff5C5C5C)),),

              SizedBox(height: 20,),
              Text("Amount ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff5C5C5C)),),

              SizedBox(height: 10,),
              Container(
                height: 56,
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

                child:

                Center(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _requestedAmount = double.tryParse(_amountController.text) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Amount",
                      hintStyle: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),


                    ),
                  ),
                ),

              ),
              SizedBox(height: 20,),

              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("KES 0", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C)),),
                    Text("KES ${_loanLimit}", style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff5C5C5C)),),

                  ]
              ),

              Slider(
                  value: _requestedAmount.toDouble(),
                  min: 0,
                  max: double.tryParse(_loanLimit.toString()) ?? 0,
                  divisions: _loanLimit!,
                  label: _requestedAmount.toString(),
                  activeColor: Color(0xff009BA5),
                  onChanged: (value) {
                    setState(() {
                      _requestedAmount = value.toInt();
                      _amountController.text = _requestedAmount.toString();
                      //  _fetchLoanOffers(storedToken, _requestedAmount);
                    });
                  }),

              SizedBox(height: 10,),



              if (_repaymentItems.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Repayment period ", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff5C5C5C)),),

                    SizedBox(height: 10,),


                    Container(

                      height: 56,
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
                        child: DropdownButton<String>(
                          hint: Text('Select repayment period'),
                          value: _repaymentPeriod,
                          isExpanded: true,
                          elevation: 0,
                          underline: Container(),


                          onChanged: (String? value) {
                            setState(() {
                              _repaymentPeriod = value!;
                              // Save the selected loanProductId based on selected duration
                              _selectedLoanProductId = _loanOffers
                                  .firstWhere((offer) => offer.duration== int.parse(value!.split(' ')[0]))
                                  .loanProductId;

                              _selectedLoanOffer = _loanOffers
                                  .firstWhere((offer) => offer.loanProductId == _selectedLoanProductId);


                              _showLoanOffers = true;
                            });




                          },
                          items: _repaymentItems.map((valueItem) {
                            return DropdownMenuItem<String>(
                                value: valueItem,
                                child: Text(valueItem, style: GoogleFonts.montserrat(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060))));
                          }).toList(),

                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 40,),


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
                    onPressed: _isRequesting || _isFetchingLoanOffers ? null : () {
                      if (_requestedAmount > 0 && _requestedAmount <= _loanLimit!) {
                        // _fetchLoanOffers(storedToken, _requestedAmount);
                        _fetchRepaymentItems(storedToken, _requestedAmount);

                        setState(() {
                          _isFetchingLoanOffers = true; // Show loan offers after fetching
                        });
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

                    child: _isRequesting
                        ? CircularProgressIndicator()
                        : Text('NEXT', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),),
                    style: ElevatedButton.styleFrom(

                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11)
                      ),

                      backgroundColor: Colors.transparent,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shadowColor: Colors.transparent,

                    )

                ),
              ),

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

  Widget _buildLoanOfferScreen() {
    return Scaffold(
      backgroundColor: Color(0xffE5EBEA),
      body:
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 40,),



              // Display loan offers dropdown
              // ... Your UI for displaying loan offers dropdown ...
              Text('Hello ${toTitleCase(_userModel!.name?? '')},',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w400, color: Color(0xff606060)),),
              SizedBox(height: 10,),
              Text("Request loan", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),
              SizedBox(height: 20,),
              Text("Loan limit: ${NumberFormat.currency(symbol: 'KES ').format(_loanLimit?? 0.00)}", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),

              SizedBox(height: 20,),


              Container(
                height: 300,
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child:  Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,


                    children: [
                      Text(
                        'Amount Requested: ${NumberFormat.currency(symbol: 'KES ').format(_selectedLoanOffer?.principal?? 0.00)}',
                        style: styles.greenLargeText, textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10,),

                      _buildOfferInfoRow('Principal', '${NumberFormat.currency(symbol: 'KES ').format(_selectedLoanOffer?.principal?? 0.00)}'),
                      _buildOfferInfoRow('Interest Rate', '${_selectedLoanOffer?.interestRate}%'),
                      _buildOfferInfoRow('Total', '${NumberFormat.currency(symbol: 'KES ').format(_selectedLoanOffer?.dueAmount?? 0.00)}'),
                      _buildOfferInfoRow('Period', '${_selectedLoanOffer?.duration} days'),
                      _buildOfferInfoRow('Deadline', '${_selectedLoanOffer?.dueOn}'),
                      _buildOfferInfoRow('Installments', '${_selectedLoanOffer?.numberOfInstallments}'),

                    ],
                  ),
                ),

              ),

              SizedBox(height: 30,),
              // Request loan button
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
                    onPressed: _loanProcessing ? null : () {
                      if (_selectedLoanProductId != null) {
                        int offerId = _selectedLoanProductId;
                        _requestLoan(_requestedAmount, offerId);
                        _refreshUserData(); // Refresh user data after requesting loan
                        setState(() {
                          _showLoanOffers = false; // Hide loan offers after requesting
                        });
                      } else {
                        // Show error dialog for selecting an offer
                      }
                    },
                    child:  _loanProcessing
                        ? const CircularProgressIndicator()
                        : Text('REQUEST LOAN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      backgroundColor: Colors.transparent,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shadowColor: Colors.transparent,
                    )
                ),
              ),

              Center(
                child: TextButton(onPressed: () {
                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> ForgotPassword()), (route) => false);

                  Navigator.push(context, MaterialPageRoute(builder: (context)=> BottomNav()));

                  //Navigator.pop(context);
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

  Widget _buildPendingLoanScreen() {
    return Scaffold(
      backgroundColor: Color(0xffE5EBEA),

      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        child:

        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40,),



                // Display loan offers dropdown
                // ... Your UI for displaying loan offers dropdown ...
                Text('Hello ${toTitleCase(_userModel!.name?? '')},',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w400, color: Color(0xff606060)),),
                SizedBox(height: 10,),
                Text("Your loan details", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),

                SizedBox(height: 30,),


                Container(
                  height: 300,
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:  Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,


                      children: [
                        Text(
                          'Amount Due: ${NumberFormat.currency(
                            symbol: 'KES ',
                          ).format(double.tryParse(_userModel?.outstandingLoan?['due_amount'] ?? '0')?? 0.00)}',
                          style: styles.greenLargeText, textAlign: TextAlign.start,
                        ),
                        SizedBox(height: 16,),

                        _buildLoanInfoRow('Principal', 'KES ${_userModel?.outstandingLoan?['principal']?.toString() ?? 0.00}'),
                        _buildLoanInfoRow('Interest', '${_userModel?.outstandingLoan?['interest']?.toString() ?? 0.00} %'),
                        _buildLoanInfoRow(
                          'Balance',
                          'KES ${NumberFormat.currency(
                            symbol: '',
                            decimalDigits: 2,
                          ).format(double.tryParse(_userModel?.outstandingLoan?['due_amount'] ?? '0') ?? 0.00)}',
                        ),
                        _buildLoanInfoRow('Period', '${_userModel?.outstandingLoan?['duration']?.toString() ?? 0} Days'),
                        _buildLoanInfoRow('Date Borrowed', _userModel?.outstandingLoan?['requested_at'] ?? ''),
                        _buildLoanInfoRow('Deadline', _userModel?.outstandingLoan?['due_on'] ?? '')

                      ],
                    ),
                  ),

                ),

                SizedBox(height: 30,),
                // Request loan button
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoanRepaymentScreen(userModel: _userModel!,)));
                      },
                      child: Text('REPAY LOAN', style: GoogleFonts.montserrat(fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        backgroundColor: Colors.transparent,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shadowColor: Colors.transparent,
                      )
                  ),
                ),


              ],
            ),
          ),
        ),


      ),
    );
  }




  Widget _buildOfferInfoRow(String label,  String value, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
                label,
                style: styles.blackText
            ),
          ),
          
          Expanded(
            child: Text(
                value,
                style: styles.blackGreyText
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildLoanInfoRow(String label,  String value, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: styles.blackText
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: styles.blackSmallText
            ),
          ),

        ],
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

  void _performLogout() async {

    // Clear the Hive database
    await Hive.box<UserModel>('userBox').clear();

    // final box = Hive.box<UserModel>('userBox');
    //   box.clear();

    // clear secure storage
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'phone_number');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
  }



}
