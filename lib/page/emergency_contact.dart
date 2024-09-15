import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawssguardiann/model/emergency_contact_model.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactPage extends StatefulWidget {
  @override
  _EmergencyContactPageState createState() => _EmergencyContactPageState();
}

class _EmergencyContactPageState extends State<EmergencyContactPage> {
  TextEditingController _clinicSearchController = TextEditingController();
  TextEditingController _orgSearchController = TextEditingController();
  String _clinicSearchText = "";
  String _orgSearchText = "";

  @override
  void initState() {
    super.initState();
    _clinicSearchController.addListener(() {
      setState(() {
        _clinicSearchText = _clinicSearchController.text;
      });
    });
    _orgSearchController.addListener(() {
      setState(() {
        _orgSearchText = _orgSearchController.text;
      });
    });
  }

  @override
  void dispose() {
    _clinicSearchController.dispose();
    _orgSearchController.dispose();
    super.dispose();
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launch(emailLaunchUri.toString());
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(contact.image, width: double.infinity, height: 200, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.green),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _makePhoneCall(contact.phone),
                        child: Text(
                          contact.phone,
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, color: Colors.orange),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _sendEmail(contact.email),
                        child: Text(
                          contact.email,
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.phone, color: Colors.green),
                  onPressed: () => _makePhoneCall(contact.phone),
                ),
                IconButton(
                  icon: Icon(Icons.email, color: Colors.orange),
                  onPressed: () => _sendEmail(contact.email),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList(String collectionName, String searchText) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection(collectionName).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No contacts available'));
        }

        List<EmergencyContact> contacts = snapshot.data!.docs
            .map((doc) => EmergencyContact.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList();

        // Filter the contacts based on the search text
        List<EmergencyContact> filteredContacts = contacts.where((contact) {
          return contact.name.toLowerCase().contains(searchText.toLowerCase());
        }).toList();

        return ListView.builder(
          itemCount: filteredContacts.length,
          itemBuilder: (context, index) {
            final contact = filteredContacts[index];
            return _buildContactCard(contact);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Emergency Contact'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'CLINIC'),
              Tab(text: 'ORGANISATION'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _clinicSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search Clinic',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildContactList('emergencyContactClinic', _clinicSearchText),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: _orgSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search Organisation',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildContactList('emergencyContacts', _orgSearchText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
