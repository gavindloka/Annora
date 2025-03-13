import 'package:annora_survey/models/task.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

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
          "Detail Task",
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal : ${task.startDate}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Nama Client : ${task.company}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "App No : ${task.projectID}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Detail Customer",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildDetailRow("Customer Name", task.customerName),
            const SizedBox(height: 6),
            buildDetailRow("Unit", task.surveyType),
            const SizedBox(height: 6),
            buildDetailRow("Status Unit", task.status),
            const SizedBox(height: 6),
            buildDetailRow("Alamat", task.address),
            const SizedBox(height: 6),
            buildDetailRow("Telephone", "1234"),
            const SizedBox(height: 6),
            buildDetailRow("Nama Perusahaan", task.company),
            const SizedBox(height: 6),
            buildDetailRow("Jabatan", "STAF KEUANGAN"),
            const SizedBox(height: 6),
            buildDetailRow("Keterangan", "tanpa keterangan"),
            const SizedBox(height: 6),
            buildDetailRow("Kode Pos", "121212"),
            const SizedBox(height: 6),
            buildDetailRow("Jenis Survey", task.category),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              // Handle Process Survey action
            },
            child: const Text(
              "Process Survey",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          children: [
            TextSpan(text: "$label: "),
            TextSpan(
              text: value,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
