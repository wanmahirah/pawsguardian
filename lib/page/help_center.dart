import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  final List<Map<String, dynamic>> helpTopics = [
    {
      "section": "General Information",
      "topics": [
        {
          "question": "What is this volunteering program about?",
          "answer": "Our volunteering program aims to improve the lives of stray animals by providing them with necessary care by doing tasks and report if anything in danger happens to them."
        },
        {
          "question": "Who can volunteer?",
          "answer": "Anyone with a compassionate heart and a willingness to help stray animals can volunteer. There are no age requirements, but minors may need parental consent."
        },
      ],
    },
    {
      "section": "Getting Started",
      "topics": [
        {
          "question": "How do I sign up to volunteer?",
          "answer": "You can sign up by filling out the registration form in the application. You are now one of the volunteers."
        },
        {
          "question": "Is there any training provided?",
          "answer": "Yes, all volunteers will receive training sessions to equip them with the necessary skills and knowledge to handle various tasks."
        },
      ],
    },
    {
      "section": "Tasks & Responsibilities",
      "topics": [
        {
          "question": "What kind of tasks can I assign?",
          "answer": "Tasks include feeding animals, cleaning shelters, walking dogs, assisting with medical care, organizing events, and helping with adoptions, and many more. Stay tuned for more tasks available in Volunteer Task List"
        },
        {
          "question": "Can I choose my tasks?",
          "answer": "Yes, volunteers can choose tasks based on their interests and availability through the Task tab. We encourage volunteers to try different tasks to gain a well-rounded experience."
        },
      ],
    },
    {
      "section": "Contact Us",
      "topics": [
        {
          "question": "How can I get in touch for more information?",
          "answer": "You can contact us through email at b032110244@student.utem.edu.my, or call us at +6019-652 6757."
        },
        {
          "question": "Where is your organization located?",
          "answer": "The main office is located at Fakulti Teknologi Maklumat dan Komunikasi (FTMK), Universiti Teknikal Malaysia Melaka."
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: helpTopics.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              child: ExpansionTile(
                title: Text(
                  helpTopics[index]['section'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                children: <Widget>[
                  ...helpTopics[index]['topics'].map<Widget>((topic) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic['question'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            topic['answer'],
                            style: TextStyle(fontSize: 16, height: 1.5),
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                    );
                  }).toList(),
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
