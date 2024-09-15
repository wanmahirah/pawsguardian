import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Map<String, int>> fetchReportData() async {
    // Replace 'reports' with your actual Firestore collection name
    QuerySnapshot reportSnapshot = await _db.collection('reports').get();

    int totalReports = reportSnapshot.size;
    int pendingReports = 0;
    int resolvedReports = 0;

    for (var doc in reportSnapshot.docs) {
      String status = doc['status'];
      if (status == 'pending') {
        pendingReports++;
      } else if (status == 'resolved') {
        resolvedReports++;
      }
    }

    return {
      'total': totalReports,
      'pending': pendingReports,
      'resolved': resolvedReports,
    };
  }
}
