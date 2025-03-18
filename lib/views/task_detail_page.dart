import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/models/wo.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/wo_view_model.dart';
import 'package:annora_survey/views/form_survey_page.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  WO? woData;
  bool isLoading = true;
  String errorMsg = '';

  Future<void> fetchWO() async {
    final result = await WOViewModel().getWO(widget.task.woID.toString());
    if (result['success']) {
      setState(() {
        woData = result['data'];
        isLoading = false;
      });
    } else {
      setState(() {
        errorMsg = result['message'];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWO();
  }

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
                color: Helper.getStatusSurveyorColor(
                  widget.task.statusSurveyor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tanggal : ${widget.task.startDate}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Nama Client : ${widget.task.company}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "App No : ${widget.task.projectID}",
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

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (woData != null) ...[
              buildDetailRow("Customer Name", widget.task.customerName),
              const SizedBox(height: 6),
              buildDetailRow("Unit", widget.task.surveyType),
              const SizedBox(height: 6),
              buildDetailRow("Status Unit", widget.task.status),
              const SizedBox(height: 6),
              buildDetailRow("Alamat", widget.task.address),
              const SizedBox(height: 6),
              buildDetailRow("Telephone", woData!.telephone),
              const SizedBox(height: 6),
              buildDetailRow("Nama Perusahaan", widget.task.company),
              const SizedBox(height: 6),
              buildDetailRow("Jabatan", woData!.jabatan),
              const SizedBox(height: 6),
              buildDetailRow("Keterangan", woData!.keterangan),
              const SizedBox(height: 6),
              buildDetailRow("Kode Pos", woData!.kodePos),
              const SizedBox(height: 6),
              buildDetailRow("Jenis Survey", widget.task.category),
            ] else if (errorMsg.isNotEmpty) ...[
              Text('Error: $errorMsg', style: TextStyle(color: Colors.red)),
            ],
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FormSurveyPage(task: widget.task),
                ),
              );
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
