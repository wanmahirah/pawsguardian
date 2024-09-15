import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pawsguardian_admin/model/volunteer_task_model.dart';

class AdminVolunteerTaskPage extends StatefulWidget {
  @override
  _AdminVolunteerTaskPageState createState() => _AdminVolunteerTaskPageState();
}

class _AdminVolunteerTaskPageState extends State<AdminVolunteerTaskPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - Manage Volunteer Tasks', style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskDialog(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder(
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

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return AdminVolunteerTaskCard(
                task: tasks[index],
                onEdit: () => _openTaskDialog(context, task: tasks[index]),
                onDelete: () => _confirmDeleteTask(tasks[index].id),
              );
            },
          );
        },
      ),
    );
  }

  void _openTaskDialog(BuildContext context, {VolunteerTaskModel? task}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TaskDialog(
          task: task,
          onSave: (taskData) {
            if (task == null) {
              _createTask(taskData);
            } else {
              _updateTask(task.id, taskData);
            }
          },
        );
      },
    );
  }

  Future<void> _createTask(VolunteerTaskModel task) async {
    await _firestore.collection('volunteerTasks').add(task.toFirestore());
  }

  Future<void> _updateTask(String taskId, VolunteerTaskModel task) async {
    await _firestore.collection('volunteerTasks').doc(taskId).update(task.toFirestore());
  }

  Future<void> _confirmDeleteTask(String taskId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      await _deleteTask(taskId);
    }
  }

  Future<void> _deleteTask(String taskId) async {
    await _firestore.collection('volunteerTasks').doc(taskId).delete();
  }
}

class AdminVolunteerTaskCard extends StatelessWidget {
  final VolunteerTaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminVolunteerTaskCard({
    required this.task,
    required this.onEdit,
    required this.onDelete,
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
              child: Image.network(task.imageAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.taskTitle,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(task.taskDescription),
                  SizedBox(height: 8),
                  Text('Location: ${task.location}'),
                  SizedBox(height: 8),
                  Text('Date: ${task.formattedDatetime}'),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    ],
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

class TaskDialog extends StatefulWidget {
  final VolunteerTaskModel? task;
  final Function(VolunteerTaskModel) onSave;

  const TaskDialog({this.task, required this.onSave});

  @override
  _TaskDialogState createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  String? _uploadedImageUrl;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.taskTitle;
      _descriptionController.text = widget.task!.taskDescription;
      _locationController.text = widget.task!.location;
      _uploadedImageUrl = widget.task!.imageAsset;
      _selectedDate = widget.task!.datetime.toDate();
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Create Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Task Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Task Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 16),
            _image != null
                ? Image.file(_image!)
                : (_uploadedImageUrl != null
                ? Image.network(_uploadedImageUrl!)
                : Container()),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text('Upload Photo from Gallery'),
              onPressed: _uploadPhoto,
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Take Photo with Camera'),
              onPressed: _takePhoto,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text(_selectedDate == null
                  ? 'Pick Date'
                  : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
              onPressed: _pickDate,
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.access_time),
              label: Text(_selectedTime == null
                  ? 'Pick Time'
                  : _selectedTime!.format(context)),
              onPressed: _pickTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_titleController.text.isNotEmpty &&
                _descriptionController.text.isNotEmpty &&
                _locationController.text.isNotEmpty &&
                (_image != null || _uploadedImageUrl != null) &&
                _selectedDate != null &&
                _selectedTime != null) {
              String imageUrl = _uploadedImageUrl ?? '';
              if (_image != null) {
                imageUrl = await _uploadImageToFirebase(_image!);
              }

              final taskDateTime = DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              );

              final newTask = VolunteerTaskModel(
                id: widget.task?.id ?? '',
                taskTitle: _titleController.text,
                taskDescription: _descriptionController.text,
                location: _locationController.text,
                imageAsset: imageUrl,
                datetime: Timestamp.fromDate(taskDateTime),
              );
              widget.onSave(newTask);
              Navigator.of(context).pop(); // Close dialog
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  Future<void> _uploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<String> _uploadImageToFirebase(File image) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('volunteerTasks/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await ref.putFile(image);
    return await ref.getDownloadURL();
  }
}
