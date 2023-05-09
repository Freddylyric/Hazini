import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:hazini/screens/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:hazini/utils/styles.dart' as styles;

import 'help_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username = 'John Doe'; // Replace with actual username

  //HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoanInfoExpanded = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: styles.backgroundColor,
      appBar: AppBar(
        backgroundColor: styles.backgroundColor,
        leading: CircleAvatar(
          backgroundColor: styles.backgroundColor,
          child: Text(widget.username.substring(0, 2)),
        ),
        title: Text('Hi there, ${widget.username}', style: styles.greenBigText,),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: styles.secondaryColor,),
            onPressed: () {
              // Add any menu logic here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your loans',
                  style: styles.greenBigText,
                ),
                SizedBox(height: 20),
                // Container for loan info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[300]!,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loan amount
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'You have a loan of:',
                                style: styles.greenSmallText,
                              ),SizedBox(height: 10),

                              Text('Ksh 5,000', // Placeholder for loan amount
                                  style: styles.greenBigText
                              ),
                            ],
                          ),

                          Spacer(),
                          IconButton(
                            icon: Icon(
                              _isLoanInfoExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isLoanInfoExpanded = !_isLoanInfoExpanded;
                              });
                            },
                          ),
                        ],
                      ),
                      if (_isLoanInfoExpanded) ...[
                        const SizedBox(height: 16),
                        // Loan info details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLoanInfoRow('Principal', '\$5,000'), // Placeholder for principal amount
                            _buildLoanInfoRow('Interest', '\$1,000'), // Placeholder for interest amount
                            _buildLoanInfoRow('Balance', '\$3,000'), // Placeholder for balance amount
                            _buildLoanInfoRow('Period', '12 months'), // Placeholder for period
                            _buildLoanInfoRow('Date Borrowed', '01/01/2022'), // Placeholder for date borrowed
                            _buildLoanInfoRow('Deadline', '01/01/2023'), // Placeholder for deadline
                          ],
                        ),
                      ],
                      SizedBox(height: 16),
                      // Pay now button
                      ElevatedButton(
                        onPressed: () {
                          // Add any "pay now" logic here
                        },
                        style: styles.ButtonStyleConstants.primaryButtonStyle,
                        child: const Text('Pay now'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Tabs for History, Profile, and Help
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTab('History', Icons.file_copy_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()),
                      );
                    }),
                    _buildTab('Profile', Icons.person_2_outlined, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    }),
                    _buildTab('Help', Icons.question_mark, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  Widget _buildLoanInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
              style: styles.greenSmallText
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, IconData icon, Function() onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 90,
        height: 90,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[300]!,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.grey[700],
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: styles.purpleText
            ),
          ],
        ),
      ),
    );
  }

}
