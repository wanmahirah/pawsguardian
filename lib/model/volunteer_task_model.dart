import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class VolunteerTaskModel {
  final String id;
  final String imageAsset;
  final String points;
  final String taskTitle;
  final String category;
  final String taskDescription;
  final String location;
  final Timestamp datetime;

  VolunteerTaskModel({
    required this.id,
    required this.imageAsset,
    required this.points,
    required this.taskTitle,
    required this.category,
    required this.taskDescription,
    required this.location,
    required this.datetime,
  });

  factory VolunteerTaskModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VolunteerTaskModel(
      id: doc.id,
      imageAsset: data['imageAsset'] ?? '',
      points: data['points'] ?? '',
      taskTitle: data['taskTitle'] ?? '',
      category: data['category'] ?? '',
      taskDescription: data['taskDescription'] ?? '',
      location: data['location'] ?? '',
      datetime: data['datetime'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'imageAsset': imageAsset,
      'points': points,
      'taskTitle': taskTitle,
      'category': category,
      'taskDescription': taskDescription,
      'location': location,
      'datetime': datetime,
    };
  }

  String get formattedDatetime {
    DateTime date = datetime.toDate();
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }
}
