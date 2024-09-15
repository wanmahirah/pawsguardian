import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  final List<Map<String, String>> faqs = [
    {
      "question": "How can I volunteer?",
      "answer": "You can volunteer by clicking Tasks and choose the tasks you want to commit."
    },
    {
      "question": "What are the requirements to volunteer?",
      "answer": "Generally, volunteers should be compassionate, reliable, and have a genuine interest in animal welfare. There are no age requirements to volunteer."
    },
    {
      "question": "What kind of tasks will I be doing?",
      "answer": "Volunteers can expect to perform tasks such as feeding animals, cleaning shelters, walking dogs, assisting with medical care, and participating in adoption events."
    },
    {
      "question": "Can I volunteer if I have no experience?",
      "answer": "Of course! Enthusiasm and a willingness to learn are often more important than prior experience."
    },
    {
      "question": "Are there any benefits to volunteering?",
      "answer": "Volunteering can be incredibly rewarding. You get to help animals in need, meet like-minded people, and gain valuable experience. Additionally, it can be a great way to improve your mental and physical health."
    },
    {
      "question": "Can I volunteer if I have pets at home?",
      "answer": "Yes, but it's important to take precautions to prevent the spread of diseases. Always wash your hands and change clothes after handling stray animals before interacting with your pets."
    },
    {
      "question": "What should I do if I find a stray animal in danger?",
      "answer": "If you find a stray animal in danger, please click Report and make the report about the stray animal."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: faqs.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  faqs[index]['question']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                children: <Widget>[
                  Divider(thickness: 1, color: Colors.grey[300]),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      faqs[index]['answer']!,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                ],
                tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                childrenPadding: const EdgeInsets.all(16.0),
              ),
            );
          },
        ),
      ),
    );
  }
}
