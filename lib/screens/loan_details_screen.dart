import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/screens/new%20screens/home_screen.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';


import 'new screens/bottom_nav.dart';

class LoanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? loan;


  final int loanNumber = 1;
  // final double loanAmount = 5000;

  const LoanDetailsScreen( {Key? key, required this.loan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE5EBEA) ,

      body: Center(

        child: ListView(
          padding: EdgeInsets.all(20),
          children: [

            SizedBox(height: 60,),
            Text("Your loan Details", style: TextStyle(fontSize: 18, fontWeight:FontWeight.w600,color: Color(0xff5C5C5C)),),
            Text(
              'Loan No.${loanNumber.toString()}',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),
            ),
            SizedBox(height: 10),
            Text(
              'KES ${loan? ['principal'].toString() ?? 0.00} ',
              style: styles.greenSmallText,
            ),
            SizedBox(height: 10),
            Text(
              'Amount',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                _buildInfoRow('Principal', 'KES ${loan? ['principal'] ?? '0.00'}'),
                _buildInfoRow('Interest', ' ${loan? ['interest'] ?? '0'} %'),
                _buildInfoRow('Total', 'KES ${loan? ['total_amount'] ?? '0.00'}'),


              ],
            ),
            Divider(height: 32),
            Text(
              'Repayment Plan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Period:'),
                    Text('${loan? ['duration'] ?? '0'} days'), // Placeholder for amount of days
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Repayment date:'),
                    Text('${loan? ['due_on'] ?? ''}'), // Placeholder for amount of days
                  ],
                ),
              ],
            ),
            Divider(height: 32),
            Text(
              'Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
            ),
            SizedBox(height: 20),
            Text('Overdue repayment'), // Placeholder for overdue repayment
            Divider(height: 32),
            ExpansionTile(
              title: Text(
                'Transaction History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
                textAlign: TextAlign.start,
              ),
              trailing: Icon(Icons.expand_more, color: styles.primaryColor,),
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: (double.tryParse(loan?['paid_amount'] ?? '0') ?? 0) > 0
                        ? Text(
                      'Paid amount: ${loan?['paid_amount']}',
                      style: styles.greenSmallText,
                    )
                        :  Text(
                      'Seems like there is no history available for this loan at the moment',
                      style: styles.greenSmallText,
                    ),
                  ),
                ),

              ],
            ),



            ElevatedButton(onPressed: (){
              //TODO: handle close
              Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav()));
            },
              style: ButtonStyleConstants.secondaryButtonStyle,
                child: const Text("Close", style: styles.purpleText,),)
          ],
        ),
      ),
    );
  }



  Widget _buildInfoRow(String label,  String value, ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
            ),
          ),
          Spacer(),

          Text(
            value,
            style: TextStyle( fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff5C5C5C)),
          ),

        ],
      ),
    );
  }

}
