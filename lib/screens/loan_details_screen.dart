import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

class LoanDetailsScreen extends StatelessWidget {


  final int loanNumber = 1;
  final double loanAmount = 5000;

  const LoanDetailsScreen( {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text('Loan Details', style: styles.greenBigText,),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text(
            'LOAN NO.${loanNumber.toString()}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'KES ${loanAmount.toString()}, ',
            style: styles.greenBigText,
          ),
          Divider(height: 32),
          Text(
            'Amount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Principal:'),
                  Text('amount'), // Placeholder for amount
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Interest:'),
                  Text('percentage and amount'), // Placeholder for percentage and amount
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:'),
                  Text('amount'), // Placeholder for amount
                ],
              ),
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
                  Text('amount of days'), // Placeholder for amount of days
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Repayment days:'),
                  Text('amount of days'), // Placeholder for amount of days
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
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: styles.primaryColor), textAlign: TextAlign.start,
            ),
            trailing: Icon(Icons.expand_more, color: styles.primaryColor,),
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Seems like there is no history available for this loan at the moment',
                    style: styles.greenSmallText,
                  ),
                ),
              ),
            ],
          ),
          ElevatedButton(onPressed: (){
            //TODO: handle close
          },
            style: ButtonStyleConstants.secondaryButtonStyle,
              child: const Text("Close", style: styles.purpleText,),)
        ],
      ),
    );
  }
}
