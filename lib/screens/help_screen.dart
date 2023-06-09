import 'package:flutter/material.dart';
import 'package:hazini/utils/help_strings.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _messageController = TextEditingController();

  final Uri _url = Uri.parse('mailto:support@hazini.com');



  final List<FAQCategory> faqCategories = [
    FAQCategory(
      title: 'About Hazini',
      faqs: [
        FAQ(title: abQN1whatIsHazini, answer: whatIsHazini),
        FAQ(title: abQN2haziniLocation, answer:haziniLocation),
        FAQ(title: abQN3haziniCountries, answer: haziniCountries),
        FAQ(title: abQN4haziniSwahili, answer: haziniSwahili),
        FAQ(title: abQN5haziniAppVersion, answer: haziniAppVersion),
        FAQ(title: abQN6haziniNetworks, answer: haziniNetworks),
        FAQ(title: abQN7haziniVacancies, answer: haziniVacancies),
        FAQ(title: abQN8haziniRepresentative, answer: haziniRepresentative),
        // Add more FAQs in this category
      ],
    ),
    FAQCategory(
      title: 'My Account',
      faqs: [
        FAQ(title: acQN1SIMSupported, answer: SIMSupported),
        FAQ(title: acQN2changeNationalID, answer: changeNationalID),
        FAQ(title: acQN3deleteAccount, answer: deleteAccount),
        FAQ(title: acQN4changeDetails, answer: changeDetails),
        FAQ(title: acQN5addNumber, answer: addNumber),
        FAQ(title: acQN6validateAccount, answer: validateAccount),
        // Add more FAQs in this category
      ],
    ),

    FAQCategory(
      title: 'Eligibility Criteria',
      faqs: [
        FAQ(title: elQN1lendingDecisions, answer: lendingDecisions),
        FAQ(title: elQN2loanRejected, answer: loanRejected),
        FAQ(title: elQN3loanRequirements, answer: loanRequirements),
        FAQ(title: elQN4someoneElse, answer: someoneElse),
        FAQ(title: elQN5increaseLoanChances, answer: increaseLoanChances),
        FAQ(title: elQN6applicationProcess, answer: applicationProcess),


        // Add more FAQs in this category
      ],
    ),

    FAQCategory(
      title: 'Loan Offers',
      faqs: [
        FAQ(title: loQN1howToApply, answer: howToApply),
        FAQ(title: loQN2howMuch, answer: howMuch),
        FAQ(title: loQN3howDetermineOffers, answer: howDetermineOffers),
        FAQ(title: loQN4applyHigherAmount, answer: applyHigherAmount),
        FAQ(title: loQN5largestAmount, answer: largestAmount),
        FAQ(title: loQN6interestRate, answer: interestRate),
        FAQ(title: loQN7loanSizeIncreaseRepay, answer: loanSizeIncreaseRepay),
        FAQ(title: loQN8howFastLoanIncrease, answer: howFastLoanIncrease),

        // Add more FAQs in this category
      ],
    ),

    FAQCategory(
      title: 'Repayment',
      faqs: [
        FAQ(title: reQN1howToRepay, answer: howToRepay),
        FAQ(title: reQN2onePayment, answer: onePayment),
        FAQ(title: reQN3repaymentSchedule, answer: repaymentSchedule),
        FAQ(title: reQN4monthlyRepayment, answer: monthlyRepayment),
        FAQ(title: reQN5repaymentReflect, answer: repaymentReflect),
        FAQ(title: reQN6repayEarly, answer: repayEarly),
        FAQ(title: reQN7overpay, answer: overpay),
        // Add more FAQs in this category
      ],
    ),

    FAQCategory(
      title: 'Late Repayment and CRB',
      faqs: [
        FAQ(title: crQN1missRepayment, answer: missRepayment),
        FAQ(title: crQN2requestLaterRepay, answer: requestLaterRepay),
        FAQ(title: crQN3whatIsCRB, answer: whatIsCRB),

        // Add more FAQs in this category
      ],
    ),

    FAQCategory(
      title: 'Security & Privacy',
      faqs: [
        FAQ(title: scQN1trustHazini, answer: trustHazini),
        FAQ(title: scQN2whyID, answer: whyID),
        FAQ(title: scQN3permissionNeed, answer: permissionNeed),
        FAQ(title: scQN4givePermission, answer: givePermission),
        // Add more FAQs in this category
      ],
    ),
    // Add more FAQ categories
  ];

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return  Scaffold(

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
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
            // const SizedBox(height: 10),
            // Help options

               Container(
                 height: size.height*0.45,
                  child: ListView.builder(
                    itemCount: faqCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = faqCategories[index];
                      return Card(
                        child: ExpansionTile(
                          title: Text(category.title, style: greenSmallText,),
                          children: category.faqs.map((faq) {
                            return ExpansionTile(
                              title: Text(faq.title, ),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(faq.answer, style: blackSmallText,),
                              ),
                                ),]
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
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
                GestureDetector(
                  onTap: () {
                    _launchUrl();
                  },
                  child: Text(
                    'support@hazini.com',
                    style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w400, decoration: TextDecoration.underline),
                  ),
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
                ElevatedButton(
                  onPressed: () {
                    final phoneNumber = '0702364929'; // Replace with the desired phone number
                    final message = _messageController.text;

                    // sendSMS(phoneNumber, message);

                    launch('sms:0702364929?body=${_messageController.text}');
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

  // Widget _buildHelpOption(String title) {
  //   return ListTile(
  //     title: Text(title),
  //     trailing: Icon(Icons.arrow_forward_ios),
  //     onTap: () {
  //       // Add help option navigation logic here
  //     },
  //   );
  // }
}


class FAQCategory {
  final String title;
  final List<FAQ> faqs;

  FAQCategory({
    required this.title,
    required this.faqs,
  });
}

class FAQ {
  final String title;
  final String answer;

  FAQ({
    required this.title,
    required this.answer,
  });
}

