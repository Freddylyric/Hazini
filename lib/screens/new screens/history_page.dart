import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


import 'package:google_fonts/google_fonts.dart';
import '../../adapters/user_model.dart';
import '../../utils/styles.dart';
import 'loan_details_screen.dart';


class HistoryPage extends StatefulWidget {

  const HistoryPage({Key? key, }) : super(key: key);



  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final _storage = const FlutterSecureStorage();

  List<Map<String, dynamic>> _loanHistory = []; // Placeholder for loan history data





  @override
  void initState() {
    super.initState();
    _fetchLoanHistory();
  }

  Future<void> _fetchLoanHistory() async {
    final token = await _storage.read(key: 'token');
    final phoneNumber = await _storage.read(key: 'phone_number');

    if (token != null && phoneNumber != null) {
      final url = Uri.parse('https://dev.hazini.com/search-loans-by-phone');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: json.encode({'phone_number': phoneNumber}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final loans = jsonResponse['loans'] as List<dynamic>;

        setState(() {
          _loanHistory = List<Map<String, dynamic>>.from(loans);
        });
      } else {
        // Handle API error
        //print the errors based on API response
        print(response.body);

      }
    }
  }


  String toTitleCase(String text) {
    if (text == null || text.isEmpty) {
      return '';
    }
    return text.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: Color(0xffE5EBEA) ,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Text( _loanHistory.isNotEmpty ? 'Hello ${toTitleCase(_loanHistory[0]['full_names'])},' : 'Hello,',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w400, color: Color(0xff606060)),),
              SizedBox(height: 10,),
              Text("Your loan History", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),

              SizedBox(height: 20,),


              Container(
                height: 400,
                width: double.infinity,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: _loanHistory.length, // Placeholder for number of loans
                  itemBuilder: (context, index) {


                    final loan = _loanHistory[index];
                    bool isActive = loan['status'] == 1;
                    final requestedAt = DateTime.parse(loan['requested_at']);
                    final formattedRequestedAt = DateFormat('MMM dd, yyyy').format(requestedAt);




                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
                        child: ListTile(
                          title: Text(
                            NumberFormat.currency(
                              symbol: 'KES ',
                            ).format(double.tryParse( loan['principal'] ?? '0.00')),
                            style: TextStyle( fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff009BA5)),
                          ), // Placeholder for loan
                          subtitle: Text(formattedRequestedAt, style: TextStyle( fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xff009BA5))), // Placeholder


                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Text(isActive ? 'Active' : 'Inactive', style: isActive ? styles.purpleText: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: Color(0xff5C5C5C) ),), // Placeholder for loan status
                             SizedBox(width: 5),
                              Icon(Icons.arrow_forward_ios, color: isActive ? styles.secondaryColor: Colors.grey,),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoanDetailsScreen(loan: loan),
                              ),
                            );
                            },
                        ));

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
