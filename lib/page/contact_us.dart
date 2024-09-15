import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ContactInfoCard(
              icon: Icons.person,
              text: 'Wan Mahirah binti Wan Mashruhim',
              onTap: null,
            ),
            SizedBox(height: 10),
            ContactInfoCard(
              icon: Icons.phone,
              text: '+6019-652 6757',
              onTap: () => _launchURL('tel:+60196526757'),
            ),
            SizedBox(height: 10),
            ContactInfoCard(
              icon: Icons.email,
              text: 'b032110244@student.utem.edu.my',
              onTap: () => _launchURL('mailto:b032110244@student.utem.edu.my'),
            ),
            SizedBox(height: 10),
            ContactInfoCard(
              icon: Icons.location_on,
              text:
              'Fakulti Teknologi Maklumat dan Komunikasi (FTMK)\nUniversiti Teknikal Malaysia Melaka (UTeM)\n76100 Durian Tunggal, Melaka, Malaysia',
              onTap: () => _launchURL('https://www.google.com/maps/place/Universiti+Teknikal+Malaysia+Melaka/@2.294848,102.247842'),
            ),
            Spacer(),
            Text(
              '© Paws Guardian, 2024',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}

class ContactInfoCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  ContactInfoCard({required this.icon, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.brown,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Icon(icon, color: Colors.white),
          title: Text(
            text,
            style: TextStyle(color: Colors.white, fontSize: 16), // Adjustable font size
          ),
        ),
      ),
    );
  }
}