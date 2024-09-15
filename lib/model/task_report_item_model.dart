import 'package:cloud_firestore/cloud_firestore.dart';

class TaskReportItem {
  final String id;
  final String imageUrl;
  final String title;
  final String location;
  final String description;
  final String date;

  TaskReportItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
  });

  factory TaskReportItem.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return TaskReportItem(
      id: doc.id,
      imageUrl: data['imageUrl'] ?? '',
      title: data['title'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'location': location,
      'description': description,
      'date': date,
    };
  }
}
