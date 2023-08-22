import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:intl/intl.dart';

import 'package:google_fonts/google_fonts.dart';
import '../../adapters/user_model.dart';
import '../loan_details_screen.dart';


class HistoryPage extends StatefulWidget {

  const HistoryPage({Key? key, }) : super(key: key);



  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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

              SizedBox(height: 30,),
              Text('Hello widget.userModel!.name?? ''},',style: GoogleFonts.montserrat(fontSize: 14,fontWeight: FontWeight.w400, color: Color(0xff606060)),),
              SizedBox(height: 10,),
              Text("Your loan History", style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),),

              SizedBox(height: 20,),


              Container(
                height: 400,
                width: double.infinity,
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: 1, // Placeholder for number of loans
                  itemBuilder: (context, index) {
                    return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(
                            NumberFormat.currency(
                              symbol: 'KES ',
                            ).format(double.tryParse( '0.00')),
                            style: styles.greenSmallText,
                          ), // Placeholder for loan
                          subtitle: Text('', style: styles. greenSmallText,), // Placeholder


                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Active', style: styles.purpleText,), // Placeholder for loan status
                              Icon(Icons.arrow_forward_ios, color: styles.secondaryColor,),
                            ],
                          ),
                          onTap: () {
                            // Navigate to loan details screen
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => LoanDetailsScreen( loan: widget.userModel?.outstandingLoan)),);
                            //
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
