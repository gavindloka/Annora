import 'package:annora_survey/models/notif.dart';
import 'package:annora_survey/models/task.dart';
import 'package:annora_survey/models/user.dart';
import 'package:annora_survey/models/wo.dart';
import 'package:annora_survey/utils/helper.dart';
import 'package:annora_survey/viewModels/notif_view_model.dart';
import 'package:annora_survey/viewModels/wo_view_model.dart';
import 'package:annora_survey/views/form_survey_page.dart';
import 'package:annora_survey/views/survey_result_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
   List<Notif> notifications = [];

 Future<void> fetchNotifications() async {
    final result = await NotifViewModel().getNotifications(widget.user.email);
    if (result['success']) {
      setState(() {
        notifications = result['data'];
      });
    }
  }
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
    fetchNotifications();
  }

  @override
  Widget build(BuildContext context) {
    int unreadCount =
        notifications.where((notif) => notif.status == "unread").length;
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
                clipBehavior: Clip.none,
                children: [
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.notifications,
                      size: 30,
                      color: Colors.amber,
                    ),
                    itemBuilder: (context) {
                      if (isLoading) {
                        return [
                          const PopupMenuItem(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ];
                      }
                      if (notifications.isEmpty) {
                        return [
                          const PopupMenuItem(
                            child: Text("No new notifications"),
                          ),
                        ];
                      }
                      return notifications.map((notif) {
                        bool isUnread = notif.status == "unread";

                        return PopupMenuItem(
                          child: ListTile(
                            leading: Icon(
                              isUnread
                                  ? Icons.notifications_active
                                  : Icons.notifications_none,
                              color: isUnread ? Colors.orange : Colors.grey,
                            ),
                            title: Text(
                              notif.notification,
                              style: TextStyle(
                                fontWeight:
                                    isUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy, HH:mm').format(notif.date),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                          ),
                        );
                      }).toList();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 5,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 8,
                          minHeight: 8,
                        ),
                        child: Text(
                          unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                    "App No : ${widget.task.appNo}",
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
                          builder:
                              (context) => FormSurveyPage(task: widget.task, user: widget.user),
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
