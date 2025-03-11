import 'package:annora_survey/widgets/bottom_bar.dart';
import 'package:annora_survey/widgets/project_card.dart';
import 'package:annora_survey/widgets/top_bar.dart';
import 'package:flutter/material.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});

  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {
  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "New Task",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  ProjectCard(
                    projectId: "2121",
                    name: "Rahman Faturrahman",
                    location: "Surabaya",
                    type: "Rumah",
                    backgroundColor: Colors.orange,
                  ),
                  ProjectCard(
                    projectId: "2121",
                    name: "Rahman Faturrahman",
                    location: "Surabaya",
                    type: "Rumah",
                    backgroundColor: Colors.blue,
                  ),
                  ProjectCard(
                    projectId: "2121",
                    name: "Rahman Faturrahman",
                    location: "Surabaya",
                    type: "Rumah",
                    backgroundColor: Color(0xFF004AAD),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
