import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pawssguardiann/profile/profile_settings.dart';
import 'package:pawssguardiann/page/welcome_screen.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _name;
  String? _email;
  String? _profileImageUrl;
  int _points = 0;

  List<Map<String, dynamic>> _reportHistory = [];
  List<Map<String, dynamic>> _volunteerTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchReportHistory();
    _fetchVolunteerTasks();
  }

  Future<void> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _name = data['name'] ?? '';
          _email = data['email'] ?? '';
          _profileImageUrl = data['profileImageUrl'];
          _points = data['points'] ?? 0;  // Fetch user points
        });
      }
    }
  }

  Future<void> _fetchReportHistory() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot reportSnapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _reportHistory = reportSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  Future<void> _fetchVolunteerTasks() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot volunteerSnapshot = await _firestore
          .collection('volunteerTasks')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        _volunteerTasks = volunteerSnapshot.docs.map((doc) {
          return doc.data() as Map<String, dynamic>;
        }).toList();
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
            (route) => false,
      );
    }
  }

  Future<void> _refreshData() async {
    await _fetchUserData();
    await _fetchReportHistory();
    await _fetchVolunteerTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Account',
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout_outlined, color: Colors.brown),
            onPressed: () => _logout(context),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : NetworkImage('https://via.placeholder.com/150'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditProfilePage()),
                              );
                            },
                            child: CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.brown,
                              child: Icon(Icons.edit, color: Colors.white, size: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _email ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          '$_points points',  // Display user points
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                // Integrating TabBar and TabBarView
                DefaultTabController(
                  length: 3,  // Adding a third tab
                  child: Column(
                    children: [
                      TabBar(
                        indicatorColor: Colors.brown,
                        labelColor: Colors.brown,
                        unselectedLabelColor: Colors.black,
                        tabs: [
                          Tab(text: 'REPORTS'),
                          Tab(text: 'VOLUNTEER TASKS'),
                          Tab(text: 'ACHIEVEMENTS'),  // New tab for Achievements
                        ],
                      ),
                      SizedBox(
                        height: 400, // Adjust height as needed
                        child: TabBarView(
                          children: [
                            _buildReportHistoryTab(),
                            _buildVolunteerTasksTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addActionAndSetStatus(String reportId, String action) {
    FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'actions': FieldValue.arrayUnion([action]), // Add the action to the 'actions' array
      'status': 'In Progress', // Update the status to 'In Progress'
    }).then((_) {
      print('Action added and status updated successfully.');
    }).catchError((error) {
      print('Failed to update report: $error');
    });
  }

  Widget _buildReportHistoryTab() {
    return _reportHistory.isEmpty
        ? Center(child: Text('No reports available'))
        : ListView.builder(
      itemCount: _reportHistory.length,
      itemBuilder: (context, index) {
        final report = _reportHistory[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  report['photoUrls'] != null && (report['photoUrls'] as List).isNotEmpty
                      ? report['photoUrls'][0]
                      : 'https://via.placeholder.com/150',
                ),
                SizedBox(height: 10),
                Text(
                  report['description'] ?? 'No Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Location: ${report['location'] ?? 'No Location'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Date: ${report['reportDate'] ?? 'No Date'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Status: ${report['status'] ?? 'Pending'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: report['status'] == 'Pending' ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolunteerTasksTab() {
    return _volunteerTasks.isEmpty
        ? Center(child: Text('No tasks available'))
        : ListView.builder(
      itemCount: _volunteerTasks.length,
      itemBuilder: (context, index) {
        final task = _volunteerTasks[index];
        return Card(
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  task['imageUrl'] ?? 'https://via.placeholder.com/150',
                ),
                SizedBox(height: 10),
                Text(
                  task['title'] ?? 'No Title',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Description: ${task['description'] ?? 'No Description'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Date: ${task['date'] ?? 'No Date'}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
