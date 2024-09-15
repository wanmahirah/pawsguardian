import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseServices {
  final String? uid;
  DatabaseServices({this.uid});

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection = FirebaseFirestore.instance.collection("groups");

  Future updateUserData(String email, int phoneno, String name) async {
    return await userCollection.doc(uid).set( {
      "email": email,
      "phoneNo": phoneno,
      "name": name
    });
  }
}