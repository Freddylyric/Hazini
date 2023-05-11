import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

class LoanRepaymentScreen extends StatefulWidget {
  final double loanAmount = 5000;

  const LoanRepaymentScreen({Key? key,}) : super(key: key);

  @override
  _LoanRepaymentScreenState createState() => _LoanRepaymentScreenState();
}

class _LoanRepaymentScreenState extends State<LoanRepaymentScreen> {
  double? _repayAmount;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(

      body: Container(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            const Text('AMOUNT', style: styles.greenBigText),
            const SizedBox(height: 20,),
            Text('Your loan is KES ${widget.loanAmount.toStringAsFixed(2)}', style: styles.greenSmallText,),
            const SizedBox(height: 20),
            const Text('How much would you like to repay?', style: styles.blackText,),
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
              onPressed: _repayAmount == null
                  ? null
                  : () {
                // Add repayment logic here
              },
              style: styles.ButtonStyleConstants.primaryButtonStyle,
              child: const Text('Repay', style: styles.whiteText,),
            ),
          ],
        ),
      ),
    ));
  }
}
