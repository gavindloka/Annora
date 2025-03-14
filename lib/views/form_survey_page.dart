import 'package:flutter/material.dart';

class FormSurveyPage extends StatefulWidget {
  const FormSurveyPage({super.key});

  @override
  State<FormSurveyPage> createState() => _FormSurveyPageState();
}

class _FormSurveyPageState extends State<FormSurveyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.orange,
            child: IconButton(
              iconSize: 18,
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: const Text(
          "Form Survey",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: Colors.orange,
                  size: 30,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
