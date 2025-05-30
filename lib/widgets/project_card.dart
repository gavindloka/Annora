import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/views/task_detail_page.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Task task;
  final User user;

  const ProjectCard({super.key, required this.task, required this.user});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(task: task, user: user),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Helper.getStatusSurveyorColor(task.statusSurveyor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "ID Project: #${task.projectID}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.white),
                children: [
                  const TextSpan(
                    text: "Nama : ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: task.customerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Lokasi : ${task.address}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 5),
            Text(
              "Tipe : ${task.category}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            Text(
              "Status Surveyor : ${task.statusSurveyor}",
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
