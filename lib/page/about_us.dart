import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // App Logo or Image
              Image.asset(
                'lib/images/logo.jpg',
                height: 150,
              ),
              SizedBox(height: 20),
              // Introduction Text
              Text(
                'Welcome to Paws Guardian, a community-driven initiative dedicated to improving the lives of stray animals. Our mission is to connect volunteers with opportunities to make a difference in the lives of these helpless creatures.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Mission Statement
              Text(
                'Mission \nTo create a supportive network that empowers volunteers to provide care, shelter, and love to stray animals in need.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 20),
              // Vision Statement
              Text(
                'Vision \nA world where every stray animal is safe, healthy, and loved, living in a community that values their lives and well-being.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '© Paws Guardian, 2024',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
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
