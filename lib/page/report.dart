import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pawssguardiann/page/report_list.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _image;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _viewReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportListPage()),
    );
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _uploadPhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        _image = null;
      }
    });
  }

  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        _image = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(child: Text('Report', style: TextStyle(fontSize: 18))),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'You will gain 50 points for each report submitted!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'View Report',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _viewReport,
              icon: Icon(Icons.summarize_outlined),
              label: Text('View Report'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Select Date and Time',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: Icon(Icons.calendar_today),
              label: Text('Pick Date and Time'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            if (_selectedDate != null && _selectedTime != null)
              Text(
                'Selected: ${_selectedDate!.toLocal()} at ${_selectedTime!.format(context)}',
                style: TextStyle(fontSize: 16),
              ),
            SizedBox(height: 20),
            Text(
              'Location',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Enter your current location',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 1,
            ),
            SizedBox(height: 20),
            Text(
              'Report Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Describe the stray animal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _uploadPhoto,
              icon: Icon(Icons.upload_file),
              label: Text('Upload Photo from Gallery'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _takePhoto,
              icon: Icon(Icons.camera_alt),
              label: Text('Take Photo with Camera'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            _image != null
                ? Image.file(_image!)
                : Container(),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _submitReport,
              icon: Icon(Icons.send),
              label: Text('Submit Report'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.brown,
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            if (_isSubmitting)
              Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_image != null && _descriptionController.text.isNotEmpty && _locationController.text.isNotEmpty && _selectedDate != null && _selectedTime != null) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final ref = FirebaseStorage.instance.ref().child('reports/${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_image!);
        final url = await ref.getDownloadURL();

        final reportDate = _selectedDate!.toLocal();
        final reportTime = _selectedTime!.format(context);
        final formattedDateTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime(reportDate.year, reportDate.month, reportDate.day, _selectedTime!.hour, _selectedTime!.minute));

        final docRef = await FirebaseFirestore.instance.collection('reports').add({
          'description': _descriptionController.text,
          'location': _locationController.text,
          'timestamp': Timestamp.now(),
          'photoUrls': [url],
          'reportDate': formattedDateTime,
          'reportTime': reportTime,
          'status': 'Pending', // Add default status as pending
          'userId': FirebaseAuth.instance.currentUser?.uid, // Add user ID to report
        });

        // Update user points
        await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser?.uid).update({
          'points': FieldValue.increment(50),
        });

        final docSnapshot = await docRef.get();
        final reportData = docSnapshot.data() as Map<String, dynamic>;

        setState(() {
          _isSubmitting = false;
          _descriptionController.clear();
          _locationController.clear();
          _image = null;
          _selectedDate = null;
          _selectedTime = null;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Report sent successfully!'),
                  SizedBox(height: 8),
                  Text('Description: ${reportData['description']}'),
                  SizedBox(height: 8),
                  Text('Date and Time: ${reportData['reportDate']}'),
                  SizedBox(height: 8),
                  Text('Location: ${reportData['location']}'),
                  SizedBox(height: 8),
                  reportData['photoUrls'] != null && (reportData['photoUrls'] as List).isNotEmpty
                      ? Image.network(reportData['photoUrls'][0])
                      : Container(),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to submit report. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

}
