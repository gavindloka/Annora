import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/models/wo.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/wo_view_model.dart';
import 'package:annora_survey/views/form_survey_page.dart';
import 'package:annora_survey/views/survey_result_page.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final User user;
  const TaskDetailPage({super.key, required this.task, required this.user});

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
                    "Start Date : ${widget.task.startDate.toString().substring(0, widget.task.startDate.toString().indexOf(' '))}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Target Date : ${widget.task.targetDate.toString().substring(0, widget.task.targetDate.toString().indexOf(' '))}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Nama Client : ${widget.task.company}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "WO ID : ${widget.task.woID}",
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
              buildDetailRow("Customer Name", woData!.customerName),
              const SizedBox(height: 6),
              buildDetailRow("Cabang", woData!.cabang),
              const SizedBox(height: 6),
              buildDetailRow("Status Unit", woData!.statusUnit),
              const SizedBox(height: 6),
              buildDetailRow("Alamat", woData!.alamat),
              const SizedBox(height: 6),
              buildDetailRow("Telephone", woData!.telephone),
              const SizedBox(height: 6),
              buildDetailRow("Nama Perusahaan", woData!.namaPerusahaan),
              const SizedBox(height: 6),
              buildDetailRow("Jabatan", woData!.jabatan),
              const SizedBox(height: 6),
              buildDetailRow("Sales", woData!.sales),
              const SizedBox(height: 6),
              buildDetailRow("Keterangan", woData!.keterangan),
              const SizedBox(height: 6),
              buildDetailRow("Kode Pos", woData!.kodePos),
              const SizedBox(height: 6),
              buildDetailRow("Jenis Survey", woData!.jenisSurvey),
              const SizedBox(height: 6),
              buildDetailRow("Tipe Survey", woData!.tipeSurvey),
              const SizedBox(height: 6),
              buildDetailRow("Nama Pasangan", woData!.namaPasangan),
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
          child:
              widget.task.statusSurveyor == 'Uploading Task'
                  ? ElevatedButton(
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
                          builder: (context) => SurveyResultPage(task: widget.task),
                        ),
                      );
                    },
                    child: const Text(
                      "Survey Result",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : ElevatedButton(
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
                          builder:
                              (context) => FormSurveyPage(
                                task: widget.task,
                                user: widget.user,
                              ),
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
    String displayValue = (value == null || value.isEmpty) ? "Empty" : value;
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
              text: displayValue,
              style: TextStyle(fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}
