import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile section
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(
                      'https://i.imgur.com/4TZ6ZAR.png', // Use your image link here
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wan Mahirah',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Text('mahirahmashruhim@gmail.com', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Balance section
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'RM 0.40',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.add),
                        label: Text('Top Up'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Points section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text('Points'),
                      SizedBox(height: 4),
                      Text('102 pts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('Daily Check-in'),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Easy Goer'),
                      SizedBox(height: 4),
                      Text('2 / 10', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Icon(Icons.local_cafe, size: 30),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Action buttons
              ListTile(
                leading: Icon(Icons.receipt_long),
                title: Text('Orders'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.coffee),
                title: Text('Register Your ZUS Tumbler'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard),
                title: Text('Missions & Rewards'),
                trailing: CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.orange,
                  child: Text(
                    '1',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                onTap: () {},
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
