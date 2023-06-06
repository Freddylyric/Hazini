import 'package:flutter/material.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            // Help title
            const Text(
              'HELP',
              style: styles.greenBigText
            ),
            const SizedBox(height: 10),
            Divider(
              color: styles.secondaryColor,
              thickness: 2,

            ),
            const SizedBox(height: 10),
            // Help options
            Column(
              children: [
                _buildHelpOption('About hazini'),

                _buildHelpOption('My account'),

                _buildHelpOption('Eligibility Criteria'),

                _buildHelpOption('Loan Offers'),

                _buildHelpOption('Repayment'),
              ],
            ),
            Divider(
              color: styles.secondaryColor,
              thickness: 2,

            ),
            SizedBox(height: 20),
            // Contact us
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Contact us',
                  style: styles.greenBigText, textAlign: TextAlign.start,
                ),SizedBox(height: 16),
                // Email
                Text(
                  'support@hazini.com',
                  style: styles.greenSmallText
                ),
                SizedBox(height: 16),
                // Send message
                Text(
                  'Send us a message',
                  style: styles.greenSmallText
                ),
                SizedBox(height: 16),
                // Message input field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextFormField(
                    controller: _messageController,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Message',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Send message button
                ElevatedButton(
                  onPressed: () {
                    // Add any logic to send message here
                  },
                  style: ButtonStyleConstants.primaryButtonStyle,
                  child: Text('Send Message'),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title) {
    return ListTile(
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: () {
        // Add help option navigation logic here
      },
    );
  }
}
