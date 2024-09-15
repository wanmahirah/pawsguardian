import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pawssguardiann/model/volunteer_task_model.dart';

class VolunteerWorkPage extends StatefulWidget {
  @override
  _VolunteerWorkPageState createState() => _VolunteerWorkPageState();
}

class _VolunteerWorkPageState extends State<VolunteerWorkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer Tasks', style: TextStyle(fontSize: 18)),
        centerTitle: true,
          automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Task',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.pink),
                  onPressed: _pickDate,
                ),
              ],
            ),
            SizedBox(height: 8),
            if (_selectedDate != null)
              Text(
                'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}',
                style: TextStyle(fontSize: 16),
              ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore.collection('volunteerTasks').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No tasks available'));
                  }

                  List<VolunteerTaskModel> tasks = snapshot.data!.docs
                      .map((doc) => VolunteerTaskModel.fromFirestore(doc))
                      .toList();

                  // Filter tasks based on search text and selected date
                  List<VolunteerTaskModel> filteredTasks = tasks.where((task) {
                    bool matchesSearchText = task.taskTitle.toLowerCase().contains(_searchText.toLowerCase()) ||
                        task.formattedDatetime.toLowerCase().contains(_searchText.toLowerCase());
                    bool matchesDate = _selectedDate == null ||
                        DateFormat('yyyy-MM-dd').format(task.datetime.toDate()) ==
                            DateFormat('yyyy-MM-dd').format(_selectedDate!);
                    return matchesSearchText && matchesDate;
                  }).toList();

                  // Sort tasks by date
                  filteredTasks.sort((a, b) => a.datetime.compareTo(b.datetime));

                  return ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return VolunteerTask(
                        taskId: filteredTasks[index].id,
                        imageAsset: filteredTasks[index].imageAsset,
                        points: filteredTasks[index].points,
                        taskTitle: filteredTasks[index].taskTitle,
                        category: filteredTasks[index].category,
                        taskDescription: filteredTasks[index].taskDescription,
                        location: filteredTasks[index].location,
                        datetime: filteredTasks[index].formattedDatetime,
                        onVolunteer: () => _showVolunteerDialog(filteredTasks[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showVolunteerDialog(VolunteerTaskModel task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Volunteer Confirmation'),
          content: Text('Do you want to volunteer to ${task.taskTitle}?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _volunteerForTask(task, task.id);
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _volunteerForTask(VolunteerTaskModel task, String taskId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userTasksCollection = _firestore.collection('users').doc(user.uid).collection('volunteerTasks');
      final existingTask = await userTasksCollection.doc(taskId).get();

      if (!existingTask.exists) {
        await userTasksCollection.doc(taskId).set(task.toFirestore());
      } else {
        print('Task already added.');
      }
    }
  }
}

class VolunteerTask extends StatelessWidget {
  final String taskId;
  final String imageAsset;
  final String points;
  final String taskTitle;
  final String category;
  final String taskDescription;
  final String location;
  final String datetime;

  final VoidCallback onVolunteer;

  const VolunteerTask({
    required this.taskId,
    required this.imageAsset,
    required this.points,
    required this.taskTitle,
    required this.category,
    required this.taskDescription,
    required this.location,
    required this.datetime,
    required this.onVolunteer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(imageAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${points} points',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    taskTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${category}',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(taskDescription,
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('$location',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('$datetime',
                    style: TextStyle(
                      color: Colors.cyan
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onVolunteer,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volunteer_activism, color: Colors.white),
                          SizedBox(width: 8),
                          Text('Volunteer', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
