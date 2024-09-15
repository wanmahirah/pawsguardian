import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';

class AdminReportPage extends StatefulWidget {
  @override
  _AdminReportPageState createState() => _AdminReportPageState();
}

class _AdminReportPageState extends State<AdminReportPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _searchQuery = '';
  String _selectedDate = '';
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void _approveReport(String reportId) {
    FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'status': 'Resolved',
    });
  }

  void _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report List', style: TextStyle(fontSize: 18)),
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'PENDING'),
            Tab(text: 'IN PROGRESS'),
            Tab(text: 'RESOLVED'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Report',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('reports').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reports found.'));
                }

                final reports = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Report(
                    id: doc.id,
                    description: data['description'] ?? '',
                    location: data['location'] ?? '',
                    date: (data['timestamp'] as Timestamp).toDate().toLocal().toString().split(' ')[0],
                    time: data['reportTime'] ?? '',
                    imageUrl: (data['photoUrls'] as List).isNotEmpty ? data['photoUrls'][0] : '',
                    status: data['status'] ?? 'Pending',
                    actions: List<String>.from(data['actions'] ?? []),
                  );
                }).where((report) {
                  final query = _searchQuery.toLowerCase();
                  final dateFilter = _selectedDate.isNotEmpty ? report.date == _selectedDate : true;
                  return (report.description.toLowerCase().contains(query) ||
                      report.location.toLowerCase().contains(query) ||
                      report.date.toLowerCase().contains(query) ||
                      report.time.toLowerCase().contains(query)) && dateFilter;
                }).toList();

                final pendingReports = reports.where((report) => report.status == 'Pending').toList();
                final inProgressReports = reports.where((report) => report.status == 'In Progress').toList();
                final resolvedReports = reports.where((report) => report.status == 'Resolved').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    ReportListView(reports: pendingReports, approveReport: _approveReport),
                    ReportListView(reports: inProgressReports, approveReport: _approveReport),
                    ReportListView(reports: resolvedReports, approveReport: _approveReport),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Report {
  final String id;
  final String description;
  final String location;
  final String date;
  final String time;
  final String imageUrl;
  final String status;
  final List<String> actions;

  Report({
    required this.id,
    required this.description,
    required this.location,
    required this.date,
    required this.time,
    required this.imageUrl,
    required this.status,
    required this.actions,
  });
}

class ReportListView extends StatelessWidget {
  final List<Report> reports;
  final Function(String) approveReport;

  const ReportListView({
    required this.reports,
    required this.approveReport,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.0),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportCard(
          report: report,
          approveReport: approveReport,
        );
      },
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final Function(String) approveReport;

  const ReportCard({
    required this.report,
    required this.approveReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => ImagePopup(imageUrl: report.imageUrl),
                  );
                },
                child: report.imageUrl.isNotEmpty
                    ? Image.network(
                  report.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
                    : SizedBox.shrink(),
              ),
            ),
            SizedBox(height: 8.0),
            Center(
              child: Text(
                report.description,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Location: ${report.location}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 4.0),
            Text(
              'Date: ${report.date}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 4.0),
            Text(
              'Time: ${report.time}',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 4.0),
            Text(
              'Status: ${report.status}',
              style: TextStyle(fontSize: 16.0),
            ),
            if (report.status == 'In Progress') ...[
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  _showConfirmationDialog(context, report.id);
                },
                child: Text('Approve'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, String reportId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Approval'),
          content: Text('Are you sure you want to approve this report?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                approveReport(reportId);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Approve'),
            ),
          ],
        );
      },
    );
  }
}

class ImagePopup extends StatelessWidget {
  final String imageUrl;

  const ImagePopup({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: PhotoViewGallery(
            pageOptions: [
              PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              ),
            ],
            backgroundDecoration: BoxDecoration(
              color: Colors.black,
            ),
            scrollPhysics: BouncingScrollPhysics(),
            loadingBuilder: (context, event) => Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
