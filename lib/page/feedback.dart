import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _feedbackController = TextEditingController();
  int _rating = 4;

  Map<int, int> ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  @override
  void initState() {
    super.initState();
    _getRatings();
  }

  void _getRatings() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('feedback').get();
    List<QueryDocumentSnapshot> reviews = snapshot.docs;

    for (var review in reviews) {
      int rating = review['rating'] ?? 0;
      if (ratingCounts.containsKey(rating)) {
        ratingCounts[rating] = ratingCounts[rating]! + 1;
      }
    }

    setState(() {});
  }

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      String feedback = _feedbackController.text;

      // Save feedback to Firestore
      await FirebaseFirestore.instance.collection('feedback').add({
        'feedback': feedback,
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update local counts
      ratingCounts[_rating] = ratingCounts[_rating]! + 1;

      // Clear the form
      _feedbackController.clear();
      setState(() {
        _rating = 4; // Reset rating to default
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Feedback submitted successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Submit Feedback'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Write a review',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _feedbackController,
                      decoration: InputDecoration(
                        labelText: 'Give your feedback!',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some feedback';
                        }
                        return null;
                      },
                      maxLines: 4,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitFeedback,
                        child: Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Rating Distribution',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Container(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: List.generate(5, (index) {
                      int rating = index + 1;
                      return PieChartSectionData(
                        color: Colors.primaries[index % Colors.primaries.length],
                        value: ratingCounts[rating]!.toDouble(),
                        title: '$rating Stars',
                        radius: 50,
                        titleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'Reviews',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feedback')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var reviews = snapshot.data!.docs;

                  if (reviews.isEmpty) {
                    return Center(
                      child: Text('No reviews yet.'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true, // Important to allow ListView inside SingleChildScrollView
                    physics: NeverScrollableScrollPhysics(), // Prevent ListView from scrolling independently
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      var review = reviews[index];
                      var rating = review['rating'] ?? 0;
                      var feedback = review['feedback'] ?? '';
                      var timestamp = review['timestamp']?.toDate() ?? DateTime.now();

                      return ListTile(
                        leading: Icon(Icons.account_circle, size: 40),
                        title: Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            );
                          }),
                        ),
                        subtitle: Text(feedback),
                        trailing: Text(
                          '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
