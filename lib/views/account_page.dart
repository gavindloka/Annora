import 'package:annora_survey/models/user.dart';
import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  final User user;
  const AccountPage({
    super.key,
    required this.user
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
            Text("Name: ${widget.user.name}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Email: ${widget.user.email}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Phone: ${widget.user.phone}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Region: ${widget.user.region}", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
