import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';


import '../../adapters/customer_model.dart';
import 'bottom_nav.dart';
import 'loan_repayment_screen.dart';

class LoanDetailsScreen extends StatelessWidget {
  final Map<String, dynamic>? loan;



  const LoanDetailsScreen( {Key? key, required this.loan}) : super(key: key);

  Future<CustomerModel?> _readCustomerDetailsFromHive() async {
    final customerDetailsBox = Hive.box<CustomerModel>('customer_details');
    final customerDetails = customerDetailsBox.get('data');

      return customerDetails;

  }


  @override
  Widget build(BuildContext context) {
    bool isActive = loan!['status'] == 1;

    final dueOnString = loan!['due_on']['Time'];
    final dateFormatter = DateFormat('yyyy-MM-ddTHH:mm:ssZ'); // Format used in the API response
    final dueOnDateTime = dateFormatter.parse(dueOnString);
// Format the date to display in a more readable format
    final formattedDueDate = DateFormat('MMM dd, yyyy').format(dueOnDateTime);


    return Scaffold(
      backgroundColor: Color(0xffE5EBEA),

      body: Center(

        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

            //  SizedBox(height: 80,),
              Text("Your loan Details", style: TextStyle(fontSize: 18, fontWeight:FontWeight.w600,color: Color(0xff5C5C5C)),),
              SizedBox(height: 16,),
              Text(
                'Loan No.${loan? ['loan_product_id'].toString()?? ''}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xff606060)),
              ),
              SizedBox(height: 5),
              Text(
                'KES ${loan? ['principal'].toString() ?? 0.00} ',
                style: styles.greenSmallText,
              ),
              SizedBox(height: 16),
              Text(
                'Amount',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
              ),
              SizedBox(height: 16),
              Column(
                children: [
                  _buildInfoRow('Principal:', 'KES ${loan? ['principal'] ?? '0.00'}'),
                  _buildInfoRow('Interest:', ' ${loan? ['interest'] ?? '0'} %'),
                  _buildInfoRow('Total:', 'KES ${loan? ['total_amount'] ?? '0.00'}'),


                ],
              ),
              Divider(height: 20,  color: Colors.grey, thickness: 1,),
              Text(
                'Repayment Plan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
              ),
              SizedBox(height: 16),
              Column(
                children: [

                  _buildInfoRow('Period:', '${loan? ['duration'] ?? '0'} days'),
                  _buildInfoRow('Repayment date:', formattedDueDate),

                ],
              ),
              Divider(height: 20,  color: Colors.grey, thickness: 1,),
              Text(
                'Status',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
              ),
              SizedBox(height: 16),
              Text( _getStatusText(loan!['status']),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
              ), // Placeholder for overdue repayment
              SizedBox(height: 20),
              ExpansionTile(
                initiallyExpanded: true,
                tilePadding: EdgeInsets.all(0),
                title: Text(
                  'Transaction History',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xff5C5C5C)),
                  textAlign: TextAlign.left,
                ),


                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child:
                    (double.tryParse(loan?['paid_amount'] ?? '0') ?? 0) > 0
                        ?

                    Text(

                      'Paid amount: ${loan?['paid_amount']}',
                      style: styles.greenSmallText,
                    )
                        :  Text(
                      'Seems like there is no history available for this loan at the moment',
                      style: styles.greenSmallText,
                    ),
                  ),

                ],
              ),

              SizedBox(height: 30,),


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
                child: ElevatedButton(onPressed: () async {

                  final customerDetails = await _readCustomerDetailsFromHive();
                  if (customerDetails != null){

                    if (isActive) {

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>LoanRepaymentScreen(customerDetails: customerDetails,)));
                      // TODO: Handle repay loan
                    } else {
                      Navigator.pop(context); // Navigate back to history page
                    }
                  }

                  // //TODO: handle close
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => BottomNav()));
                  //
                },

                    child:  Text(isActive ? "REPAY LOAN" : "CLOSE",
                      style: TextStyle(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white)),
                  style:  ElevatedButton.styleFrom(

                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11)
                    ),

                    backgroundColor: Colors.transparent,

                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shadowColor: Colors.transparent,

                  ),
                ),
              )
            ],
          ),
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

  String _getStatusText(int statusCode) {
    switch (statusCode) {
      case 9:
        return 'Paid';
      case 2:
        return 'Pending Disbursement';
      case 1:
        return 'Active';
      case -1:
        return 'Pending Approval';
      case -4:
        return 'Failed';
      case -5:
        return 'Disbursement Failed';
      case -9:
        return 'Rejected';
      case -6:
        return 'Defaulted';
      default:
        return 'Unknown Status';
    }
  }

}
