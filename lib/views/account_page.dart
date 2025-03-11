import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  final String username;
  final String email;
  final String phone;
  final String regional;
  const AccountPage({
    super.key,
    required this.username,
    required this.email,
    required this.phone,
    required this.regional,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text("Name: ${widget.username}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Email: ${widget.email}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Phone: ${widget.phone}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Region: ${widget.regional}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
