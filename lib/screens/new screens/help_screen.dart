import 'package:flutter/material.dart';
import 'package:hazini/utils/help_strings.dart';
import 'package:hazini/utils/styles.dart' as styles;
import 'package:hazini/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

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

      backgroundColor: Color(0xffE5EBEA) ,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            // Help title
             Text(
              'HELP',
              style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w500,color: Color(0xff5C5C5C)),
            ),
            const SizedBox(height: 10),

            // const SizedBox(height: 10),
            // Help options

               Container(
                 height: size.height*0.55,
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: faqCategories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = faqCategories[index];
                      return Card(
                        elevation: 1,
                        shape:  RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),

                        ),
                        shadowColor:  Color(0xff5C5C5C),

                        child: ExpansionTile(
                          title: Text(category.title, style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16,color: Color(0xff009BA5)),),
                          children: category.faqs.map((faq) {
                            return ExpansionTile(
                              title: Text(faq.title, ),
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
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
              color: Colors.grey,
              thickness: 1,

            ),
            SizedBox(height: 5),
            // Contact us
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'CONTACT US',
                  style: GoogleFonts.montserrat( fontSize: 20, fontWeight: FontWeight.w500,color: Color(0xff5C5C5C)),
                  textAlign: TextAlign.start,
                ),SizedBox(height: 5),
                // Email
                GestureDetector(
                  onTap: () {
                    _launchUrl();
                  },
                  child: Text(
                    'support@hazini.com',
                    style: GoogleFonts.montserrat(color: Color(0xff009BA5), fontSize: 16, fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                  ),
                ),

                SizedBox(height: 10),
                // Message input field
                Container(

                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow:  [
                      BoxShadow(
                        color: Color(0x2E2E2E40),
                        offset: Offset(1, 3),
                        blurRadius: 3,
                        spreadRadius: 1,
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: Center(
                    child: TextFormField(
                      controller: _messageController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: GoogleFonts.montserrat(color: Color(0xff9B9B9B), fontSize: 16, fontWeight: FontWeight.w500),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
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
                  child: ElevatedButton(
                    onPressed: () {
                      final phoneNumber = '0702364929'; // Replace with the desired phone number
                      final message = _messageController.text;

                      // sendSMS(phoneNumber, message);

                      launch('sms:0702364929?body=${_messageController.text}');
                    },
                    child: Text('SEND MESSAGE',style: GoogleFonts.montserrat(fontWeight:FontWeight.w500,fontSize: 16,  color: Colors.white)),

                      style:  ElevatedButton.styleFrom(

                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)
                        ),

                        backgroundColor: Colors.transparent,

                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shadowColor: Colors.transparent,

                      )
                  ),
                ),

              ],
            ),

          ],
        ),
      ),
    );
  }


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

