import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;

import 'loan_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: styles.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: styles.secondaryColor,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Your Loan History', style: styles.greenBigText,),
      ),
      body: ListView.builder(
        itemCount: 5, // Placeholder for number of loans
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text('Loan Amount', style: styles.greenSmallText,), // Placeholder for loan
              subtitle: Text('Deadline', style: styles. greenSmallText,), // Placeholder
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Active', style: styles.purpleText,), // Placeholder for loan status
                  Icon(Icons.arrow_forward_ios, color: styles.secondaryColor,),
                ],
              ),
              onTap: () {
                // Navigate to loan details screen
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoanDetailsScreen()),);
              },
            ));

        },
      ),
    );
  }
}
