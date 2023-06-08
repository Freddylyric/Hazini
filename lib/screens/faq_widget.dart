import 'package:flutter/material.dart';

class FAQScreen extends StatelessWidget {
  final List<FAQCategory> faqCategories = [
    FAQCategory(
      title: 'About Hazini',
      faqs: [
        FAQ(title: 'What is Hazini?', answer: 'Hazini is...'),
        FAQ(title: 'How does Hazini work?', answer: 'Hazini works by...'),
        // Add more FAQs in this category
      ],
    ),
    FAQCategory(
      title: 'My Account',
      faqs: [
        FAQ(title: 'How can I create an account?', answer: 'To create an account...'),
        FAQ(title: 'How do I reset my password?', answer: 'To reset your password...'),
        // Add more FAQs in this category
      ],
    ),
    // Add more FAQ categories
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazini FAQs'),
      ),
      body: ListView.builder(
        itemCount: faqCategories.length,
        itemBuilder: (BuildContext context, int index) {
          final category = faqCategories[index];
          return ExpansionTile(
            title: Text(category.title),
            children: category.faqs.map((faq) {
              return ListTile(
                title: Text(faq.title),
                subtitle: Text(faq.answer),
              );
            }).toList(),
          );
        },
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
