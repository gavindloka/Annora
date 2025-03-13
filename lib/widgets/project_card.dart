import 'package:annora_survey/models/task.dart';
import 'package:flutter/material.dart';

class ProjectCard extends StatelessWidget {
  final Task task;

  const ProjectCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.lightBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ID Project: #",
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
        ],
      ),
    );
  }
}
