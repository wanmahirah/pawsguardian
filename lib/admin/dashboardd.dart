import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pawssguardiann/admin/profile.dart';
import 'package:pawssguardiann/admin/reports.dart';
import 'package:pawssguardiann/admin/tasks.dart';

class DashboardContent extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard', style: TextStyle(fontSize: 18)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReportOverview(context),
              SizedBox(height: 30),
              _buildTaskOverview(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportOverview(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('reports').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No reports available'));
                }

                int totalReports = snapshot.data!.docs.length;
                int resolvedReports = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'Resolved')
                    .length;
                int inProgressReports = snapshot.data!.docs
                    .where((doc) => doc['status'] == 'In Progress')
                    .length;

                return Column(
                  children: [
                    SizedBox(
                      height: 180, // Set a fixed height for the pie chart
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                return;
                              }
                              final touchedIndex =
                                  pieTouchResponse.touchedSection!.touchedSectionIndex;
                              _showReportDetails(context, touchedIndex);
                            },
                          ),
                          sections: _getPieChartSections(
                            total: totalReports,
                            resolved: resolvedReports,
                            inProgress: inProgressReports,
                          ),
                          centerSpaceRadius: 40,
                          sectionsSpace: 0,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      children: [
                        _buildPieChartLabel(Colors.blue, 'Resolved', resolvedReports),
                        _buildPieChartLabel(Colors.purple, 'In Progress', inProgressReports),
                        _buildPieChartLabel(Colors.cyan, 'Total', totalReports + resolvedReports + inProgressReports),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskOverview(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('volunteerTasks').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks available'));
                }

                Map<String, int> taskCategoryCount = {
                  'Environmental Checkup': 0,
                  'Community Outreach': 0,
                  'Fundraising': 0,
                  'Animal Care': 0,
                  'Education & Awareness': 0,
                };

                snapshot.data!.docs.forEach((doc) {
                  String category = doc['category'];
                  if (taskCategoryCount.containsKey(category)) {
                    taskCategoryCount[category] = taskCategoryCount[category]! + 1;
                  }
                });

                return SizedBox(
                  height: 200, // Set a fixed height for the bar chart
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (taskCategoryCount.values.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final categoryName = taskCategoryCount.keys.toList()[group.x.toInt()];
                            return BarTooltipItem(
                              categoryName + '\n' + rod.toY.toString(),
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return _buildBarChartTitle(value.toInt());
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _getBarChartData(taskCategoryCount),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context, int index) {
    // Updated this function to handle display directly instead of using a pop-up
  }

  List<PieChartSectionData> _getPieChartSections({
    required int total,
    required int resolved,
    required int inProgress,
  }) {
    return [
      PieChartSectionData(
        color: Colors.blue,
        value: resolved.toDouble(),
        title: '$resolved',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.purple,
        value: inProgress.toDouble(),
        title: '$inProgress',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      PieChartSectionData(
        color: Colors.cyan,
        value: (total - resolved - inProgress).toDouble(),
        title: '${total - resolved - inProgress}',
        radius: 50,
        titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ];
  }

  List<BarChartGroupData> _getBarChartData(Map<String, int> taskCategoryCount) {
    return taskCategoryCount.entries.map((entry) {
      int index;
      switch (entry.key) {
        case 'Environmental Checkup':
          index = 0;
          break;
        case 'Community Outreach':
          index = 1;
          break;
        case 'Fundraising':
          index = 2;
          break;
        case 'Animal Care':
          index = 3;
          break;
        case 'Education & Awareness':
          index = 4;
          break;
        default:
          index = 0;
          break;
      }
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
          toY: entry.value.toDouble(),
          color: Colors.lightBlue,
          width: 20,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: (taskCategoryCount.values.reduce((a, b) => a > b ? a : b)).toDouble() + 2,
            color: Colors.lightBlueAccent.shade100,
          ),
        ),
      ]);
    }).toList();
  }

  Widget _buildPieChartLabel(Color color, String text, int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(width: 4),
        Text(
          value.toString(),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBarChartTitle(int index) {
    const style = TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    String text;
    switch (index) {
      case 0:
        text = 'EC';
        break;
      case 1:
        text = 'CO';
        break;
      case 2:
        text = 'FR';
        break;
      case 3:
        text = 'AC';
        break;
      case 4:
        text = 'E&A';
        break;
      default:
        return const SizedBox.shrink();
    }
    return SideTitleWidget(
      axisSide: AxisSide.bottom,
      space: 8.0,
      child: Text(text, style: style, overflow: TextOverflow.ellipsis),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardContent(),
    AdminReportPage(),
    AdminVolunteerTaskPage(),
    AdminProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
      ),
    );
  }
}
