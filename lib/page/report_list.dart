import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:intl/intl.dart';

class ReportListPage extends StatefulWidget {
  @override
  _ReportListPageState createState() => _ReportListPageState();
}

class _ReportListPageState extends State<ReportListPage> with SingleTickerProviderStateMixin {
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

  void _addActionAndSetStatus(String reportId, String action) {
    FirebaseFirestore.instance.collection('reports').doc(reportId).update({
      'actions': FieldValue.arrayUnion([action]),
      'status': 'In Progress',
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
        title: Text('Report List'),
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
                    ReportListView(reports: pendingReports, addActionAndSetStatus: _addActionAndSetStatus),
                    ReportListView(reports: inProgressReports, addActionAndSetStatus: _addActionAndSetStatus),
                    ReportListView(reports: resolvedReports, addActionAndSetStatus: _addActionAndSetStatus),
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
  final Function(String, String) addActionAndSetStatus;

  const ReportListView({
    required this.reports,
    required this.addActionAndSetStatus,
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
          addActionAndSetStatus: addActionAndSetStatus,
        );
      },
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final Function(String, String) addActionAndSetStatus;

  const ReportCard({
    required this.report,
    required this.addActionAndSetStatus,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _actionController = TextEditingController();

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
            if (report.status == 'Pending') ...[
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Take Action'),
                        content: Text('Do you want to commit to ${report.description}?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              addActionAndSetStatus(report.id, _actionController.text);
                              _actionController.clear();
                              Navigator.of(context).pop();
                            },
                            child: Text('Yes'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Take Action'),
              ),
            ],
          ],
        ),
      ),
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
